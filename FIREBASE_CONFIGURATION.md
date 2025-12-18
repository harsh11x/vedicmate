# Firebase Configuration Guide

## Current Status
✅ `firebase_options.dart` file has been created
✅ `main.dart` has been updated to use `DefaultFirebaseOptions.currentPlatform`

## Next Steps to Complete Firebase Setup

### Option 1: Using FlutterFire CLI (Recommended)

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   # OR using Homebrew on macOS:
   brew install firebase-cli
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Configure FlutterFire:**
   ```bash
   cd /Users/harshdev/Documents/Projects/astroapp
   flutterfire configure --project=vedic-mate
   ```

   This will automatically:
   - Detect your Firebase project
   - Update `firebase_options.dart` with real values
   - Update `google-services.json` (Android)
   - Update `GoogleService-Info.plist` (iOS)

### Option 2: Manual Configuration

If you can't use FlutterFire CLI, you can manually update the values:

1. **Get your Firebase project credentials:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: `vedic-mate`
   - Go to Project Settings (gear icon)
   - Scroll down to "Your apps" section

2. **Update `lib/firebase_options.dart`:**
   - Replace placeholder values with real values from Firebase Console
   - Update `apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`
   - For iOS, also update `iosBundleId` to match your iOS app bundle ID

3. **Update `android/app/google-services.json`:**
   - Download the latest `google-services.json` from Firebase Console
   - Replace the existing file

4. **Update iOS configuration (if needed):**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/` directory

## Current Placeholder Values

The current `firebase_options.dart` uses placeholder values:
- `projectId`: `vedicmate-placeholder`
- `apiKey`: `AIzaSyPlaceholder-Key-Replace-With-Real-Key`
- `appId`: `1:123456789000:android:abcdef1234567890`

**These need to be replaced with your actual Firebase project values for the app to work properly.**

## Verification

After configuration, test Firebase by:
1. Running the app: `flutter run`
2. Check console logs for: `✅ Firebase initialized successfully`
3. Try authentication features to verify Firebase is working

