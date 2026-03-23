#!/bin/bash

cargo build --release

echo "Installing to /usr/local/bin/rcd"
sudo cp target/release/rcd /usr/local/bin/rcd

CURRENT_SHELL=$(basename "$SHELL")

case "$CURRENT_SHELL" in
    bash)
        CONFIG_FILE="$HOME/.bashrc"
        WRAPPER="rj() { local dir; dir=\$(rcd); [ -n \"\$dir\" ] && cd \"\$dir\"; }"
        ;;
    zsh)
        CONFIG_FILE="$HOME/.zshrc"
        WRAPPER="rj() { local dir; dir=\$(rcd); [ -n \"\$dir\" ] && cd \"\$dir\"; }"
        ;;
    fish)
        CONFIG_FILE="$HOME/.config/fish/config.fish"
        WRAPPER="function rj; set -l dir (rcd); if test -n \"\$dir\"; cd \"\$dir\"; end; end"
        ;;
    *)
        echo "Unsupported shell: $CURRENT_SHELL. Please add the wrapper manually."
        exit 1
        ;;
esac

if ! grep -q "rcd" "$CONFIG_FILE"; then
    echo "Adding rj function to $CONFIG_FILE..."
    echo -e "\n# rcd wrapper\n$WRAPPER" >> "$CONFIG_FILE"
    echo "Please restart your terminal or source your config."
else
    echo "rcd wrapper already exists in $CONFIG_FILE. Skipping."
fi
