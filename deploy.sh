#!/bin/bash

echo ""
echo "============================================"
echo "   Firebase Deployment for Cold Email App"
echo "============================================"
echo ""

# Check Firebase CLI
echo "[1/6] Checking Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo "ERROR: Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

firebase --version

# Check login
echo ""
echo "[2/6] Verifying Firebase login..."
if ! firebase whoami &> /dev/null; then
    echo "Please login to Firebase..."
    firebase login
fi

# Set project
echo ""
echo "[3/6] Setting project..."
firebase use coldemailapp-799e0

# Build
echo ""
echo "[4/6] Cleaning and building Flutter web..."
flutter clean
flutter pub get
flutter build web --release

# Check build
echo ""
echo "[5/6] Checking build output..."
if [ ! -f "build/web/index.html" ]; then
    echo "ERROR: Build failed - index.html not found in build/web"
    exit 1
fi

echo "Build successful! Files found in build/web:"
ls -la build/web/

# Deploy
echo ""
echo "[6/6] Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo ""
echo "============================================"
echo "   Deployment Complete!"
echo "============================================"
echo ""
echo "Your app should be live at:"
echo "https://coldemailapp-799e0.web.app"
echo ""