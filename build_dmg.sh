#!/bin/bash

echo "🔨 Building ClaudeUsageMonitor..."

# Go to project directory
cd "$(dirname "$0")"

# Set Xcode path
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# Clean and build
xcodebuild -project ClaudeUsageMonitor.xcodeproj \
  -scheme ClaudeUsageMonitor \
  -configuration Release \
  clean build \
  CONFIGURATION_BUILD_DIR="$(pwd)/build" \
  2>&1 | grep -E "(error:|warning:|BUILD|ClaudeUsageMonitor\.app)"

# Check if build succeeded
if [ ! -d "build/ClaudeUsageMonitor.app" ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build succeeded!"

# Copy icon to app bundle
echo "🎨 Adding icon..."
cp "ClaudeUsageMonitor/Resources/AppIcon.icns" "build/ClaudeUsageMonitor.app/Contents/Resources/AppIcon.icns"

# Manually copy localization files (since they aren't in project.pbxproj)
echo "🌍 Adding translations..."
cp -R "ClaudeUsageMonitor/Resources/en.lproj" "build/ClaudeUsageMonitor.app/Contents/Resources/"
cp -R "ClaudeUsageMonitor/Resources/pt.lproj" "build/ClaudeUsageMonitor.app/Contents/Resources/"
cp -R "ClaudeUsageMonitor/Resources/es.lproj" "build/ClaudeUsageMonitor.app/Contents/Resources/"

# Re-sign the app after modifications
codesign --force --sign - "build/ClaudeUsageMonitor.app" 2>/dev/null

# Remove old DMG if exists
rm -f ~/Desktop/ClaudeUsageMonitor.dmg

# Create DMG
echo "📦 Creating DMG..."
mkdir -p /tmp/dmg_staging
rm -rf /tmp/dmg_staging/*

# Copy and rename to "Claude HUD.app"
cp -R "build/ClaudeUsageMonitor.app" "/tmp/dmg_staging/Claude HUD.app"
ln -sf /Applications /tmp/dmg_staging/Applications

hdiutil create -volname "Claude HUD" \
  -srcfolder /tmp/dmg_staging \
  -ov -format UDZO \
  ~/Desktop/ClaudeHUD.dmg

echo ""
echo "🎉 Done! DMG created at: ~/Desktop/ClaudeHUD.dmg"
echo ""
echo "To install: Open DMG → Drag app to Applications"
