# Claude HUD 📊

**The missing dashboard for Claude Code power users on macOS.**

![App Icon](ClaudeUsageMonitor/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

Claude HUD is a native macOS Menu Bar companion for **Claude Code**. It provides real-time monitoring of your usage quotas, tracks reset times, and allows you to resume your chat sessions with a single click.

## 🚀 Installation

### Option 1: Direct Download (Recommended)
1.  Download the latest **`ClaudeHUD.dmg`** from the [Releases page](https://github.com/nicolaregattieri/claude-hud/releases).
2.  Drag **Claude HUD.app** to your **Applications** folder.
3.  **To Launch:** Right-click the app in your Applications folder and select **Open**.

### Option 2: Install via Terminal
Run this command to download and install the latest version automatically:
```bash
curl -sL https://raw.githubusercontent.com/nicolaregattieri/claude-hud/main/install.sh | bash
```

## ✨ Features

*   **Real-time Monitoring:** Tracks your usage quotas directly from the Anthropic API.
*   **Smart Reset Timer:** Shows exactly when your limits will be renewed.
*   **Project & Chat Management:** Auto-discovery of local projects and one-click session resume.
*   **Native Experience:** Beautiful glassmorphism UI that adapts to Light/Dark mode.

## 🔐 Permissions

The app requires two permissions on the first run:
1.  **Keychain Access:** To read the token created by `claude login`. Click **"Always Allow"**.
2.  **Automation (Terminal):** To resume sessions automatically. Click **OK**.

---

### 🛠️ Development (Build from Source)
Requirements: Xcode 14+
```bash
git clone https://github.com/nicolaregattieri/claude-hud.git
cd claude-hud
./build_dmg.sh
```

## 📄 License
[MIT](LICENSE)

---
**Author:** Nicola Regattieri  
**Built with:** 🤖 Claude & Gemini