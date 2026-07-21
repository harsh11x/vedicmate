# Reels Video Setup

Reels were showing "Video unavailable" because video files on the server weren't persisting or reachable. Here's how to fix it.

## Option 1: Firebase Storage (Recommended)

Videos upload to Firebase Storage and stream reliably. No server file storage needed.

### 1. Get Firebase Web config
- Go to [Firebase Console](https://console.firebase.google.com) → your project (vedic-mate)
- Project Settings → General → Your apps → Add app (Web) if not added
- Copy: `apiKey`, `projectId`, `storageBucket`

### 2. Add to admin `.env.local`
```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_web_api_key
NEXT_PUBLIC_FIREBASE_PROJECT_ID=vedic-mate
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=vedic-mate.firebasestorage.app
```

### 3. Deploy Storage rules
```bash
firebase deploy --only storage
```
(Rules in `storage.rules` allow read/write to `reels/` folder)

### 4. Restart admin
```bash
npm run dev
```

New reel uploads will go to Firebase. The app will play them directly from the Firebase URL.

---

## Option 2: Server file storage

If you prefer server storage, ensure admin and app point to the **same backend**:

### Admin `.env.local`
```env
NEXT_PUBLIC_API_BACKEND=http://13.60.233.237:3001
```
(Use your actual server URL)

### App
- `EnvConfig.apiBaseUrl` or build with `--dart-define=API_BASE_URL=http://13.60.233.237:3001`

### On the server
- Videos must be in `server/assets/videos/reels/`
- If using Docker/AWS, use a **persistent volume** for that folder so uploads survive restarts
