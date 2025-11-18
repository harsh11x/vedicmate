# Firebase Setup Instructions

## Prerequisites
1. A Google/Firebase account
2. Flutter SDK installed
3. Android Studio (for Android)
4. Xcode (for iOS - Mac only)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `VedicMate` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create Project"

## Step 2: Enable Authentication Methods

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable the following providers:
   - **Phone** (for OTP authentication)
   - **Google** (for Google Sign-In)

### Phone Authentication Setup
- Click on "Phone" provider
- Click "Enable"
- No additional configuration needed for development
- **For Production**: You'll need to add your app's SHA-256 fingerprint

### Google Sign-In Setup
- Click on "Google" provider
- Click "Enable"
- Add your support email
- Save

## Step 3: Setup Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click "Create Database"
3. Choose **Start in test mode** (for development)
4. Select your region (choose closest to your users)
5. Click "Enable"

## Step 4: Android Configuration

### 4.1 Download google-services.json

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to "Your apps" section
3. Click "Add app" → Select **Android**
4. Fill in the details:
   - **Android package name**: `com.example.vedic_mate`
   - **App nickname**: VedicMate
   - **Debug signing certificate SHA-1**: (optional for now)
5. Click "Register app"
6. Download `google-services.json`
7. Place it in: `android/app/google-services.json`

### 4.2 Get SHA-1 Certificate (Required for Google Sign-In)

Run this command in your project root:
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 from the debug keystore and add it to Firebase:
1. Go to Firebase Console → Project Settings
2. Under "Your apps" → Click on your Android app
3. Click "Add fingerprint"
4. Paste the SHA-1

## Step 5: iOS Configuration (Mac Only)

### 5.1 Download GoogleService-Info.plist

1. In Firebase Console, go to **Project Settings**
2. Click "Add app" → Select **iOS**
3. Fill in the details:
   - **iOS bundle ID**: `com.example.vedicMate`
   - **App nickname**: VedicMate
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Open Xcode: `open ios/Runner.xcworkspace`
7. Drag `GoogleService-Info.plist` into `Runner` folder in Xcode
8. Make sure "Copy items if needed" is checked

### 5.2 Update Info.plist for Google Sign-In

Open `ios/Runner/Info.plist` and add:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID` with the value from `GoogleService-Info.plist`.

## Step 6: Install Dependencies

Run in your project root:
```bash
flutter pub get
```

## Step 7: Test the Setup

### Test Phone OTP:
1. Run the app: `flutter run`
2. Go to Login screen
3. Enter a phone number
4. Check Firebase Console → Authentication → Users to see if OTP is sent
5. Enter the OTP received on your phone
6. You should be logged in!

### Test Google Sign-In:
1. Click "Continue with Google"
2. Select your Google account
3. You should be logged in and see your account in Firebase Console → Authentication

## Troubleshooting

### Android Issues:

**Error: Default FirebaseApp is not initialized**
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean` and `flutter pub get`

**Google Sign-In not working**
- Add SHA-1 fingerprint to Firebase Console
- Make sure Google Sign-In is enabled in Firebase Authentication

### iOS Issues:

**Error: Firebase could not be initialized**
- Make sure `GoogleService-Info.plist` is added to Xcode project
- Clean build: `flutter clean` then rebuild

### Phone Authentication Issues:

**SMS not received**
- Check if Phone authentication is enabled in Firebase
- Verify the phone number format includes country code (+91)
- For testing, you can add test phone numbers in Firebase Console

**Error: This app is not authorized**
- Add SHA-1 fingerprint to Firebase (Android)
- Add bundle ID correctly (iOS)

## Production Checklist

Before going to production:

1. **Firestore Rules**: Change from test mode to production rules
2. **Authentication**: 
   - Set up reCAPTCHA for phone auth
   - Configure authorized domains
3. **App Signing**: Use release keystore for Android
4. **API Keys**: Restrict API keys in Google Cloud Console
5. **Billing**: Enable billing in Firebase (required for production usage)

## Security Rules for Firestore

Replace test mode rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Add other collection rules as needed
  }
}
```

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
