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

    git clone https://github.com/yourusername/flutter_method_channel_example.git
    cd flutter_method_channel_example

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

static const platform = MethodChannel('my_channel');
String _batteryLevel = 'Unknown battery level.';

// step 2..
<!-- Native Code Implementation -->

// Step 3..
<!-- Get battery level. -->
Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
}


***Native Code Implementation of Android and iOS***

**Android Side**

- File: android/app/src/main/kotlin/com/example/MainActivity.kt
- Kotlin code implements the native method to retrieve the battery level.


                                                            <!-- MainActivity.kt -->
<!------------------------------------------------------------------------------------------------------------------------------------>

package com.example.flutter_method_channel
import android.annotation.SuppressLint
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Define the MethodChannel name
    private val myChannel = "my_channel"

    // Configure the FlutterEngine to set up the MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create a MethodChannel and set a MethodCallHandler
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, myChannel).setMethodCallHandler { call, result ->
            // Handle method calls from Flutter on the main thread
            if (call.method == "getBatteryLevel") {
                // Get the battery level using the getBatteryLevel() method
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    // Return the battery level to Flutter if available
                    result.success(batteryLevel)
                } else {
                    // Return an error to Flutter if the battery level is not available
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                // Return 'not implemented' if the method is not recognized
                result.notImplemented()
            }
        }
    }

    // Method to get the battery level of the device
    @SuppressLint("ObsoleteSdkInt")
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int

        // Check if the Android version is Lollipop (API 21) or higher
        if (SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // Use BatteryManager to get the battery level for modern devices
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            // For older devices, use the battery level from the Intent broadcast
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 /
                           intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        // Return the calculated battery level
        return batteryLevel
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
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Access the FlutterViewController
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Create a MethodChannel
    let batteryChannel = FlutterMethodChannel(name: "my_channel",
                                              binaryMessenger: controller.binaryMessenger)

    // Set the MethodCallHandler for the MethodChannel
    batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Handle incoming method calls from Flutter
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented) // Return if the method is not implemented
        return
      }
      // Call the function to retrieve the battery level
      self?.receiveBatteryLevel(result: result)
    }

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Method to get the device battery level
  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true // Enable battery monitoring

    // Check if the battery state is unknown
    if device.batteryState == UIDevice.BatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Battery level not available.",
                          details: nil))
    } else {
      // Return the battery level as an integer percentage
      result(Int(device.batteryLevel * 100))
    }
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