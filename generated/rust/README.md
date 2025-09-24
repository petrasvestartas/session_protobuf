# Generated Protobuf Types for Rust

This Rust crate contains protobuf serialization code using `prost` with automatic code generation.

## Features

- ✅ **No System Dependencies**: Uses `protoc-bin-vendored` for automatic protoc installation
- ✅ **Build-Time Generation**: Rust code is generated automatically when you build
- ✅ **Minimal Dependencies**: Only requires `prost` at runtime
- ✅ **Cross-Platform**: Works on Windows, Linux, and macOS

## Usage

Add to your `Cargo.toml`:

```toml
[dependencies]
session-protobuf-types = { path = "./path/to/this/crate" }
```

Then use in your code:

```rust
use session_protobuf_types::{ColorProto, PointProto, Message};

// Create and serialize data
let color = ColorProto {
    name: "Red".to_string(),
    guid: "color-123".to_string(),
    r: 255, g: 0, b: 0, a: 255,
};

let bytes = color.encode_to_vec();
let decoded = ColorProto::decode(&bytes[..])?;
```

## Building

```bash
cargo build    # Generates Rust code and builds the crate
cargo test     # Run tests
cargo run      # Run the example
```

The protobuf code generation happens automatically during the build process.
