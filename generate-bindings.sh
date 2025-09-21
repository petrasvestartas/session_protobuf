#!/bin/bash
set -e

# Generate language bindings for common proto files
# This creates ready-to-use code for Rust, Python, and C++

echo "🔧 Generating language bindings from proto files..."

# Detect platform and set protoc path
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        PROTOC_PATH="install-macos-arm64/bin/protoc"
        INSTALL_DIR="install-macos-arm64"
    else
        PROTOC_PATH="install-macos-x86_64/bin/protoc"
        INSTALL_DIR="install-macos-x86_64"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PROTOC_PATH="install-linux-x86_64/bin/protoc"
    INSTALL_DIR="install-linux-x86_64"
else
    echo "❌ Unsupported platform for this script"
    exit 1
fi

# Check if protoc exists
if [ ! -f "$PROTOC_PATH" ]; then
    echo "❌ protoc not found at $PROTOC_PATH"
    echo "Please build protobuf first by running ./build.sh"
    exit 1
fi

# Create output directories
mkdir -p generated/{cpp,python,rust}

# Proto files to generate (Google well-known types)
PROTO_FILES=(
    "src/src/google/protobuf/any.proto"
    "src/src/google/protobuf/timestamp.proto"
    "src/src/google/protobuf/duration.proto"
    "src/src/google/protobuf/empty.proto"
    "src/src/google/protobuf/struct.proto"
    "src/src/google/protobuf/wrappers.proto"
)

echo ""
echo "📁 Proto files to process:"
for proto in "${PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  ✅ $proto"
    else
        echo "  ❌ $proto (not found)"
    fi
done

echo ""
echo "🔨 Generating C++ bindings..."
for proto in "${PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto")..."
        "$PROTOC_PATH" \
            --proto_path=src/src \
            --cpp_out=generated/cpp \
            "$proto"
    fi
done

echo ""
echo "🐍 Generating Python bindings..."
for proto in "${PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto")..."
        "$PROTOC_PATH" \
            --proto_path=src/src \
            --python_out=generated/python \
            "$proto"
    fi
done

echo ""
echo "🦀 Generating Rust bindings..."
# For Rust, we'll create a build script that users can integrate
cat > generated/rust/build.rs << 'EOF'
// Build script for Rust protobuf integration
// Add this to your Cargo.toml:
// [build-dependencies]
// protobuf-codegen = "3.0"

use protobuf_codegen::Codegen;

fn main() {
    Codegen::new()
        .pure()
        .cargo_out_dir("protos")
        .inputs(&[
            "proto/google/protobuf/any.proto",
            "proto/google/protobuf/timestamp.proto",
            "proto/google/protobuf/duration.proto",
            "proto/google/protobuf/empty.proto",
            "proto/google/protobuf/struct.proto",
            "proto/google/protobuf/wrappers.proto",
        ])
        .include("proto")
        .run_from_script();
}
EOF

cat > generated/rust/Cargo.toml << 'EOF'
[package]
name = "protobuf-common-types"
version = "0.1.0"
edition = "2021"

[dependencies]
protobuf = "3.0"

[build-dependencies]
protobuf-codegen = "3.0"
EOF

cat > generated/rust/lib.rs << 'EOF'
//! Common Protocol Buffer types for Rust
//! 
//! This crate provides pre-generated Rust bindings for Google's
//! well-known protobuf types.

pub mod google {
    pub mod protobuf {
        include!(concat!(env!("OUT_DIR"), "/protos/google.protobuf.rs"));
    }
}

pub use google::protobuf::*;
EOF

echo ""
echo "📦 Creating archives..."
cd generated

# Create C++ archive
tar -czf ../cpp-bindings.tar.gz cpp/
echo "  ✅ cpp-bindings.tar.gz created"

# Create Python archive  
tar -czf ../python-bindings.tar.gz python/
echo "  ✅ python-bindings.tar.gz created"

# Create Rust archive
tar -czf ../rust-bindings.tar.gz rust/
echo "  ✅ rust-bindings.tar.gz created"

cd ..

echo ""
echo "✅ Language bindings generated successfully!"
echo ""
echo "📋 Generated files:"
echo "  - cpp-bindings.tar.gz    (C++ .h and .cc files)"
echo "  - python-bindings.tar.gz (Python _pb2.py files)"
echo "  - rust-bindings.tar.gz   (Rust crate template)"
echo ""
echo "💡 Usage:"
echo "  C++:    Extract and include .h files, compile .cc files"
echo "  Python: Extract and import the _pb2.py modules"
echo "  Rust:   Extract and use as a Cargo crate"
