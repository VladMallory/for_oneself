#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local"
GO_DIR="$INSTALL_DIR/go"
GO_BIN_PATH="/usr/local/go/bin"

echo "== Detecting OS and architecture =="

OS_RAW=$(uname -s)
ARCH_RAW=$(uname -m)

# OS
case "$OS_RAW" in
    Linux)  GOOS="linux" ;;
    Darwin) GOOS="darwin" ;;
    *)
        echo "Unsupported OS: $OS_RAW"
        exit 1
        ;;
esac

# ARCH
case "$ARCH_RAW" in
    x86_64)          GOARCH="amd64" ;;
    aarch64|arm64)   GOARCH="arm64" ;;
    armv6l)          GOARCH="armv6l" ;;
    *)
        echo "Unsupported architecture: $ARCH_RAW"
        exit 1
        ;;
esac

echo "OS:   $GOOS"
echo "ARCH: $GOARCH"

echo "== Fetching latest stable version =="
LATEST=$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)
echo "Version: $LATEST"

TARBALL="${LATEST}.${GOOS}-${GOARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"

echo "Checking availability..."
if ! curl -fsI "$URL" >/dev/null; then
    echo "Download not available: $URL"
    exit 1
fi

echo "Downloading $TARBALL..."
curl -fLO "$URL"

echo "Removing previous installation..."
sudo rm -rf "$GO_DIR"

echo "Installing..."
sudo tar -C "$INSTALL_DIR" -xzf "$TARBALL"
rm -f "$TARBALL"

echo "== Updating PATH in shell configs =="

append_path() {
    local file="$1"

    [ -f "$file" ] || return 0

    if ! grep -q "$GO_BIN_PATH" "$file"; then
        {
            echo ""
            echo "# Go"
            echo "export PATH=\$PATH:$GO_BIN_PATH"
        } >> "$file"
        echo "Updated: $file"
    fi
}

append_path "$HOME/.zshrc"
append_path "$HOME/.bashrc"
append_path "$HOME/.profile"

export PATH="$PATH:$GO_BIN_PATH"

echo
echo "== Verification =="
if command -v go >/dev/null 2>&1; then
    file "$GO_BIN_PATH/go"
    go version
    echo "Go installed successfully."
else
    echo "Go not found in PATH."
    exit 1
fi
