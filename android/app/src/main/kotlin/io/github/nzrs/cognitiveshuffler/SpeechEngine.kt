package io.github.nzrs.cognitiveshuffler

import android.content.Context
import android.media.AudioAttributes
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import java.util.Locale

/**
 * Thin wrapper around the platform text-to-speech engine.
 *
 * The phone's installed engine is deliberately used instead of bundling a
 * voice: it keeps the APK small and lets the user pick a voice in Android.
 */
@Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
class SpeechEngine(
    context: Context,
    private val language: String,
    private val rate: Float,
    initialVolume: Float,
    private val onReady: () -> Unit,
    private val onError: (String) -> Unit,
) {
    private val appContext = context.applicationContext
    private var tts: TextToSpeech? = null

    @Volatile
    private var volume: Float = initialVolume.coerceIn(0f, 1f)

    @Volatile
    var ready: Boolean = false
        private set

    private var failed: Boolean = false

    fun start() {
        tts = TextToSpeech(appContext) { status ->
            if (status != TextToSpeech.SUCCESS) {
                fail("tts_init_failed")
                return@TextToSpeech
            }
            configure()
        }
    }

    private fun configure() {
        val engine = tts ?: return
        val preferred = if (language == "es") {
            Locale.forLanguageTag("es-ES")
        } else {
            Locale.US
        }
        var result = engine.setLanguage(preferred)
        if (result == TextToSpeech.LANG_MISSING_DATA ||
            result == TextToSpeech.LANG_NOT_SUPPORTED
        ) {
            result = engine.setLanguage(Locale.forLanguageTag(language))
        }
        if (result == TextToSpeech.LANG_MISSING_DATA ||
            result == TextToSpeech.LANG_NOT_SUPPORTED
        ) {
            fail("tts_unavailable")
            return
        }

        engine.setSpeechRate(rate.coerceIn(0.5f, 1.4f))
        engine.setPitch(0.96f)
        engine.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build(),
        )
        engine.setOnUtteranceProgressListener(
            object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) = Unit

                override fun onDone(utteranceId: String?) = Unit

                @Deprecated("Deprecated in Java")
                override fun onError(utteranceId: String?) = Unit

                override fun onError(utteranceId: String?, errorCode: Int) = Unit

                override fun onStop(utteranceId: String?, interrupted: Boolean) = Unit
            },
        )
        ready = true
        onReady()
    }

    fun speak(word: String): Boolean {
        if (!ready) return false
        val params = Bundle().apply {
            putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, volume)
        }
        return try {
            tts?.speak(
                word,
                TextToSpeech.QUEUE_FLUSH,
                params,
                "cue-${System.nanoTime()}",
            ) == TextToSpeech.SUCCESS
        } catch (_: Exception) {
            false
        }
    }

    fun setVolume(value: Float) {
        volume = value.coerceIn(0f, 1f)
    }

    fun stop() {
        try {
            tts?.stop()
        } catch (_: Exception) {
            // The engine may already be shutting down.
        }
    }

    fun shutdown() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (_: Exception) {
            // Best effort.
        }
        tts = null
        ready = false
    }

    private fun fail(code: String) {
        if (failed) return
        failed = true
        ready = false
        onError(code)
    }
}
