package io.github.nzrs.cognitiveshuffler

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val SESSION_CHANNEL =
            "io.github.nzrs.cognitiveshuffler/session"
        private const val EVENT_CHANNEL =
            "io.github.nzrs.cognitiveshuffler/session_events"
        private const val THEME_CHANNEL =
            "io.github.nzrs.cognitiveshuffler/theme"
        private const val NOTIFICATION_PERMISSION_REQUEST = 7001
    }

    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SESSION_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val plan = call.argument<String>("plan")
                    if (plan.isNullOrBlank()) {
                        result.error("bad_plan", "The session plan is empty.", null)
                    } else {
                        SessionService.start(this, plan)
                        result.success(true)
                    }
                }
                "pause" -> {
                    SessionService.pause(this)
                    result.success(true)
                }
                "resume" -> {
                    SessionService.resume(this)
                    result.success(true)
                }
                "stop" -> {
                    SessionService.stopSession(this)
                    result.success(true)
                }
                "extend" -> {
                    SessionService.extend(this, call.argument<Int>("minutes") ?: 15)
                    result.success(true)
                }
                "updateNoise" -> {
                    SessionService.updateNoise(
                        context = this,
                        enabled = call.argument<Boolean>("enabled") ?: true,
                        volume = (call.argument<Double>("volume") ?: 0.35).toFloat(),
                        color = (call.argument<Double>("color") ?: 0.3).toFloat(),
                        warmth = (call.argument<Double>("warmth") ?: 0.45).toFloat(),
                    )
                    result.success(true)
                }
                "getState" -> result.success(SessionService.snapshot())
                "requestNotificationPermission" ->
                    requestNotificationPermission(result)
                "setKeepScreenOn" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(SessionEvents)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            THEME_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAccentColor" -> result.success(systemAccentColor())
                else -> result.notImplemented()
            }
        }
    }

    private fun systemAccentColor(): Long? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return null
        val id = resources.getIdentifier("system_accent1_500", "color", "android")
        if (id == 0) return null
        return resources.getColor(id, theme).toLong() and 0xFFFFFFFFL
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (permissionResult != null) {
            result.success(false)
            return
        }
        permissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResult?.success(granted)
            permissionResult = null
        }
    }

    override fun onDestroy() {
        permissionResult?.success(false)
        permissionResult = null
        super.onDestroy()
    }
}
