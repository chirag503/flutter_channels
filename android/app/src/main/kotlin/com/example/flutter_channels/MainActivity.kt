package com.example.flutter_channels
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SENSOR_CHANNEL = "com.example/sensorStream"
    private val CONTROL_CHANNEL = "com.example/sensorControl"

    private var handler: Handler? = null
    private var runnable: Runnable? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    this@MainActivity.eventSink = null
                }
            }
        )

        // Method Channel for control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTROL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStream" -> {
                    startStream()
                    result.success(null)
                }
                "stopStream" -> {
                    stopStream()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startStream() {
        try {
            if (handler == null) {
                handler = Handler(Looper.getMainLooper())
                runnable = object : Runnable {
                    override fun run() {
                        try {
                            val simulatedData = (0..100).random() // Simulated sensor data
                            eventSink?.success(simulatedData)
                            handler?.postDelayed(this, 1000) // Stream data every second
                        } catch (e: Exception) {
                            // Handle any exceptions that may occur during data streaming
                            e.printStackTrace()
                        }
                    }
                }
                handler?.post(runnable!!)
            }
        } catch (e: Exception) {
            // Handle any exceptions that may occur when starting the stream
            e.printStackTrace()
        }
    }

    private fun stopStream() {
        try {
            handler?.removeCallbacks(runnable!!)
            handler = null
            runnable = null
            eventSink = null
        } catch (e: Exception) {
            // Handle any exceptions that may occur when stopping the stream
            e.printStackTrace()
        }
    }

}
