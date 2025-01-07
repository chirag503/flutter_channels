# flutter_method_channel

**Flutter Method Channel Example**
This is a sample Flutter project demonstrating the use of a Method Channel to communicate between Flutter and native platform code (Android and iOS). The project shows how to invoke platform-specific functionality, such as retrieving battery level or other native features.


**Features**
1. Communication between Flutter and native code using Method Channels.
2. Example of invoking native methods from Flutter.
3. Demonstrates handling responses and errors from the platform side.


**Project Structure**
.
├── lib/
│   └── main.dart             # Flutter code (Method Channel implementation)
├── android/
│   └── MainActivity.kt       # Native Android code (Kotlin)
├── ios/
│   └── Runner/
│       └── AppDelegate.swift # Native iOS code (Swift)
└── pubspec.yaml              # Project dependencies


**Setup and Usage**
1. Clone the repository

    git clone https://github.com/yourusername/flutter_channels.git
    cd flutter_channels

2. Install dependencies
    Run the following command to install Flutter dependencies:

   - flutter pub get

3. Run the app
    Use the following command to run the app:

    - flutter run



**Implementation Details**

**Flutter Side (Dart)**

- File: lib/main.dart
- The Flutter code initializes the Method Channel and invokes methods to communicate with the platform.

// step 1..
<!-- Define Method channel Name -->

static const EventChannel _eventChannel = EventChannel('com.example/sensorStream');
static const MethodChannel _methodChannel = MethodChannel('com.example/sensorControl');
String _sensorData = "No data received";
bool _isListening = false;

// step 2..
<!-- Native Code Implementation -->

// Step 3..

// Start the sensor stream
void _startSensorStream() async {
  try {
    await _methodChannel.invokeMethod('startStream');
    setState(() {
      _isListening = true;
      _sensorData = "Waiting for sensor data...";
    });

    // Listen to the Event Channel
    _eventChannel.receiveBroadcastStream().listen((data) {
      setState(() {
        _sensorData = "Sensor Data: $data";
      });
    },onError: (error) {
      setState(() {
        _sensorData = "Error: ${error.message}";
      });
    },onDone: () {
      setState(() {
        _isListening = false;
        });
      });
  }catch (e) {
    setState(() {
      _sensorData = "Error starting stream: $e";
    });
  }
}

// Stop the sensor stream
void _stopSensorStream() async {
  try{
    await _methodChannel.invokeMethod('stopStream');
      setState(() {
      _sensorData = "Stream stopped";
      _isListening = false;
    });
  }catch (e) {
    setState(() {
        _sensorData = "Error stopping stream: $e";
    });
  }
}


***Native Code Implementation of Android and iOS***

**Android Side**

- File: android/app/src/main/kotlin/com/example/MainActivity.kt
- Kotlin code implements the native method to retrieve the battery level.


                                                            <!-- MainActivity.kt -->
<!------------------------------------------------------------------------------------------------------------------------------------>


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

    // Start the stream
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

    // Stop the stream
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


<!------------------------------------------------------------------------------------------------------------------------------------>


**iOS Side**

- File: ios/Runner/AppDelegate.swift
- Swift code implements the native method to retrieve the battery level.


                                                        <!-- AppDelegate.swift -->
<!------------------------------------------------------------------------------------------------------------------------------------>


import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let SENSOR_CHANNEL = "com.example/sensorStream"
  private let CONTROL_CHANNEL = "com.example/sensorControl"
  private var timer: Timer?
  private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Set up the EventChannel for streaming data
    let eventChannel = FlutterEventChannel(name: SENSOR_CHANNEL, binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)

    // Set up the MethodChannel for controlling the stream
    let methodChannel = FlutterMethodChannel(name: CONTROL_CHANNEL, binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) in
      switch call.method {
      case "startStream":
        self?.startStream()
        result(nil)
      case "stopStream":
        self?.stopStream()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startStream() {
    if timer == nil {
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        guard let eventSink = self?.eventSink else { return }
        let simulatedData = Int.random(in: 0...100) // Simulated sensor data
        eventSink(simulatedData)
      }
    }
  }

  private func stopStream() {
    timer?.invalidate()
    timer = nil
    eventSink = nil
  }
}

// Extend AppDelegate to conform to FlutterStreamHandler
extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}


<!------------------------------------------------------------------------------------------------------------------------------------>


**How It Works**
1. Flutter communicates with the native platform using a MethodChannel.
2. The platform side (Android or iOS) listens for method calls and executes the corresponding functionality.
3. Results are sent back to Flutter, including error handling.

**Requirements**
1. Flutter SDK (Latest stable version)
2. Android Studio or Xcode for native platform development
3. Device or emulator to test platform-specific code