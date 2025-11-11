# Complete Flutter Setup Fix
# Run this in PowerShell

Write-Host "=== Flutter Setup Fix ===" -ForegroundColor Cyan
Write-Host ""

# Fix 1: Add Git safe directory
Write-Host "1. Fixing Git safe directory..." -ForegroundColor Yellow
git config --global --add safe.directory C:/tools/flutter
Write-Host "   ✓ Added Flutter to Git safe directories" -ForegroundColor Green

# Fix 2: Update PATH for current session
Write-Host ""
Write-Host "2. Updating PATH for current session..." -ForegroundColor Yellow
$env:Path = $env:Path + ";C:\Windows\System32;C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
Write-Host "   ✓ Added required paths to current session" -ForegroundColor Green

# Verify Flutter
Write-Host ""
Write-Host "3. Verifying Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   ✓ Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Flutter check failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
}

# Verify Git
Write-Host ""
Write-Host "4. Verifying Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "   ✓ Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Git check failed" -ForegroundColor Red
}

# Run flutter pub get
Write-Host ""
Write-Host "5. Running flutter pub get..." -ForegroundColor Yellow
Set-Location "C:\Users\Terrance\djay_pro_clone"
flutter pub get

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now run:" -ForegroundColor Green
Write-Host "  flutter run              # Run the app" -ForegroundColor White
Write-Host "  flutter test             # Run tests" -ForegroundColor White
Write-Host "  flutter doctor           # Check setup" -ForegroundColor White
Write-Host ""
Write-Host "Note: Always use PowerShell (not Git Bash) for Flutter commands" -ForegroundColor Yellow
