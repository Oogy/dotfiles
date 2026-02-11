# Dotfiles

Personal dotfiles with automatic sync daemon for macOS and Linux.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/Oogy/dotfiles/main/install.sh | bash
```

## Features

- **Auto-sync daemon**: Automatically pulls dotfiles from GitHub every 60 seconds
- **Config management**: Syncs `.config/` directory to `~/.config/` while preserving user modifications
- **iTerm2 themes**: Automatically installs color schemes to iTerm2
- **Package installation**: Idempotent brew package management
- **User-agnostic**: Works across different MacBooks with different users
- **Comprehensive logging**: All sync activity logged to `~/Library/Logs/dotfiles-sync.log`

## What Gets Installed

### Packages (macOS)
- Development: `neovim`, `git`, `tmux`, `gh`, `tree`
- Cloud/DevOps: `awscli`, `docker`, `kubectl`
- Security: `mitmproxy`, `zmap`
- Utilities: `wget`, `rsync`, `telnet`

### Applications (macOS)
- **ProFont Nerd Font**: Developer font with icons
- **Claude Code**: AI-powered coding assistant
- **NvChad**: Neovim configuration

### Themes
- **Gruvbox Dark**: iTerm2 color scheme

## Manual Installation

```bash
git clone https://github.com/Oogy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## How It Works

1. `setup.sh` installs packages, syncs configs, and sets up the daemon
2. A launchd daemon runs in the background (macOS)
3. Every 60 seconds, `sync.sh` checks for updates from GitHub
4. If updates are found, they're pulled and `setup.sh` is re-run
5. Your configs stay in sync across all your machines

## Logs

- **Sync log**: `~/Library/Logs/dotfiles-sync.log`
- **Error log**: `~/Library/Logs/dotfiles-sync-error.log`

## Daemon Management

```bash
# Check daemon status
launchctl list | grep dotfiles

# Restart daemon
launchctl unload ~/Library/LaunchAgents/com.tyler.weldon.dotfiles.plist
launchctl load ~/Library/LaunchAgents/com.tyler.weldon.dotfiles.plist

# Watch sync activity
tail -f ~/Library/Logs/dotfiles-sync.log
```

## Repository Structure

```
.
├── .config/              # Synced to ~/.config/
│   └── CLAUDE.md        # Claude Code project settings
├── daemons/
│   └── osx/
│       └── com.tyler.weldon.dotfiles.plist  # LaunchAgent daemon
├── themes/
│   └── iterm2/          # iTerm2 color schemes
│       └── gruvbox-dark.itermcolors
├── install.sh           # One-liner install script
├── setup.sh            # Main setup script
└── sync.sh             # Git sync script (run by daemon)
```

## Customization

- Add your dotfiles to `.config/`
- Add iTerm2 themes to `themes/iterm2/`
- Modify package list in `setup.sh`
- Adjust sync interval in the plist (default: 60 seconds)
