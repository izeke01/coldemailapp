@echo off
echo.
echo ============================================
echo    Firebase Deployment for Cold Email App
echo ============================================
echo.

echo [1/6] Checking Firebase CLI...
firebase --version
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI not found. Please install it first:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)

echo.
echo [2/6] Verifying Firebase login...
firebase whoami
if %errorlevel% neq 0 (
    echo Please login to Firebase...
    firebase login
)

echo.
echo [3/6] Setting project...
firebase use coldemailapp-799e0

echo.
echo [4/6] Cleaning and building Flutter web...
flutter clean
flutter pub get
flutter build web --release

echo.
echo [5/6] Checking build output...
if not exist "build\web\index.html" (
    echo ERROR: Build failed - index.html not found in build\web
    pause
    exit /b 1
)

echo Build successful! Files found in build\web:
dir build\web /b

echo.
echo [6/6] Deploying to Firebase Hosting...
firebase deploy --only hosting

echo.
echo ============================================
echo    Deployment Complete!
echo ============================================
echo.
echo Your app should be live at:
echo https://coldemailapp-799e0.web.app
echo.
pause