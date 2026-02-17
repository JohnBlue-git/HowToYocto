#!/bin/bash
# Yocto Build Environment Setup Script
# This script automates the setup process for the HowToYocto project

set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Yocto Build Environment Setup${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"

# Check disk space
AVAILABLE=$(df /workspaces 2>/dev/null | tail -1 | awk '{print $4}')
REQUIRED=$((50*1024*1024))  # 50GB in KB

if [ "$AVAILABLE" -lt "$REQUIRED" ]; then
    echo -e "${RED}✗ Insufficient disk space!${NC}"
    echo -e "  Available: $(df -h /workspaces | tail -1 | awk '{print $4}')"
    echo -e "  Required: 50GB"
    echo -e "  ${YELLOW}Continuing anyway, but build may fail...${NC}\n"
else
    echo -e "${GREEN}✓ Sufficient disk space: $(df -h /workspaces | tail -1 | awk '{print $4}')${NC}\n"
fi

# Check essential tools
for tool in git python3 gcc make wget curl; do
    if command -v $tool &> /dev/null; then
        VERSION=$($tool --version 2>&1 | head -1 || echo "installed")
        echo -e "${GREEN}✓${NC} $tool: OK"
    else
        echo -e "${RED}✗${NC} $tool: NOT FOUND"
        exit 1
    fi
done
echo ""

# Step 2: Install Yocto dependencies
echo -e "${YELLOW}[2/5] Installing Yocto build dependencies...${NC}"
echo -e "  This requires root access (sudo)\n"

if ! command -v gawk &> /dev/null; then
    echo -e "  Installing packages..."
    sudo apt-get update > /dev/null 2>&1 || true
    sudo apt-get install -y \
        gawk wget git diffstat unzip texinfo gcc build-essential \
        chrpath socat cpio python3 python3-pip python3-pexpect xz-utils \
        debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
        libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd \
        liblz4-tool > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Yocto dependencies installed\n"
else
    echo -e "${GREEN}✓${NC} Yocto dependencies already installed\n"
fi

# Step 3: Install Repo tool
echo -e "${YELLOW}[3/5] Installing Google Repo tool...${NC}"

if command -v repo &> /dev/null; then
    echo -e "${GREEN}✓${NC} Repo tool already installed\n"
else
    echo -e "  Creating ~/bin directory..."
    mkdir -p ~/bin
    
    echo -e "  Downloading repo tool..."
    curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    
    # Add to PATH if not already there
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/bin:$PATH"
    fi
    
    if repo --version &> /dev/null; then
        echo -e "${GREEN}✓${NC} Repo tool installed successfully\n"
    else
        echo -e "${RED}✗${NC} Repo tool installation may have failed\n"
        exit 1
    fi
fi

# Step 4: Initialize Yocto workspace
echo -e "${YELLOW}[4/5] Initializing Yocto workspace...${NC}"

WORKSPACE_DIR="${HOME}/yocto-workspace"

if [ -d "$WORKSPACE_DIR" ]; then
    echo -e "${YELLOW}  Workspace already exists at: $WORKSPACE_DIR${NC}"
    read -p "  Reinitialize? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "  Skipping initialization\n"
    else
        rm -rf "$WORKSPACE_DIR"
    fi
fi

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo -e "  Creating workspace at: $WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    echo -e "  Initializing repo..."
    repo init -u https://github.com/JohnBlue-git/HowToYocto.git -b main > /dev/null 2>&1
    
    echo -e "  Syncing repositories (this may take 10-30 minutes)..."
    echo -e "  ${BLUE}Starting sync...${NC}"
    repo sync
    
    echo -e "${GREEN}✓${NC} Yocto workspace initialized\n"
else
    echo -e "${GREEN}✓${NC} Yocto workspace already exists\n"
fi

# Step 5: Summary and next steps
echo -e "${YELLOW}[5/5] Setup Complete!${NC}\n"

echo -e "${GREEN}✓ All steps completed successfully${NC}\n"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "1. Navigate to workspace:"
echo -e "   ${YELLOW}cd $WORKSPACE_DIR${NC}\n"

echo -e "2. Source Yocto build environment:"
echo -e "   ${YELLOW}cd poky${NC}"
echo -e "   ${YELLOW}source oe-init-build-env build${NC}\n"

echo -e "3. Verify hello-world-module recipe:"
echo -e "   ${YELLOW}bitbake -p hello-world-module${NC}\n"

echo -e "4. Build the kernel module:"
echo -e "   ${YELLOW}bitbake hello-world-module${NC}\n"

echo -e "5. Build image with the module:"
echo -e "   ${YELLOW}bitbake core-image-minimal${NC}\n"

echo -e "6. Test with QEMU:"
echo -e "   ${YELLOW}sudo runqemu qemux86-64 nographic${NC}\n"

echo -e "📚 For more details, see: $WORKSPACE_DIR/meta-application/REPO_SETUP.md"
echo -e "   or check ./meta-application/README.md for recipe information\n"

echo -e "${BLUE}========================================${NC}"
