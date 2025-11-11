# Quick Start Guide - PowerShell Terminal Setup

## ✅ VS Code Configuration Complete!

I've configured VS Code to:
1. ✅ Use **PowerShell as default terminal** (required for Flutter)
2. ✅ Added Flutter/Dart settings for optimal development
3. ✅ Configured auto-format on save
4. ✅ Recommended Flutter extensions

## 🚀 Next Steps

### 1. Restart VS Code
Close and reopen VS Code for settings to take effect.

### 2. Install Recommended Extensions
When VS Code reopens, you'll see a notification to install recommended extensions:
- **Dart** (Dart-Code.dart-code)
- **Flutter** (Dart-Code.flutter)

Click "Install All" or install manually:
```
Ctrl+Shift+X → Search "Dart" → Install
Ctrl+Shift+X → Search "Flutter" → Install
```

### 3. Open PowerShell Terminal
Press `` Ctrl+` `` (backtick) to open terminal - it will now be PowerShell by default!

### 4. Run Setup Script
In the PowerShell terminal:
```powershell
.\flutter_setup_complete.ps1
```

This will:
- Fix Git safe directory
- Update PATH
- Run `flutter pub get`
- Verify everything works

### 5. Run Your App
```powershell
flutter run
```

Or for specific device:
```powershell
flutter devices              # List available devices
flutter run -d windows       # Run on Windows
flutter run -d chrome        # Run in Chrome
flutter run -d <device-id>   # Run on specific device
```

## 📋 Common Commands (PowerShell Only)

```powershell
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Check setup
flutter doctor

# Analyze code
flutter analyze

# Format code
dart format .

# Build release
flutter build windows       # Windows desktop
flutter build apk          # Android APK
flutter build ios          # iOS (requires macOS)
```

## 🔄 Switching Between Terminals

Click the dropdown arrow next to "+" in the terminal panel:
- **PowerShell** ← Use this for Flutter commands
- **Git Bash** ← Use this for Git operations only

## ⚙️ VS Code Keyboard Shortcuts

```
Ctrl+`          - Toggle terminal
Ctrl+Shift+`    - New terminal
Ctrl+Shift+P    - Command palette
F5              - Start debugging
Shift+F5        - Stop debugging
Ctrl+Shift+D    - Debug view
```

## 🛠️ Troubleshooting

### If Flutter commands still fail:
1. Close all terminals
2. Close VS Code completely
3. Reopen VS Code
4. Open PowerShell terminal
5. Run: `.\flutter_setup_complete.ps1`

### If Git safe directory error appears:
```powershell
git config --global --add safe.directory C:/tools/flutter
```

### Check Flutter installation:
```powershell
flutter doctor -v
```

## 📁 Project Files Created

Configuration files:
- `.vscode/settings.json` - VS Code workspace settings
- `.vscode/extensions.json` - Recommended extensions

Helper scripts:
- `flutter_setup_complete.ps1` - Complete setup script
- `fix_path_permanent.ps1` - Permanent PATH fix
- `fix_flutter_git.sh` - Git configuration fix

## 🎯 You're Ready!

Your development environment is now configured for Flutter development with PowerShell as the default terminal. 

Run `.\flutter_setup_complete.ps1` in PowerShell to complete the setup and start coding! 🚀
