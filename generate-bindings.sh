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

# Proto files to generate
# 1. Google well-known types (from protobuf source)
GOOGLE_PROTO_FILES=(
    "src/src/google/protobuf/any.proto"
    "src/src/google/protobuf/timestamp.proto"
    "src/src/google/protobuf/duration.proto"
    "src/src/google/protobuf/empty.proto"
    "src/src/google/protobuf/struct.proto"
    "src/src/google/protobuf/wrappers.proto"
)

# 2. User proto files (place your .proto files in proto/user/)
USER_PROTO_FILES=()
if [ -d "proto/user" ]; then
    while IFS= read -r -d '' proto; do
        USER_PROTO_FILES+=("$proto")
    done < <(find proto/user -name "*.proto" -print0)
fi

# Combine all proto files
PROTO_FILES=("${GOOGLE_PROTO_FILES[@]}" "${USER_PROTO_FILES[@]}")

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

# Generate Google well-known types
for proto in "${GOOGLE_PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto") (Google)..."
        "$PROTOC_PATH" \
            --proto_path=src/src \
            --cpp_out=generated/cpp \
            "$proto"
    fi
done

# Generate user proto files
for proto in "${USER_PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto") (User)..."
        "$PROTOC_PATH" \
            --proto_path=proto \
            --proto_path=src/src \
            --cpp_out=generated/cpp \
            "$proto"
    fi
done

echo ""
echo "🐍 Generating Python bindings..."

# Generate Google well-known types
for proto in "${GOOGLE_PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto") (Google)..."
        "$PROTOC_PATH" \
            --proto_path=src/src \
            --python_out=generated/python \
            "$proto"
    fi
done

# Generate user proto files
for proto in "${USER_PROTO_FILES[@]}"; do
    if [ -f "$proto" ]; then
        echo "  Processing $(basename "$proto") (User)..."
        "$PROTOC_PATH" \
            --proto_path=proto \
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

# Create Rust archive (include proto files for self-contained crate)
cp -r ../proto rust/
tar -czf ../rust-bindings.tar.gz rust/
echo "  ✅ rust-bindings.tar.gz created (includes proto files)"

cd ..

echo ""
echo "✅ Language-specific serialization code generated successfully!"
echo ""
echo "📋 Generated archives:"
echo "  - cpp-bindings.tar.gz    → Contains .pb.h/.pb.cc files for serialization"
echo "  - python-bindings.tar.gz → Contains _pb2.py modules for serialization"  
echo "  - rust-bindings.tar.gz   → Contains Rust crate for serialization"
echo ""
echo "🎯 What you get:"
echo "  • Self-contained serialization code (no external protobuf dependency needed)"
echo "  • Ready-to-include files for your applications"
echo "  • Cross-platform binary serialization"
echo ""
echo "💡 Usage in your applications:"
echo "  C++:    #include \"your_proto.pb.h\" and compile your_proto.pb.cc"
echo "  Python: import your_proto_pb2 (no pip install protobuf needed)"
echo "  Rust:   Add as dependency (no external protobuf crate needed)"
