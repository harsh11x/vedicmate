# Vedic Mate - Setup Guide

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

## Demo Credentials

### Client/Pandit Login
- **Phone Number**: `1234567890`
- **OTP**: `123456`

### Admin Login
- **Email**: `vedicmate2025@gmail.com`
- **Password**: `admin123`

## Key Features Implemented

### ✅ Authentication
- Demo OTP login (1234567890 / 123456)
- Role-based login (Client/Pandit)
- Admin authentication
- Social login UI (Google, Facebook)

### ✅ Client Features
- Digital Kundli generation on first signup
- Kundli download and share
- Pandit search and filtering
- Booking and scheduling
- Video/Audio call interface
- Chat interface
- Booking history
- Wallet and payment management

### ✅ Pandit Features
- Verification flow with document upload
- Online interview scheduling
- Dashboard with analytics
- Booking management
- Earnings tracking (65% share)
- Blocked account handling

### ✅ Admin Panel
- Overview dashboard
- Pandit management (Add/Edit/Remove)
- Active/Pending/Blocked Pandit filtering
- Live monitoring of calls and chats
- Set per-minute rates (Video/Audio/Chat)
- Revenue split: 65% Pandit, 35% Platform
- Block/Unblock Pandits
- View detailed analytics:
  - Call minutes
  - Chat minutes
  - Today's earnings
  - Total earnings

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/          # Yellow/white theme (Astrotalk style)
│   ├── constants/      # App constants (65/35 split)
│   ├── routes/         # Navigation routes
│   └── utils/          # Utilities (blocked check, validators)
├── models/            # Data models
├── services/          # Business logic (placeholder for backend)
├── screens/
│   ├── auth/          # Login, Registration, Splash
│   ├── client/        # Client dashboard
│   ├── pandit/         # Pandit dashboard, verification, blocked
│   ├── admin/         # Admin dashboard, rate setting
│   └── shared/        # Kundli, booking, chat, video call, etc.
└── widgets/           # Reusable components
```

## Revenue Model

- **Platform Fee**: 35%
- **Pandit Share**: 65%
- Applied to all bookings (Video Call, Audio Call, Chat)

## Kundli Generation

When a client signs up for the first time:
1. Collects: Name, DOB, Place of Birth, Time of Birth
2. Generates digital Kundli with:
   - Planetary positions
   - Houses information
   - Personal details
3. Watermark: "Vedic Mate" at bottom right
4. Downloadable and shareable

## Pandit Verification Flow

1. **Document Upload**:
   - ID Proof
   - Astrology Certificate
   - Profile Photo

2. **Interview Scheduling**:
   - Select date and time
   - Conducted via app video call

3. **Rate Setting** (by Admin):
   - After successful interview
   - Set per-minute rates for:
     - Video Call
     - Audio Call
     - Chat

## Admin Capabilities

### Pandit Management
- View all Pandits with filters (All/Active/Pending/Blocked)
- Add new Pandits
- Edit Pandit details
- Remove Pandits
- Block/Unblock Pandits temporarily

### Monitoring
- Live monitoring of active calls/chats
- View session details
- Safety monitoring

### Analytics
- Active Pandits count
- Total clients
- Today's revenue
- Platform fee earnings
- Per-Pandit analytics:
  - Total calls
  - Call minutes
  - Chat minutes
  - Today's earnings
  - Total earnings

### Rate Management
- Set per-minute rates for each Pandit
- Configure Video/Audio/Chat rates
- View revenue split (65/35)

## Blocked Account Handling

If a Pandit account is blocked:
- Shows "Account Temporarily Blocked" screen
- Displays contact information
- Prevents access to dashboard
- Can logout and return to login

## Theme

- **Primary Color**: Yellow (#FFC107) - Astrotalk style
- **Background**: White
- **Accent**: Gold
- Material Design 3

## Next Steps for Production

1. **Backend Integration**:
   - Connect to Firebase/Backend API
   - Implement real authentication
   - Store user data
   - Handle payments

2. **Video/Audio Calls**:
   - Integrate Agora SDK
   - Enable real-time calling

3. **Chat**:
   - Integrate Socket.IO
   - Real-time messaging
   - File sharing

4. **Payments**:
   - Integrate Razorpay
   - Handle transactions
   - Wallet management

5. **Kundli Generation**:
   - Integrate astrology calculation library
   - Generate accurate charts

6. **Push Notifications**:
   - Firebase Cloud Messaging
   - Booking reminders
   - Admin alerts

## Testing Checklist

- [x] Demo login works (1234567890 / 123456)
- [x] Admin login works (vedicmate2025@gmail.com / admin123)
- [x] Client registration generates Kundli
- [x] Kundli can be downloaded
- [x] Pandit verification flow works
- [x] Admin can manage Pandits
- [x] Admin can set rates
- [x] Admin can block/unblock Pandits
- [x] Blocked Pandits see error screen
- [x] Revenue split is 65/35
- [x] All screens use yellow theme

## Support

For issues or questions, contact: support@vedicmate.com

