#!/bin/bash
#
# Setup Yocto Build Environment with Auto Layer Addition & Thread Configuration
# 
# Usage: source setup-build-env.sh
# 
# This script:
# 1. Checks if we're in the correct workspace
# 2. Sources the Yocto environment
# 3. Automatically configures bitbake thread settings for optimal performance
# 4. Automatically adds the meta-application layer if not already present
# 5. Verifies the layer is properly configured
#

set -e

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if we can find the workspace structure
if [ ! -d "$SCRIPT_DIR/.repo" ] || [ ! -d "$SCRIPT_DIR/poky" ] || [ ! -d "$SCRIPT_DIR/meta-application" ]; then
    echo "ERROR: This script must be run from the HowToYocto workspace root directory"
    echo "Current directory: $SCRIPT_DIR"
    echo "Expected to find: .repo/, poky/, and meta-application/ directories"
    return 1 2>/dev/null || exit 1
fi

echo "=========================================="
echo "Setting up Yocto Build Environment"
echo "=========================================="
echo "Workspace: $SCRIPT_DIR"
echo ""

# Navigate to poky directory
cd "$SCRIPT_DIR/poky"
echo "1. Sourcing Yocto environment..."
source oe-init-build-env build > /dev/null 2>&1

# Verify we're now in the build directory
if [ ! -f "conf/local.conf" ]; then
    echo "ERROR: Failed to source oe-init-build-env"
    return 1 2>/dev/null || exit 1
fi

echo "   ✓ Environment sourced successfully"
echo ""

# Configure bitbake thread settings for optimal performance
echo "2. Configuring bitbake thread settings..."

# Get the number of CPU cores available
NUM_CORES=$(nproc 2>/dev/null || echo "4")
# Use number of cores for BB_NUMBER_THREADS and half for PARALLEL_MAKE
BB_THREADS=$NUM_CORES
PARALLEL_JOBS=$((NUM_CORES * 4))
[ $PARALLEL_JOBS -lt 1 ] && PARALLEL_JOBS=1

# Check if BB_NUMBER_THREADS is already configured
if ! grep -q "^BB_NUMBER_THREADS" conf/local.conf; then
    echo "# Bitbake Threading Configuration (Auto-configured)" >> conf/local.conf
    echo "BB_NUMBER_THREADS = \"$BB_THREADS\"" >> conf/local.conf
    echo "PARALLEL_MAKE = \"-j $PARALLEL_JOBS\"" >> conf/local.conf
    echo "   ✓ Thread configuration added (BB_NUMBER_THREADS=$BB_THREADS, PARALLEL_MAKE=-j$PARALLEL_JOBS)"
else
    echo "   ✓ Thread configuration already present in local.conf"
fi
echo ""

# Check if meta-application layer is already added
echo "3. Checking for meta-application layer..."
if bitbake-layers show-layers 2>/dev/null | grep -q "meta-application"; then
    echo "   ✓ meta-application layer already added"
else
    echo "   • meta-application layer not found, adding it..."
    bitbake-layers add-layer ../../meta-application
    echo "   ✓ meta-application layer added successfully"
fi

echo ""
echo "4. Verifying layer configuration..."
echo "=========================================="
bitbake-layers show-layers | grep -E "layer|meta-application|meta-poky|meta-yocto"
echo "=========================================="

echo ""
echo "✓ Build environment is ready!"
echo ""
echo "You can now run bitbake commands, e.g.:"
echo "  bitbake hello-world-module"
echo "  bitbake hello"
echo "  bitbake core-image-minimal"
echo ""
