# User Proto Files

Place your custom `.proto` files in this directory to generate language-specific serialization code.

## How it works

1. **Add your `.proto` files** to this directory
2. **Run the build** (GitHub Actions or locally)
3. **Download the generated bindings** from the release

## Example Structure

```
proto/user/
├── point.proto      # Your 3D point definition
├── color.proto      # Your color definition  
├── mesh.proto       # Your mesh definition
└── scene.proto      # Your scene definition
```

## Generated Output

For each `.proto` file, you'll get:

### C++
- `point.pb.h` / `point.pb.cc` - Header and implementation
- `color.pb.h` / `color.pb.cc` - Header and implementation

### Python  
- `point_pb2.py` - Python serialization module
- `color_pb2.py` - Python serialization module

### Rust
- Complete Cargo crate with all your types
- Ready to use with `cargo add` or as a path dependency

## Usage in Your Application

### C++ (No external dependencies)
```cpp
#include "point.pb.h"  // Generated from your point.proto

Point p;
p.set_x(1.0);
p.set_y(2.0);
p.set_z(3.0);

// Serialize to bytes
std::string serialized = p.SerializeAsString();

// Deserialize from bytes
Point p2;
p2.ParseFromString(serialized);
```

### Python (No pip install needed)
```python
import point_pb2  # Generated from your point.proto

p = point_pb2.Point()
p.x = 1.0
p.y = 2.0
p.z = 3.0

# Serialize to bytes
serialized = p.SerializeToString()

# Deserialize from bytes
p2 = point_pb2.Point()
p2.ParseFromString(serialized)
```

### Rust (No external crates needed)
```rust
use your_proto_crate::Point;

let mut p = Point::new();
p.set_x(1.0);
p.set_y(2.0);
p.set_z(3.0);

// Serialize to bytes
let serialized = p.write_to_bytes().unwrap();

// Deserialize from bytes
let p2 = Point::parse_from_bytes(&serialized).unwrap();
```

## Benefits

✅ **No External Dependencies**: All serialization code is self-contained  
✅ **Version Locked**: Generated from the same protobuf version  
✅ **Cross-Platform**: Works on Windows, Linux, macOS  
✅ **Multiple Languages**: C++, Python, Rust from same `.proto` files
