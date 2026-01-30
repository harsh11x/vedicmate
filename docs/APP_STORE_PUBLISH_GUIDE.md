# VedicMate — App Store Publishing Guide

Your app is configured with:
- **Bundle ID:** `com.vedicmate.app`
- **Display Name:** Vedicmate
- **Version:** 1.0.0 (build 15)
- **Team:** X4686N7YKN

---

## 1. Prerequisites

- [ ] **Apple Developer Program** ($99/year) — [developer.apple.com](https://developer.apple.com/programs/)
- [ ] **Xcode** (latest from Mac App Store)
- [ ] **App Store Connect** access for your Apple ID
- [ ] **Valid signing certificate** (your project already has `DEVELOPMENT_TEAM = X4686N7YKN`)

---

## 2. App Store Connect Setup

### Create the app listing (if not already done)

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** VedicMate (or Vedicmate)
   - **Primary Language:** English
   - **Bundle ID:** `com.vedicmate.app` (must match exactly)
   - **SKU:** e.g. `vedicmate-ios-001`
   - **User Access:** Full Access

---

## 3. Prepare for Archive & Upload

### 3.1 Clean and build release

```bash
cd /Users/harshdev/Documents/Projects/astroapp
flutter clean
flutter pub get
flutter build ios --release
```

### 3.2 Open in Xcode and archive

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Product → Destination → Any iOS Device (arm64)**
2. **Product → Archive**
3. When the Organizer opens, select the archive → **Distribute App**
4. Choose **App Store Connect** → **Upload**
5. Use default options (upload symbols, manage version/build automatically)
6. Sign with your distribution certificate
7. Wait for upload to finish

---

## 4. App Store Connect — What You Need Before Submit

| Item | Where / Notes |
|------|----------------|
| **App icon** | 1024×1024 px, no transparency, no rounded corners |
| **Screenshots** | At least one per required device size (6.5", 6.7", 5.5") |
| **App description** | Up to 4000 characters |
| **Keywords** | Up to 100 characters, comma-separated |
| **Support URL** | Your website or support page |
| **Privacy Policy URL** | Required for apps with auth, analytics, etc. |
| **Category** | e.g. Lifestyle, Health & Fitness, or Reference |
| **Age rating** | Complete the questionnaire |
| **Export compliance** | Usually "No" unless using encryption beyond HTTPS |
| **Content rights** | Confirm you have rights to all content |
| **Advertising identifier** | If using ads, specify usage |

---

## 5. Info.plist and Permissions

Your app uses:
- Microphone (AI Pandits voice)
- Speech recognition
- Photo library
- Camera

Ensure each has a clear `NSUsageDescription` in `Info.plist` (you already have these).

---

## 6. Security: NSAppTransportSecurity

Your `Info.plist` has `NSAllowsArbitraryLoads: true`, which Apple may flag. Consider:
- Restricting to your domains only
- Or removing if all APIs use HTTPS

---

## 7. Build IPA Manually (alternative to Xcode archive)

```bash
flutter build ipa
```

Then upload the generated `.ipa` via Transporter or Xcode Organizer.

---

## 8. Common Rejection Reasons to Avoid

1. **Privacy policy missing** — Add a URL if you collect user data.
2. **Login required** — Provide demo credentials if login is mandatory.
3. **Crashes** — Test on real devices before submit.
4. **Permissions** — Match usage to descriptions.
5. **Incomplete metadata** — All required fields must be filled.

---

## 9. Submit for Review

1. In App Store Connect → **App Store** tab
2. Fill all required metadata and media
3. Under **Build**, select the build you uploaded
4. Add **What’s New in This Version**
5. **Add for Review** → **Submit to App Review**

Review typically takes 24–48 hours.

---

## 10. Quick Commands Reference

| Task | Command |
|------|---------|
| Run on 6.5" simulator | `flutter run -d "iPhone 17 Pro Max"` |
| Build release iOS | `flutter build ios --release` |
| Build IPA | `flutter build ipa` |
| List devices | `flutter devices` |

---

**Next step:** Run `flutter build ios --release` and open `ios/Runner.xcworkspace` in Xcode to archive and upload.
