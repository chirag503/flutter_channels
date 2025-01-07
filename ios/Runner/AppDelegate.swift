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

