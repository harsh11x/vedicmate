# Vedic Mate - AI-Powered Astrology Consultation App

A modern, secure, and spiritually enriching Flutter application that connects seekers with verified Vedic experts through advanced technology.

## Features

- **Dual Interface**: Separate experiences for Clients and Pandits
- **Authentication**: OTP-based and social login support
- **Video/Audio Calls**: HD quality with end-to-end encryption
- **Encrypted Chat**: Secure messaging with file sharing
- **AI Recommendations**: Smart Pandit suggestions based on preferences
- **Wallet System**: Secure payments with GST compliance
- **Ratings & Reviews**: Multi-criteria feedback system
- **Multi-language**: Support for multiple Indian languages
- **Dark/Light Theme**: Customizable with saffron and cream aesthetic

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDE)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd astroapp
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── theme/               # Theme configuration
│   ├── constants/           # App constants
│   ├── routes/              # Navigation routes
│   └── utils/               # Utility functions
├── models/                  # Data models
├── services/               # Business logic services
├── providers/              # State management (Riverpod)
├── screens/
│   ├── auth/               # Authentication screens
│   ├── client/             # Client-specific screens
│   ├── pandit/             # Pandit-specific screens
│   └── shared/             # Shared screens
└── widgets/                # Reusable widgets
```

## Key Screens

### Authentication
- **Splash Screen**: App initialization and branding
- **Login Screen**: OTP and social login options
- **Registration Screen**: User and Pandit registration

### Client Interface
- **Client Dashboard**: Home, search, bookings, profile
- **Pandit Search**: Advanced search and filtering
- **Pandit Profile**: Detailed Pandit information
- **Booking & Scheduling**: Calendar and time slot selection
- **Booking History**: View and manage bookings
- **Payment & Wallet**: Wallet management and transactions

### Pandit Interface
- **Pandit Dashboard**: Analytics, bookings, quick actions
- **Booking Management**: Accept, reject, manage bookings
- **Analytics**: Revenue and performance metrics
- **Profile Management**: Edit profile, availability, pricing

### Shared Features
- **Video Call Interface**: HD video calling with controls
- **Chat Interface**: Encrypted messaging
- **Payment Gateway**: Secure payment processing

## Configuration

### Firebase Setup (Required for production)

1. Create a Firebase project
2. Add Android/iOS apps to Firebase
3. Download configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
4. Place files in respective platform directories

### Payment Gateway (Razorpay)

1. Create Razorpay account
2. Get API keys
3. Configure in `lib/services/payment_service.dart`

### Video Calling (Agora)

1. Create Agora account
2. Get App ID and Token
3. Configure in video call service

## Development

### Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Features Implementation Status

- ✅ UI/UX Design (Material Design 3)
- ✅ Navigation & Routing
- ✅ Authentication Screens
- ✅ Client & Pandit Dashboards
- ✅ Search & Filter
- ✅ Booking System
- ✅ Payment & Wallet UI
- ⏳ Backend Integration (Placeholder services)
- ⏳ Video/Audio Call Integration
- ⏳ Chat Integration
- ⏳ Push Notifications
- ⏳ AI Recommendation Engine

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Copyright © 2024 Vedic Mate. All rights reserved.

## Support

For support, email support@vedicmate.com or create an issue in the repository.

