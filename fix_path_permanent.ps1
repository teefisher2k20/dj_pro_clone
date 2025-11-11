# Permanent PATH Fix for Flutter
# Run this PowerShell script as Administrator

Write-Host "Adding required paths to User PATH..." -ForegroundColor Green

# Get current User PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Paths to add
$pathsToAdd = @(
    "C:\Windows\System32",
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\bin"
)

# Add each path if not already present
$modified = $false
foreach ($path in $pathsToAdd) {
    if ($currentPath -notlike "*$path*") {
        Write-Host "Adding: $path" -ForegroundColor Yellow
        $currentPath = $currentPath + ";" + $path
        $modified = $true
    } else {
        Write-Host "Already exists: $path" -ForegroundColor Gray
    }
}

# Save if modified
if ($modified) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    Write-Host "`nPATH updated successfully!" -ForegroundColor Green
    Write-Host "Please restart VS Code or your terminal for changes to take effect." -ForegroundColor Cyan
} else {
    Write-Host "`nAll paths already configured." -ForegroundColor Green
}

Write-Host "`nCurrent session PATH update (temporary)..." -ForegroundColor Green
$env:Path = $env:Path + ";C:\Windows\System32;C:\Program Files\Git\cmd;C:\Program Files\Git\bin"

Write-Host "`nVerifying..." -ForegroundColor Green
Write-Host "Git version: " -NoNewline
git --version
Write-Host "Flutter location: " -NoNewline
where flutter

Write-Host "`nRunning flutter pub get..." -ForegroundColor Green
Set-Location "C:\Users\Terrance\djay_pro_clone"
flutter pub get
