# PowerShell Profile - Auto-setup PATH for Flutter Development
# This file runs every time PowerShell starts

# Add required paths if not already present
$pathsToAdd = @(
    "C:\Windows\System32",
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\bin"
)

foreach ($pathToAdd in $pathsToAdd) {
    if ($env:Path -notlike "*$pathToAdd*") {
        $env:Path += ";$pathToAdd"
    }
}

# Display Flutter-ready message
Write-Host "Flutter environment ready!" -ForegroundColor Green
Write-Host "Location: " -NoNewline
Write-Host (Get-Location) -ForegroundColor Cyan
