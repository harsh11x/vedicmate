#!/bin/bash

# Build and copy APKs to Desktop
DESKTOP_PATH="$HOME/Desktop"
PROJECT_DIR="/Users/harshdev/Documents/Projects/astroapp"

cd "$PROJECT_DIR" || exit

echo "Building Client APK..."
flutter build apk --release --target=lib/main_client.dart --build-name=1.0.0 --build-number=1

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    mkdir -p "$DESKTOP_PATH/VedicMate_APKs"
    cp build/app/outputs/flutter-apk/app-release.apk "$DESKTOP_PATH/VedicMate_APKs/vedic-mate-client.apk"
    echo "✓ Client APK copied to Desktop/VedicMate_APKs/"
else
    echo "✗ Client APK build failed"
fi

echo ""
echo "Building Pandit APK..."
flutter build apk --release --target=lib/main_pandit.dart --build-name=1.0.0 --build-number=1

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    mkdir -p "$DESKTOP_PATH/VedicMate_APKs"
    cp build/app/outputs/flutter-apk/app-release.apk "$DESKTOP_PATH/VedicMate_APKs/vedic-mate-pandit.apk"
    echo "✓ Pandit APK copied to Desktop/VedicMate_APKs/"
else
    echo "✗ Pandit APK build failed"
fi

echo ""
echo "APKs location: $DESKTOP_PATH/VedicMate_APKs/"

