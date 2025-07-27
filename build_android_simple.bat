@echo off
echo Simple Android APK Builder
echo ========================
echo.

echo Step 1: Cleaning project...
powershell -Command "if (Test-Path 'build') { Remove-Item -Recurse -Force 'build' }"
echo Done.
echo.

echo Step 2: Getting dependencies...
flutter pub get
echo Done.
echo.

echo Step 3: Attempting to accept Android licenses...
echo This might fail - that's okay, we'll try building anyway.
flutter doctor --android-licenses
echo.

echo Step 4: Building APK (debug version - easier to build)...
flutter build apk --debug
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo SUCCESS! Debug APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo This APK can be installed on Android devices for testing.
    echo Note: This is a debug version. For production, you'll need to fix SDK licensing.
) else (
    echo Build failed. Let's try with different settings...
    echo.
    echo Trying alternative build...
    flutter build apk --debug --no-tree-shake-icons
    echo.
    if exist "build\app\outputs\flutter-apk\app-debug.apk" (
        echo SUCCESS! APK built with alternative settings!
        echo Location: build\app\outputs\flutter-apk\app-debug.apk
    ) else (
        echo Build still failed. You need to fix Android SDK licensing in Android Studio.
        echo.
        echo Please:
        echo 1. Open Android Studio
        echo 2. Go to SDK Manager
        echo 3. Install Android SDK Command-line Tools
        echo 4. Accept all licenses
    )
)

echo.
echo Press any key to exit...
pause