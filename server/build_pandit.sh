#!/bin/bash

# Build Android APK for Pandit App
echo "Building Pandit Android APK..."
flutter build apk --release --target=lib/main_pandit.dart --build-name=1.0.0 --build-number=1

# Rename APK to pandit-specific name
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    mkdir -p build/app/outputs/flutter-apk/pandit
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/pandit/vedic-mate-pandit.apk
    echo "✓ Pandit APK built successfully!"
    echo "Location: build/app/outputs/flutter-apk/pandit/vedic-mate-pandit.apk"
else
    echo "✗ Build failed!"
    exit 1
fi

