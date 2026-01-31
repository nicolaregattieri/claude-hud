#!/bin/bash

# Claude HUD - Auto Installer
set -e

REPO="nicolaregattieri/claude-hud"
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    echo "❌ Could not find latest release. Please check https://github.com/$REPO/releases"
    exit 1
fi

DMG_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/ClaudeHUD.dmg"
TEMP_DMG="/tmp/ClaudeHUD.dmg"

echo "📥 Downloading Claude HUD $LATEST_RELEASE..."
curl -L -o "$TEMP_DMG" "$DMG_URL"

echo "📦 Mounting volume..."
hdiutil attach "$TEMP_DMG" -quiet

echo "🚚 Installing to Applications..."
cp -R "/Volumes/Claude HUD/Claude HUD.app" /Applications/

echo "🧼 Cleaning up..."
hdiutil detach "/Volumes/Claude HUD" -quiet
rm "$TEMP_DMG"

echo "✅ Claude HUD installed successfully!"
echo "🚀 You can now find it in your Applications folder."
echo "💡 Tip: Right-click -> Open for the first launch."
