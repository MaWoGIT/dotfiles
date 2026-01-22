#!/usr/bin/env bash

# --- HELPER FUNCTIONS ---
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }

# Use sudo only if it exists and we aren't root
if command -v sudo >/dev/null 2>&1 && [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# --- 1. INSTALL CORE DEPENDENCIES ---
info "Installing zsh, stow, git, and curl..."
if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    $SUDO apt update && $SUDO apt install -y zsh stow git curl
elif [ -f /etc/fedora-release ] || [ -f /etc/nobara-release ]; then
    $SUDO dnf install -y zsh stow git curl
fi

# --- 2. CLONE REPO IF MISSING ---
DOTFILES="$HOME/.dotfiles"
if [ ! -d "$DOTFILES" ]; then
    info "Cloning dotfiles repository..."
    git clone https://github.com/MaWoGIT/dotfiles.git "$DOTFILES"
fi

# --- 3. INSTALL NERD FONTS (For Icons) ---
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR/JetBrainsMono" ]; then
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR/JetBrainsMono"
    # Download the font zip
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/font.zip
    # Unzip to font directory (requires 'unzip' package)
    $SUDO apt install -y unzip || $SUDO dnf install -y unzip
    unzip -o /tmp/font.zip -d "$FONT_DIR/JetBrainsMono"
    # Update font cache
    fc-cache -fv > /dev/null
    info "Font installed. You may need to select it in your terminal settings."
fi

# --- 4. DEPLOY WITH STOW ---
info "Linking dotfiles..."
cd "$DOTFILES"
# Backup existing .zshrc
[ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
stow .

# --- 5. SET DEFAULT SHELL ---
info "Changing default shell to Zsh..."
$SUDO chsh -s "$(which zsh)" "$USER"

info "All done! Run 'exec zsh' or log out/in to finish."
