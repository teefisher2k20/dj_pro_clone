@echo off
REM Fix Flutter PATH issues by adding required system paths

echo Adding Git and System32 to PATH...

REM Add Git to PATH
set PATH=%PATH%;C:\Program Files\Git\cmd
set PATH=%PATH%;C:\Program Files\Git\bin

REM Add Windows System32 (for WHERE command)
set PATH=%PATH%;C:\Windows\System32

REM Verify paths
echo.
echo Checking Git...
git --version

echo.
echo Checking WHERE command...
where git

echo.
echo Running Flutter pub get...
cd /d "%~dp0"
flutter pub get

echo.
echo Done!
pause
