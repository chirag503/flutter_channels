import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // step 1..
  static const EventChannel _eventChannel =
      EventChannel('com.example/sensorStream');
  static const MethodChannel _methodChannel =
      MethodChannel('com.example/sensorControl');

  String _sensorData = "No data received";
  bool _isListening = false;

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
      }, onError: (error) {
        setState(() {
          _sensorData = "Error: ${error.message}";
        });
      }, onDone: () {
        setState(() {
          _isListening = false;
        });
      });
    } catch (e) {
      setState(() {
        _sensorData = "Error starting stream: $e";
      });
    }
  }

  // Stop the sensor stream
  void _stopSensorStream() async {
    try {
      await _methodChannel.invokeMethod('stopStream');
      setState(() {
        _sensorData = "Stream stopped";
        _isListening = false;
      });
    } catch (e) {
      setState(() {
        _sensorData = "Error stopping stream: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Event Channel",
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(_sensorData),
              ElevatedButton(
                onPressed: _isListening ? null : _startSensorStream,
                child: Text("Start Listening"),
              ),
              ElevatedButton(
                onPressed: _isListening ? _stopSensorStream : null,
                child: Text("Stop Listening"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
