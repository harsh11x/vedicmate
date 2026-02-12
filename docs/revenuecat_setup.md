# RevenueCat Dashboard Setup Guide

This guide walks you through configuring RevenueCat for the Vedic Mate app.

## Prerequisites

- RevenueCat account ([sign up here](https://app.revenuecat.com/signup))
- App Store Connect account (iOS) and/or Google Play Console account (Android)
- Products created in App Store Connect/Google Play Console

## Step 1: Create RevenueCat Project

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Click **"Create new project"**
3. Enter project name: **Vedic Mate**
4. Click **"Create"**

## Step 2: Configure iOS App

1. In your project, go to **"Apps"** → **"+ New"**
2. Select **"iOS"**
3. Enter:
   - **App name**: Vedic Mate
   - **Bundle ID**: Your iOS bundle identifier (from Xcode)
4. Click **"Save"**
5. Copy the **iOS API Key** (starts with `appl_`)

## Step 3: Configure Android App

1. Go to **"Apps"** → **"+ New"**
2. Select **"Android"**
3. Enter:
   - **App name**: Vedic Mate
   - **Package name**: Your Android package name (from `build.gradle`)
4. Click **"Save"**
5. Upload your **Google Play Service Account JSON** file
6. Copy the **Android API Key** (starts with `goog_`)

## Step 4: Create Entitlement

Entitlements represent premium features users get access to.

1. Go to **"Entitlements"** → **"+ New"**
2. Enter:
   - **Identifier**: `Vedic Mate Pro`
   - **Description**: Premium features for Vedic Mate
3. Click **"Save"**

## Step 5: Create Products in App Stores

### iOS (App Store Connect)

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Go to **"My Apps"** → Select your app
3. Go to **"In-App Purchases"** → **"+"**
4. Select subscription type (Auto-Renewable Subscription)
5. Create subscription group if needed
6. Create products:
   - **Product ID**: `vedic_mate_pro_monthly` (example)
   - **Reference Name**: Vedic Mate Pro Monthly
   - **Subscription Duration**: 1 month
   - **Price**: Set your price
7. Repeat for other subscription tiers (yearly, etc.)
8. Submit for review

### Android (Google Play Console)

1. Log in to [Google Play Console](https://play.google.com/console/)
2. Select your app
3. Go to **"Monetize"** → **"Products"** → **"Subscriptions"**
4. Click **"Create subscription"**
5. Create products:
   - **Product ID**: `vedic_mate_pro_monthly`
   - **Name**: Vedic Mate Pro Monthly
   - **Description**: Premium features
   - **Billing period**: 1 month
   - **Price**: Set your price
6. Repeat for other subscription tiers
7. Activate subscriptions

### Consumable Product (if needed)

For the "consumable" product mentioned in your requirements:

**iOS:**
- Type: Consumable
- Product ID: `consumable`
- Reference Name: Consumable Credit

**Android:**
- Type: Managed product (one-time purchase)
- Product ID: `consumable`
- Name: Consumable Credit

## Step 6: Link Products to RevenueCat

1. In RevenueCat Dashboard, go to **"Products"** → **"+ New"**
2. For each product:
   - **Identifier**: Use the same as App Store/Play Store (e.g., `vedic_mate_pro_monthly`)
   - **Type**: Select appropriate type (subscription/consumable)
   - **App Store Product ID**: Enter iOS product ID
   - **Play Store Product ID**: Enter Android product ID
3. Click **"Save"**

## Step 7: Create Offering

Offerings group products together for display in your app.

1. Go to **"Offerings"** → **"+ New"**
2. Enter:
   - **Identifier**: `default`
   - **Description**: Default offering
3. Click **"Save"**
4. Add packages to the offering:
   - Click **"+ Add Package"**
   - **Identifier**: `monthly` (or custom)
   - **Product**: Select `vedic_mate_pro_monthly`
   - Click **"Save"**
5. Repeat for other packages (yearly, etc.)
6. Set as **"Current Offering"**

## Step 8: Link Entitlements to Products

1. Go to **"Products"**
2. For each product, click **"Edit"**
3. Under **"Entitlements"**, add `Vedic Mate Pro`
4. Click **"Save"**

This ensures users who purchase any product get the Pro entitlement.

## Step 9: Configure Paywalls (Optional)

RevenueCat provides customizable paywall templates:

1. Go to **"Paywalls"** → **"+ New"**
2. Choose a template
3. Customize:
   - Colors
   - Text
   - Feature list
   - Call-to-action buttons
4. Link to your offering
5. Click **"Save"**

## Step 10: Set Up Customer Center (Optional)

1. Go to **"Customer Center"**
2. Enable **"Customer Center"**
3. Customize:
   - Support email
   - Help center URL
   - Branding
4. Click **"Save"**

## Step 11: Update API Keys in App

Replace the test API key in your app with the production key:

**File**: `lib/services/revenuecat_service.dart`

```dart
// Replace this line:
static const String _apiKey = 'test_dLgiaQtmDSBlSWJpoRBvMyEIbrk';

// With your production key:
static const String _apiKey = 'YOUR_PRODUCTION_API_KEY';
```

**Important**: Use different API keys for iOS and Android, or use the public SDK key that works for both platforms.

## Step 12: Testing

### Sandbox Testing

1. **iOS**: Use sandbox Apple ID
   - Settings → App Store → Sandbox Account
2. **Android**: Use test account in Google Play Console
   - Add test users in Play Console

### Test Purchases

1. Run your app
2. Trigger the paywall
3. Make a test purchase
4. Verify in RevenueCat Dashboard:
   - Go to **"Customers"**
   - Search for your test user
   - Check active entitlements

### Test Restore Purchases

1. Delete and reinstall app
2. Log in with same account
3. Tap **"Restore Purchases"**
4. Verify entitlements are restored

## Step 13: Webhooks (Optional)

Set up webhooks to receive real-time subscription events:

1. Go to **"Integrations"** → **"Webhooks"**
2. Enter your webhook URL
3. Select events to receive:
   - Initial purchase
   - Renewal
   - Cancellation
   - Expiration
4. Click **"Save"**

## Troubleshooting

### Products Not Showing

- Verify product IDs match exactly between App Store/Play Store and RevenueCat
- Ensure products are approved and active in App Store Connect/Play Console
- Check that products are linked to the current offering

### Purchases Not Working

- Verify API keys are correct
- Check that app bundle ID/package name matches
- Ensure test accounts are set up correctly
- Check RevenueCat logs in dashboard

### Entitlements Not Granted

- Verify products are linked to entitlements
- Check that entitlement identifier matches in code: `Vedic Mate Pro`
- Refresh customer info after purchase

## Resources

- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [iOS Subscription Guide](https://developer.apple.com/app-store/subscriptions/)
- [Android Subscription Guide](https://developer.android.com/google/play/billing/subscriptions)
- [RevenueCat Support](https://community.revenuecat.com/)

## Summary

Your RevenueCat setup should include:

- ✅ iOS and Android apps configured
- ✅ Entitlement: `Vedic Mate Pro`
- ✅ Products created in App Store Connect and Google Play Console
- ✅ Products linked to RevenueCat
- ✅ Offering created with packages
- ✅ Products linked to entitlements
- ✅ Paywall configured (optional)
- ✅ Customer Center enabled (optional)
- ✅ Production API key in app
- ✅ Test purchases verified

Once complete, your subscription system is ready for production! 🎉
