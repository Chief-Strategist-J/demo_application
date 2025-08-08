# 📱 Video Calling Demo Application

A Flutter application that demonstrates real-time video calling functionality using Firebase for user management and VideoSDK for video communication.

## 🌟 Screenshots

| Home Screen | Users List | Incoming Call | Video Meeting |
|-------------|------------|---------------|---------------|
| ![Home Screen](screenshot/Screenshot%20from%202025-08-08%2018-09-17.png) | ![Users List](screenshot/Screenshot%20from%202025-08-08%2018-09-27.png) | ![Incoming Call](screenshot/Screenshot%20from%202025-08-08%2018-09-35.png) | ![Video Meeting](screenshot/Screenshot%20from%202025-08-08%2018-09-51.png) |

| Meeting Controls | Demo User Creation |
|------------------|--------------------|
| ![Meeting Controls](screenshot/Screenshot%20from%202025-08-08%2018-10-02.png) | ![Demo Users](screenshot/Screenshot%20from%202025-08-08%2018-10-15.png) |

## ✨ Features

### ✅ Implemented
- **🔥 Real-time User Management**: Firebase-powered user presence and status tracking
- **📞 Video Call Initiation**: Select contacts and start video calls
- **📲 Incoming Call Handling**: Beautiful incoming call screen with accept/decline options
- **🎥 Video Meeting Integration**: Integration with VideoSDK for actual video calls
- **👥 Demo Users**: Automatic creation of demo users for testing
- **🟢 Real-time Status**: Online/offline status and call status tracking
- **📱 Call Kit Integration**: Native call interface support

### 📱 Key Components

#### 1. Users List Screen
- View all available contacts
- See online/offline status
- Initiate video calls with available users
- Real-time user status updates

#### 2. Incoming Call Screen
- Beautiful animated incoming call interface
- Caller avatar with ripple effects
- Accept/decline call options
- Automatic navigation to video meeting

#### 3. Video Meeting
- Full video call functionality using VideoSDK
- Participant management
- Meeting controls (mute, camera, leave)

#### 4. Firebase Integration
- User authentication (anonymous for demo)
- Real-time database for user presence
- Firestore for call request management
- Automatic call status synchronization

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.8.1+)
- Firebase project
- VideoSDK account and API key

### 2. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable the following Firebase services:
   - Authentication (Anonymous sign-in)
   - Firestore Database
   - Realtime Database

3. Add your Flutter app to the Firebase project and download `google-services.json` for Android and `GoogleService-Info.plist` for iOS

4. Place the configuration files in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 3. VideoSDK Configuration

1. Get your VideoSDK API key from [VideoSDK Dashboard](https://app.videosdk.live/)

2. Update the token in `lib/core/constants.dart`:
   ```dart
   String videoCallSdkToken = "YOUR_VIDEOSDK_TOKEN_HERE";
   ```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Firebase Rules Setup

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Realtime Database Rules
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

## Usage

### 1. Launch the App
```bash
flutter run
```

### 2. Initialize Demo Users
- Tap "View Contacts & Make Call" on the home screen
- If no users are shown, tap "Create Demo Users"
- This creates several demo users for testing

### 3. Make a Video Call
- Select a contact from the users list
- Tap the video call button
- The call will be initiated and the receiver will get an incoming call

### 4. Handle Incoming Calls
- When receiving a call, an incoming call screen appears
- Accept the call to join the video meeting
- Decline to reject the call

### 5. Video Meeting
- Once in a meeting, you can:
  - Toggle microphone on/off
  - Toggle camera on/off
  - Leave the meeting

## Architecture

### State Management
- **BLoC Pattern**: Used throughout the app for state management
- **Firebase Service**: Centralized service for all Firebase operations
- **Real-time Streams**: Live updates for user status and call requests

### Key Files Structure
```
lib/
├── core/
│   └── constants.dart              # VideoSDK token and constants
├── features/
│   ├── call/
│   │   ├── incoming_call_screen.dart
│   │   └── bloc/                   # Incoming call state management
│   ├── home/
│   │   └── home_page.dart          # Main app screen
│   ├── users/
│   │   ├── users_list_screen.dart  # Contacts list
│   │   ├── components/
│   │   └── bloc/                   # Users state management
│   └── videoCall/
│       └── videoCall/              # Video meeting components
├── models/
│   ├── user.dart                   # User model
│   └── call_request.dart           # Call request model
└── services/
    └── firebase_service.dart       # Firebase operations
```

## Key Features Explanation

### 1. Real-time User Presence
- Uses Firebase Realtime Database for presence detection
- Automatically detects when users go online/offline
- Updates user status in real-time across all devices

### 2. Call Request Management
- Stores call requests in Firestore
- Real-time listening for incoming calls
- Automatic status updates (initiated, ringing, accepted, declined, ended)

### 3. Demo User Creation
- Creates 4 demo users automatically
- Each user has unique avatar, name, and online status
- Simulates real user interactions

### 4. Video Call Integration
- Seamless integration with VideoSDK
- Meeting ID generation and management
- Participant handling and controls

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` and `GoogleService-Info.plist` are correctly placed
   - Check Firebase project configuration

2. **VideoSDK token expired**
   - Generate a new token from VideoSDK dashboard
   - Update the token in `constants.dart`

3. **No demo users appearing**
   - Tap "Create Demo Users" button
   - Check Firebase Authentication is enabled
   - Verify Firestore rules allow read/write

4. **Incoming calls not working**
   - Ensure Firestore rules are configured
   - Check real-time database rules
   - Verify user authentication

### Debug Mode
- The app uses `print` statements for debugging
- Check console output for Firebase initialization and call flow

## Future Enhancements

- [ ] Push notifications for incoming calls
- [ ] Group video calls
- [ ] Call history
- [ ] User profiles and settings
- [ ] Screen sharing
- [ ] Chat during calls
- [ ] Call recording

## Dependencies

Key packages used:
- `firebase_core`: Firebase initialization
- `cloud_firestore`: User and call data storage
- `firebase_database`: Real-time presence
- `firebase_auth`: User authentication
- `videosdk`: Video calling functionality
- `flutter_bloc`: State management
- `flutter_callkit_incoming`: Native call interface

## License

This project is created for demonstration purposes.
