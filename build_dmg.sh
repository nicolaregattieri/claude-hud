#!/bin/bash

# Claude HUD - Professional Build & Package Script
# Version: 1.1

APP_NAME="Claude HUD"
PROJECT_NAME="ClaudeUsageMonitor"
BUILD_DIR="$(pwd)/build"
STAGING_DIR="/tmp/claude_hud_staging"
FINAL_APP_PATH="$STAGING_DIR/$APP_NAME.app"

echo "🔨 Building $APP_NAME..."

# Go to project directory
cd "$(dirname "$0")"

# Set Xcode path
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# 1. Clean and build
# We disable Hardened Runtime because we are not notarizing with Apple.
# This prevents the "damaged file" error on other machines.
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
  -scheme "$PROJECT_NAME" \
  -configuration Release \
  clean build \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
  ENABLE_HARDENED_RUNTIME=NO \
  2>&1 | grep -E "(error:|warning:|BUILD|ClaudeHUD)"

# Check if build succeeded
if [ ! -d "$BUILD_DIR/$PROJECT_NAME.app" ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build succeeded!"

# 2. Prepare Staging Area
echo "📦 Preparing staging area..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Copy and rename to final name
cp -R "$BUILD_DIR/$PROJECT_NAME.app" "$FINAL_APP_PATH"

# 3. Inject Resources (Icons & Translations)
echo "🎨 Adding icon & translations..."
cp "ClaudeUsageMonitor/Resources/AppIcon.icns" "$FINAL_APP_PATH/Contents/Resources/AppIcon.icns"
cp -R "ClaudeUsageMonitor/Resources/en.lproj" "$FINAL_APP_PATH/Contents/Resources/"
cp -R "ClaudeUsageMonitor/Resources/pt.lproj" "$FINAL_APP_PATH/Contents/Resources/"
cp -R "ClaudeUsageMonitor/Resources/es.lproj" "$FINAL_APP_PATH/Contents/Resources/"

# 4. Clean extended attributes (CRITICAL to avoid "corrupted" error)
# This removes local file metadata that triggers Gatekeeper
echo "🧹 Cleaning extended attributes..."
xattr -cr "$FINAL_APP_PATH"

# 5. Sign the entire bundle deeply
# Using --deep ensures all nested resources are signed
echo "🔏 Signing application..."
codesign --force --deep --sign - "$FINAL_APP_PATH"

# 6. Create DMG
echo "💿 Creating DMG..."
rm -f ~/Desktop/ClaudeHUD.dmg
ln -sf /Applications "$STAGING_DIR/Applications"

hdiutil create -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov -format UDZO \
  ~/Desktop/ClaudeHUD.dmg

echo ""
echo "🎉 SUCCESS! Claude HUD is ready on your Desktop."
echo "To share: Send ClaudeHUD.dmg to anyone."