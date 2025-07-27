@echo off
echo Building Android APK...
echo.
echo Cleaning project...
powershell -Command "if (Test-Path 'build') { Remove-Item -Recurse -Force 'build' }"
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Building APK (this may take a few minutes)...
flutter build apk --release
echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo SUCCESS! APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can install this APK on your Android device.
) else (
    echo Build failed. Check the output above for errors.
)
echo.
pause