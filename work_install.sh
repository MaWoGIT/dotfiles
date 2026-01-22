#!/usr/bin/env bash
# Use for: Work, Restricted Servers, No Root access
info() { echo -e "\033[0;35m[STANDALONE]\033[0m $1"; }

# 1. Setup Local Binaries
BIN_DIR="$HOME/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# 2. Download Portable Binaries (No Install Required)
if ! command -v fzf >/dev/null; then
    info "Downloading fzf binary..."
    curl -L https://github.com/junegunn/fzf/releases/latest/download/fzf-0.58.0-linux_amd64.tar.gz -o /tmp/fzf.tar.gz
    tar -xzf /tmp/fzf.tar.gz -C "$BIN_DIR" && chmod +x "$BIN_DIR/fzf"
fi

if ! command -v eza >/dev/null; then
    info "Downloading eza binary..."
    curl -L https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -o /tmp/eza.tar.gz
    tar -xzf /tmp/eza.tar.gz -C "$BIN_DIR" && chmod +x "$BIN_DIR/eza"
fi

# 3. Local Plugins (Stored inside your .dotfiles folder)
LOCAL_PLUGINS="$HOME/.dotfiles/plugins"
mkdir -p "$LOCAL_PLUGINS"
[ ! -d "$LOCAL_PLUGINS/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$LOCAL_PLUGINS/zsh-syntax-highlighting"

# 4. Manual Link Loop (Mimics Stow without needing the app)
info "Linking files manually..."
cd "$HOME/.dotfiles"
for file in .*; do
    [[ "$file" == "." || "$file" == ".." || "$file" == ".git" || "$file" == "install.sh" || "$file" == "work_install.sh" ]] && continue
    ln -sf "$HOME/.dotfiles/$file" "$HOME/$file"
done

info "Setup complete. Add 'export PATH=\$HOME/bin:\$PATH' to your .zshrc if not present."
