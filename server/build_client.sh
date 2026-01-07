#!/bin/bash

# Build Android APK for Client App
echo "Building Client Android APK..."
flutter build apk --release --target=lib/main_client.dart --build-name=1.0.0 --build-number=1

# Rename APK to client-specific name
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    mkdir -p build/app/outputs/flutter-apk/client
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/client/vedic-mate-client.apk
    echo "✓ Client APK built successfully!"
    echo "Location: build/app/outputs/flutter-apk/client/vedic-mate-client.apk"
else
    echo "✗ Build failed!"
    exit 1
fi

