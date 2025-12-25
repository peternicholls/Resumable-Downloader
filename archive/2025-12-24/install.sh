#!/usr/bin/env bash
#
# Install TUI dependencies for SafeDownload
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}SafeDownload TUI Dependency Installer${NC}"
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo -e "${BLUE}Detected OS:${NC} $OS"
echo ""

# Check for Gum
echo -e "${BLUE}Checking for Gum...${NC}"
if command -v gum &> /dev/null; then
    VERSION=$(gum --version 2>&1 || echo "unknown")
    echo -e "${GREEN}✓ Gum is already installed${NC} ($VERSION)"
    exit 0
fi

echo -e "${YELLOW}⚠ Gum not found${NC}"
echo ""

# Install Gum based on OS
case "$OS" in
    macos)
        echo -e "${BLUE}Installing Gum via Homebrew...${NC}"
        
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}✗ Homebrew not found${NC}"
            echo ""
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            echo "Or install Gum manually:"
            echo "  https://github.com/charmbracelet/gum/releases"
            exit 1
        fi
        
        brew install gum
        ;;
    
    linux)
        echo -e "${BLUE}Installing Gum...${NC}"
        echo ""
        echo "Choose installation method:"
        echo "  1) Download binary (recommended)"
        echo "  2) Use snap (if available)"
        echo "  3) Cancel"
        echo ""
        read -p "Choice [1-3]: " choice
        
        case "$choice" in
            1)
                # Download and install binary
                echo ""
                echo -e "${BLUE}Downloading Gum binary...${NC}"
                
                # Detect architecture
                ARCH=$(uname -m)
                case "$ARCH" in
                    x86_64)
                        ARCH="x86_64"
                        ;;
                    aarch64|arm64)
                        ARCH="arm64"
                        ;;
                    *)
                        echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
                        exit 1
                        ;;
                esac
                
                VERSION="0.14.5"
                URL="https://github.com/charmbracelet/gum/releases/download/v${VERSION}/gum_${VERSION}_Linux_${ARCH}.tar.gz"
                
                echo "Downloading from: $URL"
                
                # Create temp directory
                TEMP_DIR=$(mktemp -d)
                cd "$TEMP_DIR"
                
                # Download
                if command -v curl &> /dev/null; then
                    curl -fsSL "$URL" -o gum.tar.gz
                elif command -v wget &> /dev/null; then
                    wget -q "$URL" -O gum.tar.gz
                else
                    echo -e "${RED}✗ Neither curl nor wget found${NC}"
                    exit 1
                fi
                
                # Extract
                tar xzf gum.tar.gz
                
                # Install
                echo ""
                echo -e "${BLUE}Installing to /usr/local/bin/ (requires sudo)...${NC}"
                sudo mv gum /usr/local/bin/
                sudo chmod +x /usr/local/bin/gum
                
                # Cleanup
                cd - > /dev/null
                rm -rf "$TEMP_DIR"
                
                echo -e "${GREEN}✓ Gum installed successfully${NC}"
                ;;
            
            2)
                # Use snap
                if ! command -v snap &> /dev/null; then
                    echo -e "${RED}✗ Snap not found${NC}"
                    echo "Please install snapd first or choose option 1"
                    exit 1
                fi
                
                echo ""
                echo -e "${BLUE}Installing via snap...${NC}"
                sudo snap install gum
                echo -e "${GREEN}✓ Gum installed successfully${NC}"
                ;;
            
            3|*)
                echo "Installation cancelled"
                exit 0
                ;;
        esac
        ;;
    
    *)
        echo -e "${RED}✗ Unsupported operating system${NC}"
        echo ""
        echo "Please install Gum manually:"
        echo "  https://github.com/charmbracelet/gum/releases"
        exit 1
        ;;
esac

# Verify installation
echo ""
echo -e "${BLUE}Verifying installation...${NC}"
if command -v gum &> /dev/null; then
    VERSION=$(gum --version 2>&1 || echo "unknown")
    echo -e "${GREEN}✓ Gum installed successfully!${NC} ($VERSION)"
    echo ""
    echo -e "${BLUE}You can now run:${NC}"
    echo "  ./safedownload-gum          # Interactive TUI"
    echo "  ./safedownload-gum menu     # Menu-driven TUI"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    echo "Please check the output above for errors"
    exit 1
fi
