#!/bin/bash

# Script to help set up iOS code signing

echo "Setting up iOS code signing for VedicMate app..."
echo ""
echo "STEP 1: Open Xcode"
open -a Xcode /Users/harshdev/Documents/Projects/astroapp/ios/Runner.xcworkspace

echo ""
echo "STEP 2: In Xcode, follow these steps:"
echo "   1. Click 'Runner' (blue project icon) in the left sidebar"
echo "   2. Select the 'Runner' target under TARGETS"
echo "   3. Click the 'Signing & Capabilities' tab"
echo "   4. Check 'Automatically manage signing'"
echo "   5. Click 'Team' dropdown and select 'Add an Account...'"
echo "   6. Sign in with your Apple ID (free account works)"
echo "   7. Once signed in, select your team from the dropdown"
echo ""
echo "STEP 3: After signing is configured, press Enter here to continue building..."
read -p "Press Enter after you've completed the signing setup in Xcode..."

echo ""
echo "Building and installing app on your iPhone..."
cd /Users/harshdev/Documents/Projects/astroapp
flutter run -d 00008120-001451001101A01E

