# Protobuf Code Generation System

This system generates language-specific serialization code (C++, Python, Rust) from your `.proto` files using pre-built protoc binaries. **No compilation or package managers needed** - just run one script and get ready-to-use serialization code.

## 🚀 Quick Start

### One Command Does Everything

**Linux/macOS:**
```bash
./build-and-generate.sh
```

**Windows:**
```bat
build-and-generate.bat
```

That's it! The script will:
1. ✅ Set up the protobuf environment using pre-built binaries
2. ✅ Generate C++, Python, and Rust bindings from your proto files
3. ✅ Create ready-to-use archives with all generated code

## 📁 What You Get

After running the script, you'll have:

- **`cpp-bindings.tar.gz`** → Contains `.pb.h/.pb.cc` files for C++
- **`python-bindings.tar.gz`** → Contains `_pb2.py` modules for Python  
- **`rust-bindings.tar.gz`** → Contains complete Rust crate

## 📋 Your Proto Files

The system processes proto files from:
- `proto/color.proto` - Your color definition (matches C++ Color class)
- `proto/point.proto` - Your point definition (matches C++ Point class)

### C++ Usage
```cpp
#include "color.pb.h"
#include "point.pb.h"

// Create and serialize a color
session_proto::ColorProto color;
color.set_name("Red");
color.set_guid("color-123");
color.set_r(255);
color.set_g(0);
color.set_b(0);
color.set_a(255);

std::string serialized = color.SerializeAsString();

// Create and serialize a point
session_proto::PointProto point;
point.set_guid("point-456");
point.set_name("Origin");
point.set_x(0.0);
point.set_y(0.0);
point.set_z(0.0);
point.set_width(1.0);
*point.mutable_pointcolor() = color;

std::string point_serialized = point.SerializeAsString();
```

### Python Usage
```python
import color_pb2
import point_pb2

# Create and serialize a color
color = color_pb2.ColorProto()
color.name = "Red"
color.guid = "color-123"
color.r = 255
color.g = 0
color.b = 0
color.a = 255

serialized = color.SerializeToString()

# Create and serialize a point
point = point_pb2.PointProto()
point.guid = "point-456"
point.name = "Origin"
point.x = 0.0
point.y = 0.0
point.z = 0.0
point.width = 1.0
point.pointcolor.CopyFrom(color)

point_serialized = point.SerializeToString()
```

### Rust Usage
```rust
use protobuf_types::*;

// Add the generated crate to your Cargo.toml:
// [dependencies]
// protobuf-types = { path = "./path/to/rust-bindings" }

// Then use in your code
let mut color = ColorProto::new();
color.set_name("Red".to_string());
color.set_guid("color-123".to_string());
color.set_r(255);
color.set_g(0);
color.set_b(0);
color.set_a(255);

let serialized = color.write_to_bytes().unwrap();
```

## ✨ Benefits

- **🚀 One Command**: Everything happens in a single script execution
- **📦 No Dependencies**: Uses pre-built protoc binaries, no compilation needed
- **🔒 Self-Contained**: Generated code has minimal dependencies
- **🌍 Cross-Platform**: Same proto files work across C++, Python, and Rust
- **⚡ Fast**: No build time, just code generation
- **🎯 Ready-to-Use**: Archives contain everything you need

## 🔧 Technical Details

### Pre-built Protoc Binaries
The system includes protoc 32.1 binaries for:
- `protoc-32.1-linux-x86_64/` - Linux x86_64
- `protoc-32.1-osx-universal_binary/` - macOS Universal (Intel + Apple Silicon)  
- `protoc-32.1-win64/` - Windows x64

### Generated Code Structure
```
generated/
├── cpp/           # C++ .pb.h and .pb.cc files
├── python/        # Python _pb2.py modules  
└── rust/          # Complete Rust crate with Cargo.toml
```

### Archives Created
- **cpp-bindings.tar.gz** / **cpp-bindings.zip** (Windows)
- **python-bindings.tar.gz** / **python-bindings.zip** (Windows)
- **rust-bindings.tar.gz** / **rust-bindings.zip** (Windows)

## 🛠️ Customization

To add your own proto files:
1. Place `.proto` files in the `proto/` directory
2. Update the `MAIN_PROTO_FILES` array in the scripts
3. Run the build script

The system automatically handles imports and dependencies between your proto files.

---

*This system replaces complex protobuf compilation with a simple, one-command solution for generating cross-language serialization code.*
