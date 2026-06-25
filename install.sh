#!/usr/bin/env bash
#Usage: curl -ssL https://raw.githubusercontent.com/MaWoGIT/dotfiles/refs/heads/main/install.sh | bash
set -euo pipefail

# Ensure standard system paths are available so we can find sudo/git
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

info()  { echo -e "\033[0;34m[INFO]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; exit 1; }

# Use sudo only if it exists and we aren't root
if command -v sudo >/dev/null 2>&1 && [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# --- 1. INSTALL CORE DEPENDENCIES (per package manager) ---
if command -v apt >/dev/null 2>&1; then
    info "Debian/Ubuntu detected. Installing core requirements..."
    $SUDO apt update
    $SUDO apt install -y gpg gpg-agent curl git unzip fontconfig

    # Eza is not in the official Debian repos, so add the gierens repo
    info "Setting up eza repository..."
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | $SUDO gpg --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | $SUDO tee /etc/apt/sources.list.d/gierens.list >/dev/null
    $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

    $SUDO apt update
    $SUDO apt install -y vim zsh stow unzip fzf eza

elif command -v dnf >/dev/null 2>&1; then
    info "Fedora/Nobara detected. Installing core requirements..."
    $SUDO dnf install -y zsh stow git curl unzip eza fzf vim fontconfig

else
    error "No supported package manager (apt/dnf) found."
fi

# --- SANITY CHECK ---
command -v gpg >/dev/null 2>&1 || error "gpg failed to install."
command -v git >/dev/null 2>&1 || error "git failed to install."

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

# --- 4. INSTALL NERD FONTS (for icons) ---
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR/JetBrainsMono" ]; then
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR/JetBrainsMono"
    curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o /tmp/font.zip
    unzip -o /tmp/font.zip -d "$FONT_DIR/JetBrainsMono"
    fc-cache -fv > /dev/null
    info "Font installed. You may need to select it in your terminal settings."
fi

# --- 5. DEPLOY WITH STOW ---
info "Linking dotfiles..."
cd "$DOTFILES"

# Back up existing real files (not already-stowed symlinks)
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

stow .

# --- 6. INSTALL LATEST FZF IF PACKAGE VERSION IS TOO OLD (need > 0.48) ---
# Done AFTER stow so the installer doesn't fight with the symlinked .zshrc.
if ! command -v fzf >/dev/null 2>&1 || ! fzf --version | grep -qE "0\.(4[8-9]|[5-9][0-9])|[1-9]\."; then
    info "fzf is outdated or missing. Installing latest from git..."
    [ -d "$HOME/.fzf" ] || git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc

    # Put ~/.fzf/bin first in PATH. --follow-symlinks so we edit the stowed
    # file in place instead of replacing the symlink with a regular file.
    if ! grep -q ".fzf/bin" "$HOME/.zshrc"; then
        info "Adding fzf to PATH in .zshrc..."
        sed -i --follow-symlinks '1i export PATH="$HOME/.fzf/bin:$PATH"' "$HOME/.zshrc"
    fi
fi

# --- 7. SET DEFAULT SHELL ---
info "Changing default shell to Zsh..."
$SUDO chsh -s "$(command -v zsh)" "$(id -un)"

info "All done! Run 'exec zsh' or log out/in to finish."
