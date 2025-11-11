#!/bin/bash
# Fix Flutter Git issues in Git Bash

echo "Fixing Flutter Git configuration..."

# Add Flutter to Git safe directories
git config --global --add safe.directory C:/tools/flutter
echo "✓ Added C:/tools/flutter to Git safe directories"

# Add other common Flutter directories
git config --global --add safe.directory /c/tools/flutter
echo "✓ Added /c/tools/flutter to Git safe directories"

# Verify Git config
echo ""
echo "Current Git safe directories:"
git config --global --get-all safe.directory

echo ""
echo "Git configuration fixed!"
echo ""
echo "⚠️  Note: Flutter commands still need to run in PowerShell (not Git Bash)"
echo "    because Flutter relies on Windows commands like WHERE.EXE"
echo ""
echo "To run Flutter, use PowerShell terminal with:"
echo "  cd C:\\Users\\Terrance\\djay_pro_clone"
echo "  flutter pub get"
echo "  flutter run"
