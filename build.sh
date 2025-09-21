#!/bin/bash

# Build script for Linux and macOS
# This script builds the protobuf library using CMake

set -e  # Exit on any error

echo "Building protobuf for $(uname -s)..."

# Set build configuration (default to Release)
BUILD_TYPE=${1:-Release}

# Detect platform for install directory naming
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        PLATFORM="macos-arm64"
    else
        PLATFORM="macos-x86_64"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux-x86_64"
else
    echo "Unsupported platform: $OSTYPE"
    exit 1
fi

echo "Detected platform: $PLATFORM"
echo "Build type: $BUILD_TYPE"

# Create build directory
mkdir -p build

# Configure CMake
echo "Configuring CMake..."
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -Dprotobuf_BUILD_CONFORMANCE=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_BUILD_PROTOBUF_BINARIES=ON \
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
    -Dprotobuf_FORCE_FETCH_DEPENDENCIES=ON \
    -Dprotobuf_WITH_ZLIB=OFF

# Build the project
echo "Building project..."
cmake --build build --config "$BUILD_TYPE" --target install -j $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Build completed successfully!"
echo "Built libraries and headers are in the install-$PLATFORM directory."

# List the contents of the install directory
INSTALL_DIR="install-$PLATFORM"
if [ -d "$INSTALL_DIR" ]; then
    echo ""
    echo "Install directory contents:"
    find "$INSTALL_DIR" -type f | head -20
    if [ $(find "$INSTALL_DIR" -type f | wc -l) -gt 20 ]; then
        echo "... and more files"
    fi
fi
