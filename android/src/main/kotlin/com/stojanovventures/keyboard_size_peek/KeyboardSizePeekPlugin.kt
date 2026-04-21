package com.stojanovventures.keyboard_size_peek

import android.app.Activity
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsAnimationCompat.BoundsCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

class KeyboardSizePeekPlugin :
    FlutterPlugin,
    ActivityAware,
    EventChannel.StreamHandler {
    private var eventChannel: EventChannel? = null
    private var events: EventChannel.EventSink? = null
    private var activity: Activity? = null
    private var rootView: View? = null
    private var density: Float = 1f

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(binding.binaryMessenger, "keyboard_size_peek/events")
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        rootView = activity?.window?.decorView
        density = activity?.resources?.displayMetrics?.density ?: 1f
        installCallback()
    }

    override fun onDetachedFromActivity() {
        removeCallback()
        activity = null
        rootView = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onListen(
        arguments: Any?,
        sink: EventChannel.EventSink,
    ) {
        events = sink
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }

    private fun installCallback() {
        val view = rootView ?: return
        ViewCompat.setWindowInsetsAnimationCallback(
            view,
            object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_STOP) {
                override fun onStart(
                    animation: WindowInsetsAnimationCompat,
                    bounds: BoundsCompat,
                ): BoundsCompat {
                    if (animation.typeMask and WindowInsetsCompat.Type.ime() != 0) {
                        // At onStart, getRootWindowInsets reflects the target IME
                        // visibility — true when showing, false when hiding.
                        val targetVisible =
                            ViewCompat
                                .getRootWindowInsets(view)
                                ?.isVisible(WindowInsetsCompat.Type.ime()) ?: false
                        val heightPx = if (targetVisible) bounds.upperBound.bottom else 0
                        events?.success(
                            mapOf(
                                "height" to (heightPx / density).toDouble(),
                                "durationMs" to animation.durationMillis.toInt(),
                            ),
                        )
                    }
                    return bounds
                }

                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: MutableList<WindowInsetsAnimationCompat>,
                ): WindowInsetsCompat = insets
            },
        )
    }

    private fun removeCallback() {
        rootView?.let { ViewCompat.setWindowInsetsAnimationCallback(it, null) }
    }
}
