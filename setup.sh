#!/usr/bin/env bash

set -e

# Detect operating system
if [[ "$(uname -s)" == "Darwin" ]]; then
    export OS="macOS"
elif [[ "$(uname -s)" == "Linux" ]]; then
    export OS="Linux"
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sync .config directory from repo to home
sync_config() {
    echo "Syncing .config directory..."

    local repo_config="$DOTFILES_DIR/.config"
    local home_config="$HOME/.config"

    # Create ~/.config if it doesn't exist
    mkdir -p "$home_config"

    # Use rsync if available, otherwise fall back to cp
    if command -v rsync &> /dev/null; then
        # rsync flags:
        # -r: recursive
        # -v: verbose
        # -u: update only (skip files that are newer in destination)
        # This will:
        # - Copy new files from repo
        # - Update files if repo version is newer
        # - Skip files if ~/.config version is newer (user modifications)
        # - Leave files not in repo untouched
        rsync -rvu "$repo_config/" "$home_config/"
    else
        # Fall back to cp if rsync not available
        # -R: recursive
        # -n: no-clobber (don't overwrite existing files)
        echo "Warning: rsync not available, using cp (won't update existing files)"
        cp -Rn "$repo_config/." "$home_config/"
    fi

    echo ".config sync complete"
}

# Sync iTerm2 themes to Application Support
sync_iterm2_themes() {
    echo "Syncing iTerm2 themes..."

    local repo_themes="$DOTFILES_DIR/themes/iterm2"
    local iterm2_presets="$HOME/Library/Application Support/iTerm2/ColorPresets"

    # Check if themes directory exists in repo
    if [ ! -d "$repo_themes" ]; then
        echo "No iTerm2 themes found in repo, skipping"
        return
    fi

    # Create iTerm2 ColorPresets directory if it doesn't exist
    mkdir -p "$iterm2_presets"

    # Sync .itermcolors files
    if command -v rsync &> /dev/null; then
        rsync -rvu --include="*.itermcolors" --exclude="*" "$repo_themes/" "$iterm2_presets/"
    else
        find "$repo_themes" -name "*.itermcolors" -exec cp -n {} "$iterm2_presets/" \;
    fi

    echo "iTerm2 themes sync complete"
    echo "Themes installed to: $iterm2_presets"
}

# Check if required dependencies are installed
check_deps() {
    local missing_deps=()

    if [[ "$OS" == "macOS" ]]; then
        if ! command -v brew &> /dev/null; then
            missing_deps+=("homebrew")
        fi
    fi

    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Install packages on macOS
install_macOS_packages() {
    echo "Installing packages on macOS..."

    local packages=(
        wget
        neovim
        git
        tmux
        rsync
        awscli
        docker
        kubectl
        mitmproxy
        gh
        tree
        zmap
        telnet
    )

    for package in "${packages[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            echo "Installing $package..."
            brew install "$package"
        else
            echo "$package already installed"
        fi
    done

    # Install casks
    local casks=(
        font-profont-nerd-font
        claude-code
    )

    for cask in "${casks[@]}"; do
        if ! brew list --cask "$cask" &>/dev/null; then
            echo "Installing $cask..."
            brew install --cask "$cask"
        else
            echo "$cask already installed"
        fi
    done

    # Install NvChad if not present
    if [ ! -d ~/.config/nvim ]; then
        echo "Installing NvChad..."
        git clone https://github.com/NvChad/starter ~/.config/nvim
    else
        echo "NvChad already installed"
    fi
}

# Install dotfiles sync daemon on macOS
install_macOS_daemon() {
    echo "Installing dotfiles sync daemon..."

    local plist_template="$DOTFILES_DIR/daemons/osx/com.tyler.weldon.dotfiles.plist"
    local plist_dest="$HOME/Library/LaunchAgents/com.tyler.weldon.dotfiles.plist"

    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$HOME/Library/LaunchAgents"

    # Create logs directory
    mkdir -p "$HOME/Library/Logs"

    # Replace placeholders in plist and install
    sed -e "s|DOTFILES_DIR|$DOTFILES_DIR|g" \
        -e "s|HOME|$HOME|g" \
        "$plist_template" > "$plist_dest"

    # Unload existing daemon if running
    if launchctl list | grep -q com.tyler.weldon.dotfiles; then
        echo "Unloading existing daemon..."
        launchctl unload "$plist_dest" 2>/dev/null || true
    fi

    # Load the daemon
    echo "Loading daemon..."
    launchctl load "$plist_dest"

    echo "Daemon installed and started"
    echo "Logs: $HOME/Library/Logs/dotfiles-sync.log"
    echo "Errors: $HOME/Library/Logs/dotfiles-sync-error.log"
}

# Main installation function for macOS
install_macOS() {
    local mode="${1:-full}"
    echo "Setting up dotfiles on macOS (mode: $mode)..."

    if ! check_deps; then
        echo "Please install missing dependencies first"
        exit 1
    fi

    sync_config
    sync_iterm2_themes

    # Only install packages and daemon during full setup, not during sync
    if [ "$mode" = "full" ]; then
        install_macOS_packages
        install_macOS_daemon

        # Check for SSO_PROFILE_NAME in .zshrc
        if [ -f ~/.zshrc ] && ! grep -q SSO_PROFILE_NAME ~/.zshrc; then
            echo "WARNING: SSO_PROFILE_NAME not found in ~/.zshrc"
        fi
    fi

    echo "macOS setup complete!"
}

# Placeholder for Linux installation
install_Linux() {
    echo "Linux installation not yet implemented"
}

# Main function
main() {
    local mode="${1:-full}"
    echo "Dotfiles setup for $OS"
    install_${OS} "$mode"
}

main "$@"
