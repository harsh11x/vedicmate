# Authentication Guide - Vedic Mate App

## ✅ Firebase Authentication - Fully Integrated

The app now has **complete Firebase Authentication** integrated with multiple login methods.

## Available Authentication Methods

### 1. **Email/Password Authentication** ✨ NEW
- **Registration**: Users can create accounts with email and password
- **Login**: Dedicated email login screen (`/login/email`)
- **Password Reset**: Forgot password functionality
- **Email Verification**: Automatic email verification sent on registration

**How to use:**
- Registration: Fill in email and password on signup screen
- Login: Click "Login with Email" button or navigate to `/login/email`
- Password Reset: Click "Forgot Password?" on email login screen

### 2. **Phone OTP Authentication** ✅
- Send OTP to phone number
- Verify OTP to login
- Demo mode: Phone `1234567890`, OTP `123456`

### 3. **Google Sign-In** ✅
- One-tap Google authentication
- Automatically syncs profile data

### 4. **Guest/Anonymous Login** ✅
- Quick access without registration
- ₹5000 bonus wallet credit

## Firebase Console Setup Required

### Step 1: Enable Authentication Methods
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Enable the following:
   - ✅ **Email/Password** - Enable (Email link can be disabled)
   - ✅ **Phone** - Enable (for OTP)
   - ✅ **Google** - Enable (add OAuth client IDs)
   - ✅ **Anonymous** - Enable (for guest login)

### Step 2: Configure Google Sign-In
1. In Firebase Console → Authentication → Sign-in method → Google
2. Enable Google Sign-In
3. Add your app's SHA-1 certificate (for Android)
4. Download OAuth client IDs

### Step 3: Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
  }
}
```

## User Data Structure in Firestore

When a user registers, the following data is stored in `users/{userId}`:

```json
{
  "uid": "user_id",
  "displayName": "User Name",
  "email": "user@example.com",
  "phoneNumber": "+911234567890",
  "role": "client",
  "dateOfBirth": "Timestamp",
  "placeOfBirth": "City, State",
  "timeOfBirth": "12:00",
  "photoURL": "profile_image_url",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "lastLoginAt": "Timestamp",
  "isActive": true,
  "isVerified": false,
  "emailVerified": false,
  "isGuest": false
}
```

## Code Implementation

### Registration Flow
```dart
// In registration_screen.dart
User? user = await _authService.register(
  name,
  email,
  phone,
  password,  // Now required
  role,
  dateOfBirth: dob,
  placeOfBirth: place,
  timeOfBirth: time,
);
```

### Login Flow
```dart
// Email/Password Login
User? user = await _authService.signInWithEmailAndPassword(email, password);

// Phone OTP Login
await _authService.sendOTP(phoneNumber, role);
User? user = await _authService.verifyOTP(otp, phoneNumber, role);

// Google Login
User? user = await _authService.signInWithGoogle(role);

// Guest Login
User? user = await _authService.signInAsGuest();
```

## Alternative Authentication Solutions

If you want to consider alternatives to Firebase:

### 1. **Supabase** (Recommended)
- **Pros**: Open-source, self-hostable, similar to Firebase
- **Package**: `supabase_flutter`
- **Best for**: Projects wanting open-source solution

### 2. **AWS Amplify**
- **Pros**: Enterprise-grade, scalable, multiple providers
- **Package**: `amplify_flutter`
- **Best for**: Large-scale enterprise apps

### 3. **Appwrite**
- **Pros**: Self-hosted, open-source, multiple auth methods
- **Package**: `appwrite`
- **Best for**: Self-hosted solutions

### 4. **Auth0**
- **Pros**: Professional service, excellent security
- **Package**: `auth0_flutter`
- **Best for**: Enterprise apps needing advanced security

## Current Status

✅ **Firebase is fully integrated and ready to use!**

All authentication methods are implemented:
- ✅ Email/Password registration and login
- ✅ Phone OTP authentication
- ✅ Google Sign-In
- ✅ Guest/Anonymous login
- ✅ Password reset
- ✅ User profile management
- ✅ Firestore integration

## Testing

### Test Email/Password Registration
1. Go to Registration screen
2. Fill all fields including password
3. Submit - user created in Firebase
4. Check email for verification link

### Test Email/Password Login
1. Go to Login screen
2. Click "Login with Email"
3. Enter registered email and password
4. Successfully login

### Test Phone OTP
1. Enter phone number
2. Receive OTP (or use demo: 123456)
3. Verify and login

## Next Steps

1. **Enable Email/Password in Firebase Console** (if not already enabled)
2. **Configure Google Sign-In** (add OAuth client IDs)
3. **Set up Firestore Security Rules** (as shown above)
4. **Test all authentication methods**
5. **Configure email templates** in Firebase Console (optional)

The app is ready to use Firebase Authentication! 🚀

