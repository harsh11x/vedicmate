# Vedic Mate - AI-Powered Astrology Consultation App

A modern, secure, and spiritually enriching Flutter application that connects seekers with verified Vedic experts through advanced technology.

## Monorepo Structure

```
.
├── admin-panel/           # React admin (separate app)
├── server/                # Node/Express backend
└── lib/                   # Flutter mobile app (client + pandit)
```

## Run Backend (Node/Express)

```bash
cd server
npm install
npm run dev
# Server on http://localhost:4000
```

## Run Admin Panel (React)

```bash 
cd admin-panel
npm install
npm run dev
# Admin on http://localhost:5173
```

## Run Flutter App (Mobile)

```bash
flutter pub get
flutter run
```

### Admin Login
- Email: `vedicmate2025@gmail.com`
- Password: `admin123`

> Note: The Flutter app no longer contains the admin panel. Use the React admin in `admin-panel/`.

## Features (Mobile)

- OTP-based and social login support
- Dual interface: Client and Pandit
- Digital Kundli generation and download
- Live and Remedies sections
- Video/Audio calls and encrypted chat (scaffold)
- Wallet, payments, ratings and reviews

## API Endpoints (Server)

- `GET /api/health` – health check
- `GET /api/settings` / `POST /api/settings` – platform settings
- `GET /api/pandits` / `POST /api/pandits` / `PUT /api/pandits/:id` / `POST /api/pandits/:id/block`
- `GET /api/bookings`
- `GET /api/live`

Integrate these endpoints from the Flutter app using `dio`/`http`, and from the Admin panel using `axios`.

