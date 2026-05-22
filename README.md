# Vedic Mate

Vedic Mate is a Flutter mobile app for spiritual guidance, AI-assisted astrology, learning, lifestyle practice, and remedy commerce. The product is being built as a full client experience first, with supporting backend and admin systems in the same repository.

## What The Mobile App Has Today

### Authentication And Profile

- Splash, login, email login, registration, guest handling, and Firebase-backed auth flows.
- Profile editing with name, email, phone OTP update, avatar upload, and account deletion.
- Apple/Google/social auth dependencies are included for production sign-in flows.

### Client Home And Guidance

- Client dashboard with navigation into consultations, AI Pandit, Kundli, remedies, education, lifestyle, wallet, settings, and orders.
- Onboarding screens for selecting service categories, entering birth details, and choosing a Pandit.
- Booking scheduling, custom booking requests, booking history, chat, and video call screens.

### AI Pandit

- AI Pandit list, profile, text chat, and voice call flows.
- Multilingual AI chat/voice support with local/custom/Gemini service fallbacks.
- User profile context is passed into AI flows for more personalized answers.
- Current app mode keeps AI chat/voice free, with wallet deduction logic disabled in the AI service path.

### Kundli And Astrology Tools

- Kundli creation and detailed Kundli view.
- Kundli chart widgets, tables, details sheets, PDF generation service, and AI-assisted Kundli interpretation.
- Palm reading input and Vastu input screens that accept images through the native iOS/Android picker.
- Relationship compatibility form and result screens.

### Remedies, Cart, Checkout, And Orders

- Remedies catalog, product detail pages, cart, checkout, order history, and order detail screens.
- Remedy products are treated as optional spiritual-commerce items such as gemstones, rudraksha, yantras, and puja kits depending on listing availability.
- Wallet and online payment checkout paths are present, with PayU and in-app purchase service scaffolding included.

### Education And Lifestyle

- Scripture library and reader screens.
- Bhagavad Gita/scripture reading flow backed by local asset data.
- Yoga poses list and detail screens.
- Ancient Indian history timeline feature.
- Habit tracker and journal screens for lifestyle practice.

### Wallet, Payments, And Notifications

- Wallet balance, recharge, transaction, and wallet pass services.
- PayU checkout integration and in-app purchase service scaffolding.
- Firebase Cloud Messaging/local notification service for app updates and user events.

### Pandit Side

- Pandit dashboard and verification flow.
- Document/photo upload, interview scheduling, blocked-account handling, chat/call routes, and wallet access.

## What We Are Building Next

- Stronger App Store positioning around a unique spiritual wellness assistant, not a generic horoscope app.
- More polished AI Pandit experiences with richer personalization, session memory, and clearer safety disclaimers.
- Production-ready remedy catalog, order fulfillment, and payment reconciliation.
- Better Pandit verification/admin workflows.
- More complete subscription/customer-center behavior.
- More translations and localization coverage across all supported languages.
- Final release hardening for iOS signing, privacy prompts, App Review notes, and store screenshots.

## Repository Structure

```text
.
├── lib/                   # Flutter mobile app
├── ios/                   # iOS Runner project and CocoaPods setup
├── android/               # Android project
├── assets/                # Images, icons, animations, and local content data
├── server/                # Backend/API code and mirrored service files
├── admin-panel/           # React admin panel
├── functions/             # Firebase/serverless functions
└── supabase/              # Supabase migrations and schema support
```

## Run The Mobile App

```bash
flutter pub get
flutter run
```

For iOS builds:

```bash
cd ios
pod install
cd ..
flutter build ios
```

Open `ios/Runner.xcworkspace` in Xcode for archive/upload builds.

## Run Backend

```bash
cd server
npm install
npm run dev
```

## Run Admin Panel

```bash
cd admin-panel
npm install
npm run dev
```

## Notes

- The Flutter app is the main mobile client for both client and Pandit experiences.
- The React admin panel is separate from the Flutter mobile app.
- Firebase, Supabase, PayU, StoreKit/in-app purchase, and local asset data are all part of the current product direction.

