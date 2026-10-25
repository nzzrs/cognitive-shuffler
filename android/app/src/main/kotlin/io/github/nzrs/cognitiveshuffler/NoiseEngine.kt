package io.github.nzrs.cognitiveshuffler

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sin

/**
 * Procedural pink/brown noise with a warmth macro.
 *
 * The engine is intentionally tiny: a mono float AudioTrack, a Paul Kellet pink
 * filter, a leaky brown-noise integrator, two low-pass stages and a low-end
 * shelf. It runs in a foreground service, so it keeps going with the screen off.
 */
class NoiseEngine(
    volume: Float,
    color: Float,
    warmth: Float,
    enabled: Boolean,
) {
    companion object {
        private const val SAMPLE_RATE = 44_100
        private const val CHUNK = 1024
    }

    private val random = java.util.Random(0x5EED_2026)
    private var track: AudioTrack? = null
    private var thread: Thread? = null

    @Volatile private var running = true
    @Volatile private var paused = false
    @Volatile private var enabled = enabled
    @Volatile private var targetVolume = volume.coerceIn(0f, 1f)
    @Volatile private var targetColor = color.coerceIn(0f, 1f)
    @Volatile private var targetWarmth = warmth.coerceIn(0f, 1f)
    @Volatile private var envelope = 0f

    private var currentColor = targetColor
    private var currentWarmth = targetWarmth
    private var currentGain = 0f

    private val lowPassA = Biquad()
    private val lowPassB = Biquad()
    private val lowShelf = Biquad()

    fun start() {
        if (thread != null) return
        val minBuffer = AudioTrack.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_FLOAT,
        )
        if (minBuffer <= 0) return
        val bufferSize = max(minBuffer, CHUNK * 4 * 4)
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val format = AudioFormat.Builder()
            .setSampleRate(SAMPLE_RATE)
            .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
            .build()
        val created = try {
            AudioTrack.Builder()
                .setAudioAttributes(attributes)
                .setAudioFormat(format)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setBufferSizeInBytes(bufferSize)
                .build()
        } catch (_: Exception) {
            null
        }
        if (created == null || created.state != AudioTrack.STATE_INITIALIZED) {
            created?.release()
            return
        }
        track = created
        try {
            created.play()
        } catch (_: IllegalStateException) {
            created.release()
            track = null
            return
        }
        thread = Thread({ loop() }, "noise-engine").also {
            it.priority = Thread.NORM_PRIORITY
            it.start()
        }
    }

    fun setParameters(volume: Float, color: Float, warmth: Float, enabled: Boolean) {
        this.enabled = enabled
        targetVolume = volume.coerceIn(0f, 1f)
        targetColor = color.coerceIn(0f, 1f)
        targetWarmth = warmth.coerceIn(0f, 1f)
    }

    fun setEnvelope(value: Float) {
        envelope = value.coerceIn(0f, 1f)
    }

    fun setPaused(value: Boolean) {
        paused = value
    }

    fun release() {
        running = false
        thread?.interrupt()
        try {
            thread?.join(600)
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
        }
        thread = null
        try {
            track?.stop()
            track?.release()
        } catch (_: Exception) {
            // Best effort.
        }
        track = null
    }

    private fun loop() {
        val buffer = FloatArray(CHUNK)
        var pink0 = 0f
        var pink1 = 0f
        var pink2 = 0f
        var pink3 = 0f
        var pink4 = 0f
        var pink5 = 0f
        var pink6 = 0f
        var brown = 0f

        while (running) {
            val output = track ?: break
            if (paused) {
                try {
                    output.pause()
                } catch (_: IllegalStateException) {
                    // Ignore.
                }
                try {
                    Thread.sleep(60)
                } catch (_: InterruptedException) {
                    break
                }
                continue
            }
            if (output.playState != AudioTrack.PLAYSTATE_PLAYING) {
                try {
                    output.play()
                } catch (_: IllegalStateException) {
                    break
                }
            }

            currentColor += (targetColor - currentColor) * 0.07f
            currentWarmth += (targetWarmth - currentWarmth) * 0.07f
            val cutoff = (18_000.0 * (600.0 / 18_000.0).pow(currentWarmth.toDouble()))
                .toFloat()
                .coerceIn(140f, 19_000f)
            lowPassA.setLowPass(SAMPLE_RATE.toFloat(), cutoff, 0.65f)
            lowPassB.setLowPass(SAMPLE_RATE.toFloat(), cutoff, 0.65f)
            lowShelf.setLowPass(SAMPLE_RATE.toFloat(), 150f, 0.7f)
            val lowMix = currentWarmth * 0.38f
            val targetGain = if (enabled) targetVolume * envelope else 0f

            for (index in 0 until CHUNK) {
                val white = random.nextFloat() * 2f - 1f
                pink0 = 0.99886f * pink0 + white * 0.0555179f
                pink1 = 0.99332f * pink1 + white * 0.0750759f
                pink2 = 0.96900f * pink2 + white * 0.1538520f
                pink3 = 0.86650f * pink3 + white * 0.3104856f
                pink4 = 0.55000f * pink4 + white * 0.5329522f
                pink5 = -0.7616f * pink5 - white * 0.0168980f
                val pink = (pink0 + pink1 + pink2 + pink3 + pink4 + pink5 + pink6 +
                    white * 0.5362f) * 0.11f
                pink6 = white * 0.115926f

                brown = (brown + white * 0.02f) / 1.02f
                val mixed = pink * (1f - currentColor) + brown * 3.2f * currentColor
                var sample = lowPassB.process(lowPassA.process(mixed))
                sample += lowShelf.process(sample) * lowMix
                currentGain += (targetGain - currentGain) * 0.0015f
                buffer[index] = (sample * currentGain * 0.9f).coerceIn(-1f, 1f)
            }

            val written = try {
                output.write(buffer, 0, buffer.size, AudioTrack.WRITE_BLOCKING)
            } catch (_: Exception) {
                -1
            }
            if (written < 0) break
        }
    }

    private class Biquad {
        private var b0 = 1f
        private var b1 = 0f
        private var b2 = 0f
        private var a1 = 0f
        private var a2 = 0f
        private var x1 = 0f
        private var x2 = 0f
        private var y1 = 0f
        private var y2 = 0f

        fun setLowPass(sampleRate: Float, cutoff: Float, q: Float) {
            val frequency = cutoff.coerceIn(20f, sampleRate * 0.49f)
            val omega = 2.0 * Math.PI * frequency / sampleRate
            val alpha = sin(omega) / (2.0 * q)
            val cosOmega = Math.cos(omega)
            val a0 = 1.0 + alpha
            b0 = ((1.0 - cosOmega) / 2.0 / a0).toFloat()
            b1 = ((1.0 - cosOmega) / a0).toFloat()
            b2 = b0
            a1 = (-2.0 * cosOmega / a0).toFloat()
            a2 = ((1.0 - alpha) / a0).toFloat()
        }

        fun process(input: Float): Float {
            val output = b0 * input + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1
            x1 = input
            y2 = y1
            y1 = output
            return output
        }
    }
}
