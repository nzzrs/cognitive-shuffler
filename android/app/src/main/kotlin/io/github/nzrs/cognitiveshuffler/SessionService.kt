package io.github.nzrs.cognitiveshuffler

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock

/**
 * Owns the complete sleep session: cue schedule, phone TTS, procedural noise,
 * sleep timer, media notification and screen-off playback.
 *
 * Dart sends a precomputed cue plan once. The service only plays it, so Dart
 * timers are never required while the phone is in the user's pocket.
 */
class SessionService : Service() {
    companion object {
        private const val CHANNEL_ID = "sleep_session_v2"
        private const val OLD_CHANNEL_ID = "sleep_session"
        private const val NOTIFICATION_ID = 4201
        private const val ACTION_START = "io.github.nzrs.cognitiveshuffler.START"
        private const val ACTION_PAUSE = "io.github.nzrs.cognitiveshuffler.PAUSE"
        private const val ACTION_RESUME = "io.github.nzrs.cognitiveshuffler.RESUME"
        private const val ACTION_STOP = "io.github.nzrs.cognitiveshuffler.STOP"
        private const val ACTION_EXTEND = "io.github.nzrs.cognitiveshuffler.EXTEND"
        private const val ACTION_UPDATE_NOISE =
            "io.github.nzrs.cognitiveshuffler.UPDATE_NOISE"
        private const val EXTRA_MINUTES = "minutes"
        private const val EXTRA_ENABLED = "enabled"
        private const val EXTRA_VOLUME = "volume"
        private const val EXTRA_COLOR = "color"
        private const val EXTRA_WARMTH = "warmth"

        @Volatile
        private var pendingPlan: String? = null

        @Volatile
        private var current: SessionService? = null

        fun start(context: Context, planJson: String) {
            pendingPlan = planJson
            val intent = Intent(context, SessionService::class.java)
                .setAction(ACTION_START)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun pause(context: Context) = command(context, ACTION_PAUSE)

        fun resume(context: Context) = command(context, ACTION_RESUME)

        fun stopSession(context: Context) = command(context, ACTION_STOP)

        fun extend(context: Context, minutes: Int) {
            val intent = Intent(context, SessionService::class.java)
                .setAction(ACTION_EXTEND)
                .putExtra(EXTRA_MINUTES, minutes)
            context.startService(intent)
        }

        fun updateNoise(
            context: Context,
            enabled: Boolean,
            volume: Float,
            color: Float,
            warmth: Float,
        ) {
            val intent = Intent(context, SessionService::class.java)
                .setAction(ACTION_UPDATE_NOISE)
                .putExtra(EXTRA_ENABLED, enabled)
                .putExtra(EXTRA_VOLUME, volume)
                .putExtra(EXTRA_COLOR, color)
                .putExtra(EXTRA_WARMTH, warmth)
            context.startService(intent)
        }

        fun snapshot(): Map<String, Any?> = current?.snapshot()
            ?: mapOf(
                "running" to false,
                "paused" to false,
                "word" to null,
                "index" to 0,
                "elapsedMs" to 0L,
                "remainingMs" to -1L,
                "totalMs" to 0L,
                "language" to "",
            )

        private fun command(context: Context, action: String) {
            context.startService(
                Intent(context, SessionService::class.java).setAction(action),
            )
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var plan: SessionPlan? = null
    private var mediaSession: MediaSession? = null
    private var speech: SpeechEngine? = null
    @Volatile
    private var noise: NoiseEngine? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null

    private var cueIndex = 0
    private var lastIndex = 0
    private var lastWord: String? = null
    private var elapsedMs = 0L
    private var totalMs = 0L
    private var lastTick = 0L
    private var lastTimerEvent = 0L
    private var paused = false
    private var finished = false

    private var noiseEnabled = true
    private var noiseVolume = 0.35f
    private var noiseColor = 0.3f
    private var noiseWarmth = 0.45f

    private val ticker = object : Runnable {
        override fun run() {
            tick()
            if (!finished) handler.postDelayed(this, 250L)
        }
    }

    override fun onCreate() {
        super.onCreate()
        current = this
        createChannel()
        audioManager = getSystemService(AudioManager::class.java)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val raw = pendingPlan
                pendingPlan = null
                if (raw != null && plan == null) {
                    startSession(raw)
                } else if (raw == null && plan == null) {
                    stopSelf()
                }
            }
            ACTION_PAUSE -> pauseSession()
            ACTION_RESUME -> resumeSession()
            ACTION_STOP -> finishSession()
            ACTION_EXTEND -> extendSession(intent.getIntExtra(EXTRA_MINUTES, 15))
            ACTION_UPDATE_NOISE -> updateNoise(
                enabled = intent.getBooleanExtra(EXTRA_ENABLED, noiseEnabled),
                volume = intent.getFloatExtra(EXTRA_VOLUME, noiseVolume),
                color = intent.getFloatExtra(EXTRA_COLOR, noiseColor),
                warmth = intent.getFloatExtra(EXTRA_WARMTH, noiseWarmth),
            )
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        releaseSessionResources()
        current = null
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Keep playing if the user swipes the app away.
        super.onTaskRemoved(rootIntent)
    }

    private fun startSession(raw: String) {
        val parsed = try {
            SessionPlan.fromJson(raw)
        } catch (_: Exception) {
            emitError("bad_plan")
            stopSelf()
            return
        }
        plan = parsed
        noiseEnabled = parsed.noise.enabled
        noiseVolume = parsed.noise.volume
        noiseColor = parsed.noise.color
        noiseWarmth = parsed.noise.warmth
        totalMs = if (parsed.timerMinutes > 0) {
            parsed.timerMinutes * 60_000L
        } else {
            0L
        }
        elapsedMs = 0L
        cueIndex = 0
        lastIndex = 0
        lastWord = null
        paused = false
        finished = false
        lastTick = SystemClock.elapsedRealtime()
        lastTimerEvent = 0L

        createMediaSession()
        startForegroundCompat(buildNotification())
        acquireWakeLock()
        requestAudioFocus()

        if (noiseEnabled) {
            noise = NoiseEngine(
                volume = noiseVolume,
                color = noiseColor,
                warmth = noiseWarmth,
                enabled = true,
            ).also { it.start() }
        }

        speech = SpeechEngine(
            context = this,
            language = parsed.language,
            rate = parsed.rate,
            onReady = {
                handler.post {
                    if (!finished) emitState()
                }
            },
            onError = { code ->
                handler.post {
                    if (!finished) {
                        emitError(code)
                        finishSession(emitFinished = false)
                    }
                }
            },
        ).also { it.start() }

        handler.post(ticker)
        updateNotification()
        emitState()
    }

    private fun tick() {
        val currentPlan = plan ?: return
        if (finished) return
        if (!paused) {
            val now = SystemClock.elapsedRealtime()
            val delta = (now - lastTick).coerceAtLeast(0L)
            lastTick = now
            elapsedMs += delta

            if (totalMs > 0 && elapsedMs >= totalMs) {
                finishSession()
                return
            }

            val fadeOut = if (totalMs > 0) {
                currentPlan.fadeOutMs.coerceAtMost(totalMs / 2)
            } else {
                0L
            }
            val fadeStart = if (totalMs > 0) totalMs - fadeOut else Long.MAX_VALUE

            while (cueIndex < currentPlan.cues.size &&
                currentPlan.cues[cueIndex].atMs <= elapsedMs
            ) {
                if (elapsedMs >= fadeStart) {
                    cueIndex = currentPlan.cues.size
                    break
                }
                val engine = speech
                if (engine?.ready != true) break
                val cue = currentPlan.cues[cueIndex]
                if (engine.speak(cue.word)) {
                    lastWord = cue.word
                    lastIndex = cueIndex
                    cueIndex += 1
                    SessionEvents.emit(
                        mapOf(
                            "type" to "word",
                            "word" to cue.word,
                            "index" to lastIndex,
                        ),
                    )
                } else {
                    break
                }
            }

            val fadeIn = currentPlan.fadeInMs
            val envelope = when {
                totalMs > 0 && elapsedMs >= fadeStart && fadeOut > 0 ->
                    ((totalMs - elapsedMs).toFloat() / fadeOut).coerceIn(0f, 1f)
                fadeIn > 0 && elapsedMs < fadeIn ->
                    (elapsedMs.toFloat() / fadeIn).coerceIn(0f, 1f)
                else -> 1f
            }
            noise?.setEnvelope(envelope)

            if (now - lastTimerEvent >= 5_000L) {
                lastTimerEvent = now
                emitTimer()
            }
        }
    }

    private fun pauseSession() {
        if (plan == null || finished || paused) return
        paused = true
        lastTick = SystemClock.elapsedRealtime()
        speech?.stop()
        noise?.setPaused(true)
        releaseWakeLock()
        abandonAudioFocus()
        updateNotification()
        emitState()
    }

    private fun resumeSession() {
        if (plan == null || finished || !paused) return
        paused = false
        lastTick = SystemClock.elapsedRealtime()
        acquireWakeLock()
        requestAudioFocus()
        noise?.setPaused(false)
        val cues = plan?.cues ?: emptyList()
        while (cueIndex < cues.size && cues[cueIndex].atMs <= elapsedMs) {
            cueIndex += 1
        }
        updateNotification()
        emitState()
    }

    private fun extendSession(minutes: Int) {
        if (plan == null || finished || totalMs <= 0) return
        totalMs += minutes.coerceAtLeast(1) * 60_000L
        updateNotification()
        emitTimer()
    }

    private fun updateNoise(
        enabled: Boolean,
        volume: Float,
        color: Float,
        warmth: Float,
    ) {
        noiseEnabled = enabled
        noiseVolume = volume.coerceIn(0f, 1f)
        noiseColor = color.coerceIn(0f, 1f)
        noiseWarmth = warmth.coerceIn(0f, 1f)
        if (enabled && noise == null) {
            noise = NoiseEngine(
                volume = noiseVolume,
                color = noiseColor,
                warmth = noiseWarmth,
                enabled = true,
            ).also { it.start() }
        }
        noise?.setParameters(
            volume = noiseVolume,
            color = noiseColor,
            warmth = noiseWarmth,
            enabled = enabled,
        )
    }

    private fun finishSession(emitFinished: Boolean = true) {
        if (finished) return
        finished = true
        paused = false
        handler.removeCallbacksAndMessages(null)
        if (emitFinished) {
            SessionEvents.emit(mapOf("type" to "finished"))
        }
        releaseSessionResources()
        mediaSession?.isActive = false
        mediaSession?.release()
        mediaSession = null
        abandonAudioFocus()
        try {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } catch (_: Exception) {
            // Ignore.
        }
        stopSelf()
    }

    private fun releaseSessionResources() {
        speech?.shutdown()
        speech = null
        noise?.release()
        noise = null
        releaseWakeLock()
        handler.removeCallbacks(ticker)
    }

    @Suppress("DEPRECATION")
    private fun createMediaSession() {
        mediaSession?.release()
        mediaSession = MediaSession(this, "CognitiveShuffler").apply {
            setFlags(
                MediaSession.FLAG_HANDLES_MEDIA_BUTTONS or
                    MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS,
            )
            setCallback(object : MediaSession.Callback() {
                override fun onPlay() = resumeSession()
                override fun onPause() = pauseSession()
                override fun onStop() = finishSession()
            })
            isActive = true
        }
    }

    private fun updatePlaybackState() {
        val session = mediaSession ?: return
        val state = if (paused) {
            PlaybackState.STATE_PAUSED
        } else {
            PlaybackState.STATE_PLAYING
        }
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(
                    PlaybackState.ACTION_PLAY or
                        PlaybackState.ACTION_PAUSE or
                        PlaybackState.ACTION_PLAY_PAUSE or
                        PlaybackState.ACTION_STOP,
                )
                .setState(
                    state,
                    elapsedMs,
                    if (paused) 0f else 1f,
                )
                .build(),
        )
    }

    private fun buildNotification(): Notification {
        updatePlaybackState()
        val openIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val text = when {
            paused -> getString(R.string.notification_paused)
            totalMs == 0L -> getString(R.string.notification_infinite)
            else -> getString(R.string.notification_playing)
        }

        val builder = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.notification_session))
            .setContentText(text)
            .setSmallIcon(R.drawable.ic_stat_shuffle)
            .setContentIntent(openIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setLargeIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))

        if (totalMs > 0 && !paused) {
            val remaining = (totalMs - elapsedMs).coerceAtLeast(0L)
            builder
                .setWhen(System.currentTimeMillis() + remaining)
                .setShowWhen(true)
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
        } else {
            builder.setShowWhen(false)
        }

        if (paused) {
            builder.addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(this, android.R.drawable.ic_media_play),
                    getString(R.string.action_resume),
                    servicePendingIntent(ACTION_RESUME, 1),
                ).build(),
            )
        } else {
            builder.addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(this, android.R.drawable.ic_media_pause),
                    getString(R.string.action_pause),
                    servicePendingIntent(ACTION_PAUSE, 1),
                ).build(),
            )
        }
        builder.addAction(
            Notification.Action.Builder(
                Icon.createWithResource(
                    this,
                    android.R.drawable.ic_menu_close_clear_cancel,
                ),
                getString(R.string.action_stop),
                servicePendingIntent(ACTION_STOP, 2),
            ).build(),
        )
        if (totalMs > 0) {
            val extend = Intent(this, SessionService::class.java)
                .setAction(ACTION_EXTEND)
                .putExtra(EXTRA_MINUTES, 15)
            builder.addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(this, android.R.drawable.ic_menu_add),
                    getString(R.string.action_extend),
                    PendingIntent.getService(
                        this,
                        3,
                        extend,
                        PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE,
                    ),
                ).build(),
            )
        }
        return builder.build()
    }

    private fun servicePendingIntent(action: String, requestCode: Int): PendingIntent {
        return PendingIntent.getService(
            this,
            requestCode,
            Intent(this, SessionService::class.java).setAction(action),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun updateNotification() {
        if (plan == null || finished) return
        try {
            val manager = getSystemService(NotificationManager::class.java)
            manager.notify(NOTIFICATION_ID, buildNotification())
        } catch (_: Exception) {
            // Notification permission may be denied; playback still works.
        }
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        manager.deleteNotificationChannel(OLD_CHANNEL_ID)
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel),
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = getString(R.string.notification_channel_description)
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val manager = getSystemService(PowerManager::class.java)
            wakeLock = manager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "CognitiveShuffler::Session",
            ).apply { setReferenceCounted(false) }
        }
        val lock = wakeLock ?: return
        if (!lock.isHeld) {
            lock.acquire(12 * 60 * 60 * 1000L)
        }
    }

    private fun releaseWakeLock() {
        val lock = wakeLock ?: return
        if (lock.isHeld) {
            lock.release()
        }
    }

    private fun requestAudioFocus() {
        val manager = audioManager ?: return
        if (focusRequest == null) {
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
            focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(attributes)
                .setWillPauseWhenDucked(false)
                .setOnAudioFocusChangeListener(
                    { change ->
                        when (change) {
                            AudioManager.AUDIOFOCUS_LOSS -> pauseSession()
                            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                                val mode = audioManager?.mode
                                if (mode == AudioManager.MODE_IN_CALL ||
                                    mode == AudioManager.MODE_IN_COMMUNICATION
                                ) {
                                    pauseSession()
                                }
                            }
                        }
                    },
                    handler,
                )
                .build()
        }
        try {
            manager.requestAudioFocus(focusRequest!!)
        } catch (_: Exception) {
            // Audio focus is best effort.
        }
    }

    private fun abandonAudioFocus() {
        val manager = audioManager ?: return
        val request = focusRequest ?: return
        try {
            manager.abandonAudioFocusRequest(request)
        } catch (_: Exception) {
            // Ignore.
        }
    }

    private fun emitState() {
        SessionEvents.emit(
            mapOf(
                "type" to "state",
                "running" to (plan != null && !finished),
                "paused" to paused,
            ),
        )
        emitTimer()
    }

    private fun emitTimer() {
        val remaining = if (totalMs > 0) {
            (totalMs - elapsedMs).coerceAtLeast(0L)
        } else {
            -1L
        }
        SessionEvents.emit(
            mapOf(
                "type" to "timer",
                "remainingMs" to remaining,
                "totalMs" to totalMs,
            ),
        )
    }

    private fun emitError(code: String) {
        SessionEvents.emit(
            mapOf(
                "type" to "error",
                "code" to code,
                "language" to (plan?.language ?: ""),
            ),
        )
    }

    private fun snapshot(): Map<String, Any?> {
        val remaining = if (totalMs > 0) {
            (totalMs - elapsedMs).coerceAtLeast(0L)
        } else {
            -1L
        }
        return mapOf(
            "running" to (plan != null && !finished),
            "paused" to paused,
            "word" to lastWord,
            "index" to lastIndex,
            "elapsedMs" to elapsedMs,
            "remainingMs" to remaining,
            "totalMs" to totalMs,
            "language" to (plan?.language ?: ""),
        )
    }
}
