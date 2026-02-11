#!/usr/bin/env bash

# Dotfiles sync script
# This script pulls the latest changes from the git repository

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/Library/Logs/dotfiles-sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

cd "$DOTFILES_DIR"

# Check if we're in a git repository
if [ ! -d .git ]; then
    log "ERROR: Not a git repository"
    exit 1
fi

# Check if there are any commits in the repository
if ! git rev-parse HEAD &>/dev/null; then
    log "No commits yet in repository, skipping sync"
    exit 0
fi

# Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if upstream is configured
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
    log "No upstream branch configured for $CURRENT_BRANCH, skipping sync"
    exit 0
fi

# Fetch latest changes
log "Fetching latest changes..."
if ! git fetch origin 2>&1 | tee -a "$LOG_FILE"; then
    log "ERROR: Failed to fetch from origin"
    exit 1
fi

# Check if there are any changes
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date"
    exit 0
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    log "WARNING: Uncommitted changes detected, skipping pull"
    exit 0
fi

# Pull changes
log "Pulling changes..."
if git pull --rebase origin "$CURRENT_BRANCH" 2>&1 | tee -a "$LOG_FILE"; then
    log "Successfully pulled changes"

    # Run setup.sh if it exists and is executable
    if [ -x "$DOTFILES_DIR/setup.sh" ]; then
        log "Running setup.sh..."
        "$DOTFILES_DIR/setup.sh" 2>&1 | tee -a "$LOG_FILE"
    fi
else
    log "ERROR: Failed to pull changes"
    exit 1
fi
