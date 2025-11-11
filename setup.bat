@echo off
REM Quick Flutter Setup - Run this in Command Prompt or PowerShell

echo.
echo ===============================================
echo    Flutter Setup - DJ Pro Clone
echo ===============================================
echo.

REM Add Git safe directory
echo [1/4] Fixing Git safe directory...
git config --global --add safe.directory C:/tools/flutter
echo       Done!

REM Update PATH for current session
echo.
echo [2/4] Setting up PATH...
set PATH=%PATH%;C:\Windows\System32;C:\Program Files\Git\cmd;C:\Program Files\Git\bin
echo       Done!

REM Navigate to project directory
cd /d "%~dp0"

REM Verify Flutter
echo.
echo [3/4] Verifying Flutter...
flutter --version
if errorlevel 1 (
    echo       ERROR: Flutter not found!
    pause
    exit /b 1
)
echo       Done!

REM Run flutter pub get
echo.
echo [4/4] Getting Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo       ERROR: flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo ===============================================
echo    Setup Complete! Ready to run:
echo    flutter run -d windows
echo ===============================================
echo.
pause
