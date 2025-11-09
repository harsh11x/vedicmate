# Build Instructions

## Android APK Builds

### Build Client APK
```bash
./build_client.sh
```
Output: `build/app/outputs/flutter-apk/client/vedic-mate-client.apk`

### Build Pandit APK
```bash
./build_pandit.sh
```
Output: `build/app/outputs/flutter-apk/pandit/vedic-mate-pandit.apk`

### Manual Build Commands

**Client:**
```bash
flutter build apk --release --target=lib/main_client.dart --build-name=1.0.0 --build-number=1
```

**Pandit:**
```bash
flutter build apk --release --target=lib/main_pandit.dart --build-name=1.0.0 --build-number=1
```

## Web Admin Panel

### Run Admin Panel on Web
```bash
./run_admin_web.sh
```

Or manually:
```bash
flutter run -d chrome --target=lib/main_admin.dart
```

The admin panel will open in Chrome browser.

## Entry Points

- **Client App**: `lib/main_client.dart`
- **Pandit App**: `lib/main_pandit.dart`
- **Admin Panel**: `lib/main_admin.dart`
- **Default**: `lib/main.dart`

## Troubleshooting

If you encounter build errors:

1. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Check Android setup:**
   ```bash
   flutter doctor
   ```

3. **Accept Android licenses:**
   ```bash
   flutter doctor --android-licenses
   ```

4. **For web issues:**
   - Ensure Chrome is installed
   - Set CHROME_EXECUTABLE if needed

## Notes

- Android builds require Android SDK and Gradle
- Web builds require Chrome browser
- All builds use the same codebase with different entry points
- Admin panel is optimized for web/desktop use

