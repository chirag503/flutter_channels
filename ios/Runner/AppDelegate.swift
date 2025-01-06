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
