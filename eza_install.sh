#!/usr/bin/env bash

# --- HELPER FUNCTIONS ---
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }

# Use sudo only if it exists and we aren't root
if command -v sudo >/dev/null 2>&1 && [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# --- 1. INSTALL CORE TOOLS & EZA REPO ---
info "Setting up eza repository..."
if [ -f /etc/debian_version ]; then
    # Official eza installation for Debian/Ubuntu
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list
    $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    
    $SUDO apt update && $SUDO apt install -y eza
elif [ -f /etc/fedora-release ]; then
    $SUDO dnf install -y eza
fi

info "All done! Eza is now installed and ready to go!"
