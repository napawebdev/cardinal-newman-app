@echo off
echo Cleaning Flutter build artifacts...
powershell -Command "if (Test-Path 'build') { Remove-Item -Recurse -Force 'build' }"
powershell -Command "if (Test-Path '.dart_tool') { Remove-Item -Recurse -Force '.dart_tool' }"
echo Getting Flutter dependencies...
flutter pub get
echo Build artifacts cleaned and dependencies restored!
pause