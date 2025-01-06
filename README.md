# Flutter Project with Platform Channels

This Flutter project demonstrates the use of **MethodChannel** and **EventChannel** for communication between Flutter and native platforms (Android/iOS). Each functionality is available in a dedicated branch for better understanding and organization.

---

## Branches Overview

### 1. **MethodChannel** (`method_channel` branch)
   The `method_channel` branch demonstrates how to use `MethodChannel` for invoking platform-specific methods from Flutter. 

   **Features:**
   - One-time communication between Flutter and native platforms.
   - Call methods implemented on native platforms (Android/iOS).
   - Retrieve results or data synchronously.

   **Switch to the branch:**
   git checkout method_channel

### 2. **EventChannel** (`event_channel` branch)
   The `event_channel` branch demonstrates how to use `EventChannel` for continuous communication (streaming) from native platforms to Flutter.

   **Features:**
   - Listen to real-time or continuous data streams from native platforms.
   - Ideal for scenarios like listening to sensor data or system events.

   **Switch to the branch:**
   git checkout event_channel
