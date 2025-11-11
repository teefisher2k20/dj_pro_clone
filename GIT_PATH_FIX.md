# Git PATH Fix for Flutter

## Problem
Flutter cannot find Git in your Windows PATH, causing the error:
```
'WHERE' is not recognized as an internal or external command.
Error: Unable to find git in your PATH.
```

## Solution 1: Add Git to Windows System PATH (Recommended)

### Step 1: Find Git Installation Location

Git is likely installed at one of these locations:
- `C:\Program Files\Git\cmd`
- `C:\Program Files (x86)\Git\cmd`
- `C:\Users\Terrance\AppData\Local\Programs\Git\cmd`

### Step 2: Add Git to Windows PATH

1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables" (or "User variables"), find "Path"
5. Click "Edit"
6. Click "New"
7. Add one of these paths (check which exists):
   ```
   C:\Program Files\Git\cmd
   C:\Program Files\Git\bin
   ```
8. Click "OK" on all dialogs
9. **Restart your terminal/VS Code**

### Step 3: Verify Git is in PATH

Open a NEW PowerShell window and run:
```powershell
git --version
```

You should see: `git version x.x.x`

### Step 4: Run Flutter Commands

```powershell
cd C:\Users\Terrance\djay_pro_clone
flutter pub get
flutter doctor
```

---

## Solution 2: Use Git Bash Terminal (Quick Fix)

Instead of using PowerShell, use Git Bash in VS Code:

1. In VS Code, press `` Ctrl + ` `` to open terminal
2. Click the dropdown arrow next to "+" 
3. Select "Git Bash"
4. Run Flutter commands in Git Bash:
   ```bash
   flutter pub get
   flutter run
   ```

---

## Solution 3: Reinstall Git with PATH Option

If Git isn't properly installed:

1. Download Git from: https://git-scm.com/download/win
2. Run the installer
3. **Important**: When asked "Adjusting your PATH environment", select:
   - ✅ "Git from the command line and also from 3rd-party software"
4. Complete installation
5. Restart terminal/VS Code

---

## Verify Everything Works

After fixing PATH, run:

```powershell
# Check Git
git --version

# Check Flutter
flutter --version

# Get dependencies
cd C:\Users\Terrance\djay_pro_clone
flutter pub get

# Check Flutter setup
flutter doctor
```

---

## Current Status

- ✅ Git is installed (version 2.48.1)
- ✅ Git works in Git Bash
- ❌ Git not in Windows PATH (PowerShell can't find it)
- ❌ Flutter can't run because it needs Git

**Action Required**: Follow Solution 1 to add Git to your Windows PATH permanently.
