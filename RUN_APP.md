# Running Your DJ Pro Clone App - Quick Guide

## 🚀 Run in Chrome (Development Mode)

### Step 1: Load Environment Variables
Every time you open a new PowerShell terminal, run this first:

```powershell
. .\profile.ps1
```

### Step 2: Run the App in Chrome

```powershell
flutter run -d chrome
```

Or combine both commands in one line:

```powershell
. .\profile.ps1; flutter run -d chrome
```

---

## 🎯 Flutter Build Modes Explained

### Debug Mode (Default - Best for Development)

**When to use:** During active development when you need hot reload

**Run command:**
```powershell
. .\profile.ps1; flutter run -d chrome
```

**Features:**
- ✅ Hot reload enabled (press `r` to reload changes)
- ✅ Hot restart enabled (press `R` for full restart)
- ✅ Debugging tools available
- ✅ DevTools can connect
- ✅ Fast compilation for quick iterations
- ⚠️ Slower performance
- ⚠️ Larger file size

**Keyboard shortcuts while running:**
- `r` - Hot reload (quick refresh)
- `R` - Hot restart (full restart)
- `h` - Show help
- `q` - Quit app

---

### Profile Mode (For Performance Testing)

**When to use:** When you want to analyze performance and find bottlenecks

**Run command:**
```powershell
. .\profile.ps1; flutter run --profile -d chrome
```

**Features:**
- ✅ Performance profiling enabled
- ✅ DevTools performance overlay available
- ✅ Some debugging enabled
- ⚠️ No hot reload
- ⚠️ Chrome DevTools required for web profiling

**Note:** For web apps, use Chrome DevTools instead of Flutter DevTools for profiling.

---

### Release Mode (For Production Deployment)

**When to use:** When you're ready to deploy your app for users

**Run command:**
```powershell
. .\profile.ps1; flutter run --release -d chrome
```

**Or build for production:**
```powershell
. .\profile.ps1; flutter build web
```

**Features:**
- ✅ Maximum optimization
- ✅ Smallest file size
- ✅ Fastest execution
- ✅ Tree shaking applied (removes unused code)
- ✅ Minified code
- ❌ No debugging
- ❌ No hot reload
- ❌ Assertions disabled

**Production build files:** Located in `build/web/` directory

---

## 📋 Complete Command Reference

### Development (Debug Mode)
```powershell
# Run in Chrome (recommended for web development)
. .\profile.ps1; flutter run -d chrome

# Run in Edge
. .\profile.ps1; flutter run -d edge

# List available devices
. .\profile.ps1; flutter devices
```

### Testing Performance (Profile Mode)
```powershell
# Profile in Chrome
. .\profile.ps1; flutter run --profile -d chrome
```

### Production Build (Release Mode)
```powershell
# Run release mode in Chrome
. .\profile.ps1; flutter run --release -d chrome

# Build for web deployment
. .\profile.ps1; flutter build web

# Build optimized release
. .\profile.ps1; flutter build web --release
```

---

## 🛠️ Other Useful Commands

### Development Tools
```powershell
# Load environment first
. .\profile.ps1

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

### Building for Other Platforms
```powershell
# Build for Windows desktop (requires Visual Studio)
flutter build windows

# Build for Android APK
flutter build apk

# Build for Android App Bundle
flutter build appbundle
```

---

## 🎨 Hot Reload Tips (Debug Mode Only)

While your app is running in **debug mode**, you can:

1. **Edit your code** in `lib/main.dart`
2. **Press `r`** in the terminal
3. **See changes instantly** without restarting!

### Example Hot Reload Workflow:
```powershell
# 1. Start app
. .\profile.ps1; flutter run -d chrome

# 2. Chrome opens with your app

# 3. Edit lib/main.dart (change text, colors, etc.)

# 4. Press 'r' in terminal

# 5. See changes instantly in Chrome!
```

---

## 📦 Build Output Locations

After building, find your compiled files here:

```
build/
├── web/              # Web builds (HTML, JS, assets)
├── windows/          # Windows desktop builds
└── android/          # Android APK/AAB builds
```

---

## ⚡ Quick Start (Copy & Paste)

**For daily development:**
```powershell
. .\profile.ps1; flutter run -d chrome
```

**For performance testing:**
```powershell
. .\profile.ps1; flutter run --profile -d chrome
```

**For production build:**
```powershell
. .\profile.ps1; flutter build web --release
```

---

## 🐛 Troubleshooting

### If you get "Unable to find git in your PATH":
```powershell
. .\profile.ps1
```
(This sets up PATH with Git and System32)

### If Chrome doesn't open:
1. Check Chrome is installed
2. Try Edge instead: `flutter run -d edge`
3. Check available devices: `flutter devices`

### If hot reload doesn't work:
- Only works in **debug mode** (not profile or release)
- Try hot restart: Press `R` instead of `r`
- Or fully restart: Press `q` then run `flutter run` again

### If build fails:
```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 🎯 Recommended Workflow

1. **Development** (most of the time):
   ```powershell
   . .\profile.ps1; flutter run -d chrome
   ```
   - Use hot reload (`r`) for quick changes
   - Use hot restart (`R`) for major changes

2. **Performance Check** (occasionally):
   ```powershell
   . .\profile.ps1; flutter run --profile -d chrome
   ```
   - Open Chrome DevTools (F12)
   - Check Performance tab

3. **Before Deployment**:
   ```powershell
   flutter analyze
   flutter test
   . .\profile.ps1; flutter build web --release
   ```
   - Test the production build
   - Deploy `build/web/` folder to your server

---

## 🛠️ Using Flutter DevTools in VS Code

### What is DevTools?

Flutter DevTools is a suite of performance and debugging tools built specifically for Flutter and Dart applications. It provides:

- **Widget Inspector**: Visualize and explore your Flutter widget tree
- **Performance View**: Profile your app's CPU and GPU usage
- **Memory View**: Track memory allocation and detect leaks
- **Network View**: Monitor HTTP/HTTPS traffic
- **Logging View**: See application logs and events
- **App Size Tool**: Analyze your app's size breakdown

### Prerequisites: Install VS Code Extensions

You need these extensions installed:

- **Dart** (`Dart-Code.dart-code`) - Required
- **Flutter** (`Dart-Code.flutter`) - Required for Flutter debugging

**Install them:**

1. Open Extensions view (`Ctrl+Shift+X`)
2. Search for "Dart" and "Flutter"
3. Click **Install** on both

### Opening DevTools

#### Method 1: Command Palette (Easiest)

1. Start your app with `F5` or `flutter run -d chrome`
2. Press `F1` to open the command palette
3. Type "DevTools" and choose:
   - `Dart: Open DevTools`
   - `Flutter: Open DevTools`
   - `Dart: Open DevTools in Web Browser`

#### Method 2: Status Bar

1. Look for the `{}` icon next to "Dart" in the bottom status bar
2. Click it to see DevTools status
3. Click **Open DevTools** to launch

#### Method 3: Terminal Link

When you run `flutter run`, the terminal shows:

```text
The Flutter DevTools debugger and profiler on Chrome is available at:
http://127.0.0.1:9100?uri=ws://127.0.0.1:12345/abc123/ws
```

`Ctrl+Click` this link to open DevTools in your browser.

### DevTools Display Options

**Embedded in VS Code (Default)**:
DevTools opens as an embedded panel inside VS Code.

**Browser Window**:
To always open DevTools in a browser:

1. Open VS Code Settings (`Ctrl+,`)
2. Search for `dart.embedDevTools`
3. Uncheck the setting

**Column Layout**:
Control where DevTools appears:

1. Open Settings (`Ctrl+,`)
2. Search for `dart.devToolsLocation`
3. Choose:
   - `beside` - Opens in a new column next to your editor
   - `active` - Replaces the current editor tab

### Using DevTools for DJ Pro Clone

#### Performance Profiling (Critical for Audio Apps)

1. Run app in **profile mode**: `flutter run -d chrome --profile`
2. Open DevTools Performance view
3. Record a profile while mixing tracks
4. Look for:
   - Frame rendering time (should stay under 16ms for 60fps)
   - Long synchronous operations blocking UI
   - Excessive widget rebuilds

#### Memory Monitoring (Track Audio Buffer Leaks)

1. Open DevTools Memory view
2. Load and unload tracks
3. Watch for memory not being released
4. Use heap snapshots to find leaks

#### Widget Inspector (Debug UI Layout)

1. Open Widget Inspector
2. Click "Select Widget Mode"
3. Click on any widget in your running app
4. See its properties, size, constraints, and position in tree

### Recommended DevTools Settings

Add these to your VS Code `settings.json`:

```json
{
  "dart.embedDevTools": true,
  "dart.devToolsLocation": "beside",
  "dart.devToolsTheme": "dark",
  "dart.flutterHotReloadOnSave": "always",
  "dart.previewFlutterUiGuides": true,
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false
}
```

### DevTools Best Practices

1. **Use Profile Mode for Performance Testing**: Debug mode has overhead that skews metrics
2. **Record Short Profiles**: 5-10 seconds is usually enough
3. **Monitor Memory During Development**: Catch leaks early
4. **Use Timeline View**: Understand when audio glitches occur relative to UI operations
5. **Network View for Future API Integration**: When you add track metadata APIs

**Learn More**:
- [DevTools Documentation](https://docs.flutter.dev/tools/devtools)
- [VS Code Dart Settings](https://dartcode.org/docs/settings/)
- [Recommended Settings](https://dartcode.org/docs/recommended-settings/)

---

## �📚 Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev/
- **Build Modes Details**: https://docs.flutter.dev/testing/build-modes
- **DevTools**: https://docs.flutter.dev/development/tools/devtools/overview
- **VS Code DevTools Guide**: https://docs.flutter.dev/tools/devtools/vscode
- **Hot Reload**: https://docs.flutter.dev/development/tools/hot-reload

---

## 🎵 Your DJ Pro Clone App

**Main file**: `lib/main.dart`

**Current features**:
- Basic app structure
- Material Design UI
- Provider state management setup
- Audio service foundation
- Crossfader widget
- Waveform painter
- Data models (Track, CuePoint, DeckState)

**Next steps**: Start building DJ features! See `.github/copilot-instructions.md` for architecture guidance.

---

**Happy Coding! 🎚️🎵**
