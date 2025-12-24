#!/usr/bin/env bash
#
# SafeDownload Installation Script
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Determine installation directory
INSTALL_DIR="${HOME}/.local/bin"
if [[ -d /usr/local/bin && -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
fi

# Allow override with environment variable
INSTALL_DIR="${SAFEDOWNLOAD_INSTALL_DIR:-$INSTALL_DIR}"

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="safedownload"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               SafeDownload Installation Script               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check dependencies
print_info "Checking dependencies..."

if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed."
    print_info "Install with: sudo apt install curl (Ubuntu/Debian)"
    print_info "           or: brew install curl (macOS)"
    exit 1
fi
print_success "curl is installed"

if ! command -v python3 &> /dev/null; then
    print_error "python3 is required but not installed."
    print_info "Install with: sudo apt install python3 (Ubuntu/Debian)"
    print_info "           or: brew install python3 (macOS)"
    exit 1
fi
print_success "python3 is installed"

echo ""

# Create installation directory if needed
if [[ ! -d "$INSTALL_DIR" ]]; then
    print_info "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Copy script
print_info "Installing safedownload to $INSTALL_DIR..."
cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Create state directory
STATE_DIR="${HOME}/.safedownload"
if [[ ! -d "$STATE_DIR" ]]; then
    print_info "Creating state directory: $STATE_DIR"
    mkdir -p "$STATE_DIR"
    mkdir -p "$STATE_DIR/pids"
    mkdir -p "$STATE_DIR/downloads"
fi

print_success "SafeDownload installed successfully!"
echo ""

# Check if install dir is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "Installation directory is not in your PATH"
    echo ""
    echo "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo -e "  ${YELLOW}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    echo ""
    echo "Then run: source ~/.bashrc (or source ~/.zshrc)"
    echo ""
else
    print_success "Installation directory is already in PATH"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Usage:"
echo "  safedownload <URL>                    # Download a file"
echo "  safedownload -g                       # Launch terminal UI"
echo "  safedownload --help                   # Show help"
echo ""
