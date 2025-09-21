# Generated Protobuf Types for Rust

This Rust crate contains generated protobuf serialization code with minimal dependencies.

## Features

- ✅ **Minimal Dependencies**: Only requires protobuf runtime (no codegen at runtime)
- ✅ **Pre-Generated**: All code generation happens at build time
- ✅ **Version Locked**: Uses the same protobuf version as C++/Python bindings
- ✅ **Cross-Platform**: Compatible binary format with other languages

## Usage

1. **Add to your project:**

```toml
[dependencies]
protobuf-types = { path = "./path/to/this/crate" }
```

2. **Use the generated types:**

```rust
use protobuf_types::*;

// Example with your proto definitions
// (actual types depend on your .proto files)

// For point.proto:
let mut point = geometry::Point::new();
point.set_x(1.0);
point.set_y(2.0);
point.set_z(3.0);

// Serialize to bytes
let bytes = point.write_to_bytes().unwrap();

// Deserialize from bytes
let point2 = geometry::Point::parse_from_bytes(&bytes).unwrap();

// For color.proto:
let mut color = graphics::Color::new();
color.set_red(255);
color.set_green(128);
color.set_blue(64);
color.set_alpha(255);

let color_bytes = color.write_to_bytes().unwrap();
```

## Building

The crate will automatically generate Rust code from your .proto files when you run `cargo build`.

## Dependencies

- `protobuf` (runtime only, ~50KB) - provides serialization/deserialization
- `protobuf-codegen` (build-time only) - generates Rust code from .proto files

This is much lighter than using the full protobuf ecosystem!
