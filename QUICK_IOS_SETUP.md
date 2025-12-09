# Quick iOS Setup Guide

## Current Issue: Code Signing Required

Your iPhone 15 is connected and detected, but the app needs to be signed before it can be installed.

## Solution (Takes 2 minutes):

1. **Xcode should be open now** - If not, open: `ios/Runner.xcworkspace`

2. **In Xcode, follow these exact steps:**
   - Click **"Runner"** (blue icon) in the left sidebar
   - Select **"Runner"** under TARGETS (not PROJECTS)
   - Click the **"Signing & Capabilities"** tab at the top
   - ✅ Check **"Automatically manage signing"**
   - Click the **"Team"** dropdown
   - If you see your Apple ID, select it
   - If not, click **"Add an Account..."** and sign in with your Apple ID
     - A free Apple ID works fine (no paid developer account needed)
   - Once signed in, select your team from the dropdown
   - Xcode will automatically create certificates and provisioning profiles

3. **After signing is configured, run this command:**
   ```bash
   flutter run -d 00008120-001451001101A01E
   ```

## Alternative: Build from Xcode

If you prefer to build directly from Xcode:
1. Select your iPhone from the device dropdown at the top
2. Click the Play button (▶️) or press Cmd+R
3. Xcode will build and install on your iPhone

## Troubleshooting:

- **If you see "iOS 18.5 not installed" error**: This should resolve automatically once you sign in to Xcode. Xcode will download required components.

- **If signing fails**: Make sure Developer Mode is enabled on your iPhone:
  - Settings > Privacy & Security > Developer Mode (toggle ON)

