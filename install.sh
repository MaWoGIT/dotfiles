#!/usr/bin/env bash

# Colors for better readability
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }

# --- 1. INSTALL DEPENDENCIES ---
info "Installing zsh, stow, and git..."
if [ -f /etc/fedora-release ] || [ -f /etc/nobara-release ]; then
    sudo dnf install -y zsh stow git
elif [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y zsh stow git
fi

# --- 2. ENSURE PURE FILES EXIST ---
# We keep these in the repo so they are available on all machines
PURE_DIR="$HOME/.dotfiles/pure"
if [ ! -d "$PURE_DIR" ]; then
    info "Downloading Pure prompt files..."
    mkdir -p "$PURE_DIR"
    curl -L https://raw.githubusercontent.com/sindresorhus/pure/master/pure.zsh -o "$PURE_DIR/prompt_pure_setup"
    curl -L https://raw.githubusercontent.com/sindresorhus/pure/master/async.zsh -o "$PURE_DIR/async"
fi

# --- 3. DEPLOY CONFIGS WITH STOW ---
info "Linking dotfiles to Home directory..."
cd "$HOME/.dotfiles"
# Backup original .zshrc if it's a real file and not already a link
[ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
stow .

# --- 4. SET ZSH AS DEFAULT ---
info "Setting Zsh as the default shell..."
sudo chsh -s "$(which zsh)" "$USER"

info "Done! Log out and back in to see your clean, Pure-powered shell."
