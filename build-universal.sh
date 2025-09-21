#!/bin/bash
set -e

# Universal macOS build script for protobuf
# Creates fat binaries that work on both Intel and Apple Silicon

BUILD_TYPE=${BUILD_TYPE:-Release}
PLATFORM="macos-universal"

echo "Building protobuf for macOS Universal (Intel + Apple Silicon)..."
echo "Detected platform: $PLATFORM"
echo "Build type: $BUILD_TYPE"

# Clean any previous builds
rm -rf build-x86_64 build-arm64 install-$PLATFORM

# Create separate build directories for each architecture
mkdir -p build-x86_64 build-arm64

echo ""
echo "=== Building for x86_64 (Intel) ==="
echo "Configuring CMake for x86_64..."
cmake -S . -B build-x86_64 \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/install-x86_64" \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -Dprotobuf_BUILD_CONFORMANCE=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_BUILD_PROTOBUF_BINARIES=ON \
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
    -Dprotobuf_FORCE_FETCH_DEPENDENCIES=OFF \
    -Dprotobuf_WITH_ZLIB=OFF

echo "Building x86_64..."
cmake --build build-x86_64 --config $BUILD_TYPE -j$(sysctl -n hw.ncpu)

echo "Installing x86_64..."
cmake --install build-x86_64

echo ""
echo "=== Building for arm64 (Apple Silicon) ==="
echo "Configuring CMake for arm64..."
cmake -S . -B build-arm64 \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/install-arm64" \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -Dprotobuf_BUILD_CONFORMANCE=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_BUILD_PROTOBUF_BINARIES=ON \
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
    -Dprotobuf_FORCE_FETCH_DEPENDENCIES=OFF \
    -Dprotobuf_WITH_ZLIB=OFF

echo "Building arm64..."
cmake --build build-arm64 --config $BUILD_TYPE -j$(sysctl -n hw.ncpu)

echo "Installing arm64..."
cmake --install build-arm64

echo ""
echo "=== Creating Universal Binaries ==="
mkdir -p install-$PLATFORM/{lib,bin,include}

# Copy headers (same for both architectures)
echo "Copying headers..."
cp -r install-x86_64/include/* install-$PLATFORM/include/

# Create universal static libraries using lipo
echo "Creating universal static libraries..."
for lib in install-x86_64/lib/*.a; do
    lib_name=$(basename "$lib")
    if [ -f "install-arm64/lib/$lib_name" ]; then
        echo "  Creating universal $lib_name"
        lipo -create \
            "install-x86_64/lib/$lib_name" \
            "install-arm64/lib/$lib_name" \
            -output "install-$PLATFORM/lib/$lib_name"
    else
        echo "  Warning: $lib_name not found in arm64 build, copying x86_64 version"
        cp "$lib" "install-$PLATFORM/lib/"
    fi
done

# Create universal binaries
echo "Creating universal binaries..."
for bin in install-x86_64/bin/*; do
    bin_name=$(basename "$bin")
    if [ -f "install-arm64/bin/$bin_name" ]; then
        echo "  Creating universal $bin_name"
        lipo -create \
            "install-x86_64/bin/$bin_name" \
            "install-arm64/bin/$bin_name" \
            -output "install-$PLATFORM/bin/$bin_name"
        chmod +x "install-$PLATFORM/bin/$bin_name"
    else
        echo "  Warning: $bin_name not found in arm64 build, copying x86_64 version"
        cp "$bin" "install-$PLATFORM/bin/"
    fi
done

# Copy other files (cmake configs, pkg-config, etc.)
if [ -d "install-x86_64/lib/cmake" ]; then
    echo "Copying CMake configuration files..."
    cp -r install-x86_64/lib/cmake install-$PLATFORM/lib/
fi

if [ -d "install-x86_64/lib/pkgconfig" ]; then
    echo "Copying pkg-config files..."
    cp -r install-x86_64/lib/pkgconfig install-$PLATFORM/lib/
fi

echo ""
echo "=== Verification ==="
echo "Verifying universal binaries..."
for bin in install-$PLATFORM/bin/*; do
    if [ -f "$bin" ] && [ -x "$bin" ]; then
        echo "  $(basename "$bin"): $(lipo -info "$bin" 2>/dev/null || echo 'Not a binary')"
    fi
done

echo ""
echo "Verifying universal libraries..."
for lib in install-$PLATFORM/lib/*.a; do
    if [ -f "$lib" ]; then
        echo "  $(basename "$lib"): $(lipo -info "$lib" 2>/dev/null || echo 'Not a binary')"
    fi
done

echo ""
echo "Build completed successfully!"
echo "Universal binaries and headers are in the install-$PLATFORM directory."

echo ""
echo "Install directory contents:"
find install-$PLATFORM -type f | head -20
if [ $(find install-$PLATFORM -type f | wc -l) -gt 20 ]; then
    echo "... and $(( $(find install-$PLATFORM -type f | wc -l) - 20 )) more files"
fi
