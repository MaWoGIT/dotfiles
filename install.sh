#!/usr/bin/env bash

# --- Info Function for output
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }

# Use sudo only if it exists and we aren't root
if command -v sudo >/dev/null 2>&1 && [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# --- 1. INSTALL CORE DEPENDENCIES ---
info "Installing zsh, stow, git, unzip, fzf, eza ,vim and curl..."
if [ -f /etc/debian_version ]; then
    # Eza is not in the official repos for Debian so we have to add a new one
    info "Setting up eza repository..."
    $SUDO apt update && $SUDO apt install -y gpg gpg-agent curl
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list
    $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    
    $SUDO apt update && $SUDO apt install -y vim git zsh stow unzip fzf eza
elif [ -f /etc/fedora-release ]; then
    $SUDO dnf install -y zsh stow git curl unzip eza fzf vim
fi
# Check Version of fzf we need > 0.48
if ! fzf --version | grep -qE "0\.(4[8-9]|[5-9])"; then
    info "fzf is outdated or missing. Installing latest..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
fi

# --- 2. INSTALL ZSH PLUGINS ---
PLUGIN_DIR="/usr/share"
info "Installing Zsh plugins..."
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    $SUDO git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
fi
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    $SUDO git clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
fi

# --- 3. CLONE REPO IF MISSING ---
DOTFILES="$HOME/.dotfiles"
if [ ! -d "$DOTFILES" ]; then
    info "Cloning dotfiles repository..."
    git clone https://github.com/MaWoGIT/dotfiles.git "$DOTFILES"
fi

# --- 4. INSTALL NERD FONTS (For Icons) ---
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

# --- 5. DEPLOY WITH STOW ---
info "Linking dotfiles..."
cd "$DOTFILES"
# Backup existing .zshrc and .vimrc
[ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
[ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ] && mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
stow .

# This ensures $HOME/.fzf/bin is at the START of your PATH in .zshrc
if ! grep -q ".fzf/bin" "$HOME/.zshrc"; then
    info "Adding fzf to PATH in .zshrc..."
    # [cite_start]Use sed to insert the PATH export at the very top of the file [cite: 5]
    sed -i '1i export PATH="$HOME/.fzf/bin:$PATH"' "$HOME/.zshrc"
fi
# --- 6. SET DEFAULT SHELL ---
info "Changing default shell to Zsh..."
$SUDO chsh -s "$(which zsh)" "$USER"

info "All done! Run 'exec zsh' or log out/in to finish."
