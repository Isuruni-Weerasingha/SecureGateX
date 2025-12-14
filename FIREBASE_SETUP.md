# Firebase Setup Guide for SecureGateX

## Method 1: Using FlutterFire CLI (Recommended)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Configure Firebase for your project
```bash
flutterfire configure
```

This will:
- Ask you to select/create a Firebase project
- Generate `lib/firebase_options.dart` automatically
- Configure for all platforms (Android, iOS, Web, etc.)

### Step 4: Update main.dart to use Firebase options
The generated `firebase_options.dart` will be automatically used.

---

## Method 2: Manual Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `secure-gatex` (or your preferred name)
4. Follow the setup wizard
5. Enable Google Analytics (optional)

### Step 2: Add Android App

1. In Firebase Console, click the Android icon
2. Register app with:
   - **Package name**: `com.example.secure_gatex`
   - **App nickname**: SecureGateX (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### Step 3: Add iOS App (if needed)

1. In Firebase Console, click the iOS icon
2. Register app with:
   - **Bundle ID**: `com.example.secureGatex` (check your iOS project)
   - **App nickname**: SecureGateX (optional)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Add Web App (if needed)

1. In Firebase Console, click the Web icon (`</>`)
2. Register app with nickname: SecureGateX
3. Copy the Firebase configuration object

### Step 5: Configure Android

#### Update `android/build.gradle.kts`:
Add to the `buildscript` dependencies:
```kotlin
classpath("com.google.gms:google-services:4.4.0")
```

#### Update `android/app/build.gradle.kts`:
Add at the bottom:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

### Step 6: Configure iOS (if needed)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Drag `GoogleService-Info.plist` into the Runner folder
3. Make sure "Copy items if needed" is checked

### Step 7: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Enable **Email/Password** authentication
4. Click **Save**

### Step 8: Enable Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to your users)
5. Click **Enable**

---

## Step 9: Create firebase_options.dart (Manual)

Create `lib/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.secureGatex',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.secureGatex',
  );
}
```

**Get your Firebase config values from:**
- Firebase Console → Project Settings → Your apps → Select your app

### Step 10: Update main.dart

Update `lib/main.dart` to use Firebase options:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:secure_gatex/firebase_options.dart';
import 'package:secure_gatex/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}
```

---

## Quick Setup Commands

```bash
# 1. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Login to Firebase
firebase login

# 3. Configure Firebase (interactive)
flutterfire configure

# 4. Get dependencies
flutter pub get

# 5. Run the app
flutter run
```

---

## Verify Setup

After setup, test your Firebase connection:

1. Run the app
2. Try to login with a test account
3. Check Firebase Console → Authentication → Users (should see the user)
4. Check Firebase Console → Firestore → Data (should see user document)

---

## Troubleshooting

### Android Issues:
- Make sure `google-services.json` is in `android/app/`
- Check `android/app/build.gradle.kts` has the Google Services plugin
- Ensure `minSdkVersion` is at least 21

### iOS Issues:
- Make sure `GoogleService-Info.plist` is added to Xcode project
- Check Bundle ID matches in Firebase and Xcode

### Web Issues:
- Make sure Firebase config is correct in `firebase_options.dart`
- Check browser console for errors

---

## Security Rules (Firestore)

For development, you can use test mode. For production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

