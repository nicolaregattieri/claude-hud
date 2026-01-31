# Claude HUD 📊

**The missing dashboard for Claude Code power users on macOS.**

![App Icon](ClaudeUsageMonitor/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

Claude HUD is a native macOS Menu Bar companion for **Claude Code**. It provides real-time monitoring of your usage quotas, tracks reset times, and allows you to resume your chat sessions with a single click.

## ✨ Features

*   **Real-time Monitoring:** Tracks your usage quotas (Session, Weekly, Sonnet/Opus limits) directly from the Anthropic API.
*   **Smart Reset Timer:** Shows exactly when your message limits will be renewed.
*   **Project & Chat Management:**
    *   **Auto-discovery:** Automatically finds your projects in `~/.claude/projects`.
    *   **One-Click Resume:** Instantly opens Terminal and resumes any session (`claude --resume <id>`).
*   **Native Experience:**
    *   **Modern Liquid UI:** Beautiful glassmorphism design that adapts to Light/Dark mode.
    *   **Drill-down Navigation:** iPhone-style navigation for Settings, Projects, and Chats to save space.
*   **Resilience:** Features a "Session Inactive" screen with a quick reconnect button for when your token expires.

## 🚀 Installation

### Prerequisites
You must have the official **Claude Code CLI** installed and authenticated:
```bash
npm install -g @anthropic-ai/claude-code
claude login
```

### Download & Install
1.  Download the latest `ClaudeHUD.dmg` from the [Releases page](#).
2.  Drag **Claude HUD.app** to your **Applications** folder.
3.  **Important (First Run):** Since the app is self-signed, you might see a security warning.
    *   **Right-click** the app -> Select **Open** -> Click **Open** in the dialog.

## 🔐 Permissions

The app requires two permissions on the first run to function correctly:

1.  **Keychain Access:** Used to read the authentication token created by `claude login`. Click **"Always Allow"** to avoid repeated prompts.
2.  **Automation (Terminal):** Used to open new Terminal windows and resume sessions. Click **OK** when prompted.

## 🛠️ Building from Source
Requirements: Xcode 14+
```bash
git clone https://github.com/nicolaregattieri/claude-hud.git
cd claude-hud
./ClaudeUsageMonitor/build_dmg.sh
```

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---
**Author:** Nicola Regattieri  
**Built with:** 🤖 Claude & Gemini
