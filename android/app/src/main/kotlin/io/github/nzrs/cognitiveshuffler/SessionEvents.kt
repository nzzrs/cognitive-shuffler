package io.github.nzrs.cognitiveshuffler

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/** Small bridge between the foreground service and the Flutter event stream. */
object SessionEvents : EventChannel.StreamHandler {
    private val main = Handler(Looper.getMainLooper())

    @Volatile
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(event: Map<String, Any?>) {
        val current = sink ?: return
        main.post {
            try {
                current.success(event)
            } catch (_: Exception) {
                // The Flutter engine may have detached; state can be re-read.
            }
        }
    }
}
