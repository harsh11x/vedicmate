# Vedic Mate APK Installation Guide

## If you get "APP NOT INSTALLED AS PACKAGE APPEARS TO BE INVALID" error:

### Step 1: Uninstall Existing App (IMPORTANT!)
1. Go to **Settings** → **Apps** (or **Application Manager**)
2. Search for **"vedic_mate"** or **"Vedic Mate"**
3. If found, tap on it and select **"Uninstall"**
4. Make sure it's completely removed

### Step 2: Enable Unknown Sources
1. Go to **Settings** → **Security**
2. Enable **"Install unknown apps"** or **"Unknown sources"**
3. Or go to **Settings** → **Apps** → **Special access** → **Install unknown apps**
4. Enable for your file manager or browser

### Step 3: Choose the Right APK
- **For most modern devices (2020+):** Use `vedic-mate-arm64.apk` (30MB)
- **For older devices:** Use `vedic-mate-armeabi.apk` (28MB)  
- **Universal (works on all):** Use `vedic-mate-final.apk` (70MB)

### Step 4: Install
1. Transfer the APK to your device
2. Open the APK file
3. Tap **"Install"**
4. Wait for installation to complete

### Step 5: If Still Not Working
Try installing via ADB (if you have developer options enabled):
```bash
adb install -r vedic-mate-final.apk
```

### Common Issues:
- **"Package appears to be invalid"** → Uninstall existing app first
- **"App not installed"** → Enable unknown sources
- **"Parse error"** → Download APK again, might be corrupted
- **"Insufficient storage"** → Free up space (need ~100MB free)

### APK Files Location:
All APKs are in: `~/Desktop/VedicMate_APKs/`

