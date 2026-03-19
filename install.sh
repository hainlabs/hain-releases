#!/usr/bin/env bash
set -euo pipefail

GITHUB_REPO="hainlabs/hain-releases"
INSTALL_DIR="${HAIN_INSTALL_DIR:-$HOME/.local/share/hain}"
BIN_DIR="${HAIN_BIN_DIR:-$HOME/.local/bin}"

usage() {
    cat <<EOF
Hain installer — downloads and installs the standalone CLI/TUI.

Usage:
  curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/scripts/install.sh | bash
  curl -fsSL ... | bash -s -- --version 0.1.0

Options:
  --version <ver>   Install a specific version (default: latest release)
  --install-dir     Installation directory (default: $INSTALL_DIR)
  --bin-dir         Directory for symlinks, should be in PATH (default: $BIN_DIR)
  --uninstall       Remove hain and its symlinks
  --help            Show this message

Environment:
  HAIN_INSTALL_DIR  Alternative way to set installation directory
  HAIN_BIN_DIR      Alternative way to set bin directory
EOF
    exit 0
}

VERSION=""
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)     VERSION="$2"; shift 2 ;;
        --install-dir) INSTALL_DIR="$2"; shift 2 ;;
        --bin-dir)     BIN_DIR="$2"; shift 2 ;;
        --uninstall)   UNINSTALL=true; shift ;;
        --help)        usage ;;
        *)             echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

detect_platform() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux)  os="linux" ;;
        Darwin) os="darwin" ;;
        *)      echo "Error: unsupported OS: $os" >&2; exit 1 ;;
    esac

    case "$arch" in
        x86_64|amd64)  arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)             echo "Error: unsupported architecture: $arch" >&2; exit 1 ;;
    esac

    PLATFORM="$os"
    ARCH="$arch"
}

resolve_version() {
    if [[ -n "$VERSION" ]]; then
        return
    fi

    echo "==> Fetching latest release version..."
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

    if command -v curl &>/dev/null; then
        VERSION=$(curl -fsSL "$api_url" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    elif command -v wget &>/dev/null; then
        VERSION=$(wget -qO- "$api_url" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    else
        echo "Error: curl or wget is required." >&2
        exit 1
    fi

    if [[ -z "$VERSION" ]]; then
        echo "Error: could not determine latest version from GitHub." >&2
        echo "Specify a version manually: --version <ver>" >&2
        exit 1
    fi
}

download() {
    local url="$1" dest="$2"
    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar -o "$dest" "$url"
    elif command -v wget &>/dev/null; then
        wget --show-progress -qO "$dest" "$url"
    fi
}

verify_checksum() {
    local tarball="$1" expected_file="$2"

    if [[ ! -f "$expected_file" ]]; then
        echo "    Warning: checksum file not available, skipping verification."
        return
    fi

    local expected actual
    expected="$(awk '{print $1}' "$expected_file")"
    if command -v sha256sum &>/dev/null; then
        actual="$(sha256sum "$tarball" | awk '{print $1}')"
    elif command -v shasum &>/dev/null; then
        actual="$(shasum -a 256 "$tarball" | awk '{print $1}')"
    else
        echo "    Warning: no checksum tool available, skipping verification."
        return
    fi

    if [[ "$expected" != "$actual" ]]; then
        echo "Error: SHA256 checksum mismatch!" >&2
        echo "  Expected: $expected" >&2
        echo "  Got:      $actual" >&2
        rm -f "$tarball" "$expected_file"
        exit 1
    fi

    echo "    SHA256 checksum verified."
}

create_symlinks() {
    mkdir -p "$BIN_DIR"

    local bins=("hain" "hain-cli" "hain-tui")
    for bin in "${bins[@]}"; do
        local src="$INSTALL_DIR/bin/$bin"
        local dest="$BIN_DIR/$bin"
        if [[ -e "$src" ]]; then
            ln -sf "$src" "$dest"
        fi
    done
}

path_contains_bin_dir() {
    case ":$PATH:" in
        *":$BIN_DIR:"*) return 0 ;;
        *)              return 1 ;;
    esac
}

shell_config_file() {
    local shell_name
    shell_name="$(basename "${SHELL:-/bin/bash}")"
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.bashrc" ;;
    esac
}

uninstall() {
    echo ""
    echo "  Hain Uninstaller"
    echo "  ────────────────"
    echo ""

    local bins=("hain" "hain-cli" "hain-tui")
    local removed=false

    for bin in "${bins[@]}"; do
        local link="$BIN_DIR/$bin"
        if [[ -L "$link" || -e "$link" ]]; then
            rm -f "$link"
            echo "  Removed $link"
            removed=true
        fi
    done

    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
        echo "  Removed $INSTALL_DIR"
        removed=true
    fi

    if [[ "$removed" == true ]]; then
        echo ""
        echo "  Uninstall complete."
    else
        echo "  Nothing to remove — hain is not installed at the expected paths."
    fi

    local config_dir="$HOME/.config/hain"
    if [[ -d "$config_dir" ]]; then
        echo ""
        echo "  Note: app config at $config_dir was preserved."
        echo "  Remove it manually if you no longer need it:"
        echo ""
        echo "    rm -rf $config_dir"
    fi

    echo ""
    exit 0
}

# ── Main ─────────────────────────────────────────────────────────────────────

if [[ "$UNINSTALL" == true ]]; then
    uninstall
fi

detect_platform
resolve_version

RELEASE_NAME="hain-${VERSION}-${PLATFORM}-${ARCH}"
BASE_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}"
TARBALL_URL="${BASE_URL}/${RELEASE_NAME}.tar.gz"
CHECKSUM_URL="${BASE_URL}/${RELEASE_NAME}.sha256"

echo ""
echo "  Hain Installer"
echo "  ──────────────"
echo "  Version:      ${VERSION}"
echo "  Platform:     ${PLATFORM}-${ARCH}"
echo "  Install to:   ${INSTALL_DIR}"
echo "  Bin dir:      ${BIN_DIR}"
echo ""

# Download to temp directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Downloading ${RELEASE_NAME}.tar.gz..."
download "$TARBALL_URL" "$TMP_DIR/${RELEASE_NAME}.tar.gz"

echo "==> Downloading checksum..."
download "$CHECKSUM_URL" "$TMP_DIR/${RELEASE_NAME}.sha256" 2>/dev/null || true

echo "==> Verifying checksum..."
verify_checksum "$TMP_DIR/${RELEASE_NAME}.tar.gz" "$TMP_DIR/${RELEASE_NAME}.sha256"

# Remove previous installation
if [[ -d "$INSTALL_DIR" ]]; then
    echo "==> Removing previous installation..."
    rm -rf "$INSTALL_DIR"
fi

echo "==> Extracting to ${INSTALL_DIR}..."
mkdir -p "$(dirname "$INSTALL_DIR")"
tar -xzf "$TMP_DIR/${RELEASE_NAME}.tar.gz" -C "$(dirname "$INSTALL_DIR")"
mv "$(dirname "$INSTALL_DIR")/${RELEASE_NAME}" "$INSTALL_DIR"

echo "==> Creating symlinks in ${BIN_DIR}..."
create_symlinks

echo ""
echo "  Installation complete!"
echo ""

if ! path_contains_bin_dir; then
    CONFIG_FILE="$(shell_config_file)"
    echo "  ${BIN_DIR} is not in your PATH."
    echo "  Add it by running:"
    echo ""
    echo "    echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ${CONFIG_FILE}"
    echo "    source ${CONFIG_FILE}"
    echo ""
fi

echo "  Get started:"
echo ""
echo "    hain --help"
echo "    hain vault init ~/my-vault"
echo "    hain                        # launch interactive TUI"
echo ""
