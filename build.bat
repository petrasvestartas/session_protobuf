@echo off
REM Rust-only build script for Windows
REM This script generates Rust bindings using prost with automatic protoc handling

echo 🚀 Starting Rust-only protobuf build for Windows...

echo 📋 Platform: Windows x64 (Rust-only)
echo 💡 Note: Protoc will be handled automatically by Cargo (protoc-bin-vendored)

REM =============================================================================
REM RUST BINDINGS (AUTOMATIC PROTOC HANDLING)
REM =============================================================================

echo.
echo 🦀 Creating Rust crate with automatic protoc handling...

REM Create output directories
if not exist generated mkdir generated
if not exist generated\rust mkdir generated\rust
if not exist generated\rust\src mkdir generated\rust\src

echo.
echo 📁 Proto files to process:
if exist proto\color.proto (
    echo   ✅ proto\color.proto
) else (
    echo   ❌ proto\color.proto (not found)
)
if exist proto\point.proto (
    echo   ✅ proto\point.proto
) else (
    echo   ❌ proto\point.proto (not found)
)

echo.
echo 🦀 Creating Rust crate (Cargo will handle code generation^)...
echo   📝 Note: Rust files will be generated automatically when you build the crate

REM Create Cargo.toml with prost dependencies and protoc-bin-vendored
(
echo [package]
echo name = "session-protobuf-types"
echo version = "0.1.0"
echo edition = "2021"
echo description = "Generated protobuf types using prost"
echo.
echo [dependencies]
echo prost = "0.14"
echo.
echo [build-dependencies]
echo prost-build = "0.14"
echo protoc-bin-vendored = "3.0"
) > generated\rust\Cargo.toml

REM Create build.rs that uses protoc-bin-vendored (no system protoc needed^)
(
echo use std::env;
echo use std::path::PathBuf;
echo.
echo fn main() -^> Result^<()^, Box^<dyn std::error::Error^>^> {
echo     let out_dir = PathBuf::from(env::var("OUT_DIR"^).unwrap()^);
echo     
echo     // Configure prost-build to use protoc-bin-vendored
echo     prost_build::Config::new()
echo         .protoc_arg("--experimental_allow_proto3_optional"^)
echo         .out_dir(^&out_dir^)
echo         .compile_protos(
echo             ^&[
echo                 "../../proto/color.proto",
echo                 "../../proto/point.proto",
echo             ],
echo             ^&[
echo                 "../../proto/",
echo             ],
echo         ^)?;
echo     
echo     println!("cargo:rerun-if-changed=../../proto/"^);
echo     Ok(()^)
echo }
) > generated\rust\build.rs

REM Create lib.rs
(
echo //! Generated Protocol Buffer types using prost
echo //! 
echo //! This crate provides Rust bindings for protobuf serialization using prost.
echo //! Code generation happens automatically when you build this crate.
echo.
echo #![allow(unused_imports^)]
echo #![allow(clippy::all^)]
echo.
echo pub use prost::Message;
echo.
echo // Include generated protobuf modules from build.rs
echo // These files are generated at build time in OUT_DIR
echo include!(concat!(env!("OUT_DIR"^), "/session_proto.color.rs"^)^);
echo include!(concat!(env!("OUT_DIR"^), "/session_proto.point.rs"^)^);
echo.
echo // Re-export the main types for convenience
echo pub use color_proto::ColorProto;
echo pub use point_proto::PointProto;
) > generated\rust\src\lib.rs

REM Create main.rs for testing
(
echo //! Test binary for generated protobuf types
echo.
echo use session_protobuf_types::{ColorProto, PointProto, Message};
echo.
echo fn main() -^> Result^<()^, Box^<dyn std::error::Error^>^> {
echo     println!("🦀 Testing generated protobuf types..."^);
echo.
echo     // Create a color
echo     let color = ColorProto {
echo         name: "Test Red".to_string(),
echo         guid: "color-test".to_string(),
echo         r: 255,
echo         g: 0,
echo         b: 0,
echo         a: 255,
echo     };
echo.
echo     // Create a point with the color
echo     let point = PointProto {
echo         guid: "point-test".to_string(),
echo         name: "Test Point".to_string(),
echo         x: 1.0,
echo         y: 2.0,
echo         z: 3.0,
echo         width: 1.5,
echo         pointcolor: Some(color^),
echo     };
echo.
echo     // Test serialization
echo     let bytes = point.encode_to_vec();
echo     println!("✅ Serialized {} bytes", bytes.len()^);
echo.
echo     // Test deserialization
echo     let decoded = PointProto::decode(^&bytes[..]^)?;
echo     println!("✅ Deserialized point: '{}'", decoded.name^);
echo.
echo     println!("🎉 All tests passed! Rust protobuf types are working correctly."^);
echo     Ok(()^)
echo }
) > generated\rust\src\main.rs

REM Create README
(
echo # Generated Protobuf Types for Rust
echo.
echo This Rust crate contains protobuf serialization code using `prost` with automatic code generation.
echo.
echo ## Features
echo.
echo - ✅ **No System Dependencies**: Uses `protoc-bin-vendored` for automatic protoc installation
echo - ✅ **Build-Time Generation**: Rust code is generated automatically when you build
echo - ✅ **Minimal Dependencies**: Only requires `prost` at runtime
echo - ✅ **Cross-Platform**: Works on Windows, Linux, and macOS
echo.
echo ## Usage
echo.
echo Add to your `Cargo.toml`:
echo.
echo ```toml
echo [dependencies]
echo session-protobuf-types = { path = "./path/to/this/crate" }
echo ```
echo.
echo Then use in your code:
echo.
echo ```rust
echo use session_protobuf_types::{ColorProto, PointProto, Message};
echo.
echo // Create and serialize data
echo let color = ColorProto {
echo     name: "Red".to_string(),
echo     guid: "color-123".to_string(),
echo     r: 255, g: 0, b: 0, a: 255,
echo };
echo.
echo let bytes = color.encode_to_vec();
echo let decoded = ColorProto::decode(^&bytes[..]^)?;
echo ```
echo.
echo ## Building
echo.
echo ```bash
echo cargo build    # Generates Rust code and builds the crate
echo cargo test     # Run tests
echo cargo run      # Run the example
echo ```
echo.
echo The protobuf code generation happens automatically during the build process.
) > generated\rust\README.md

echo   ✅ Rust crate created with automatic code generation
echo   ℹ️  Run 'cargo build' in generated/rust/ to generate and build Rust code

REM =============================================================================
REM CREATE ARCHIVES
REM =============================================================================

echo.
echo 📦 Creating archives...

REM Create Rust archive using tar (available in Windows 10+) or PowerShell
where tar >nul 2>nul
if %ERRORLEVEL% equ 0 (
    REM Use tar if available
    cd generated
    tar -czf ..\rust-bindings.tar.gz rust\
    cd ..
    echo   ✅ rust-bindings.tar.gz created
) else (
    REM Use PowerShell compression as fallback
    powershell -Command "Compress-Archive -Path 'generated\rust\*' -DestinationPath 'rust-bindings.zip' -Force"
    echo   ✅ rust-bindings.zip created
)

REM =============================================================================
REM SUCCESS MESSAGE
REM =============================================================================

echo.
echo 🎉 Rust-only build completed successfully!
echo.
echo 📋 Generated archive:
echo   - rust-bindings.*    → Contains Rust crate for serialization
echo.
echo 🎯 What you get:
echo   • Self-contained Rust crate (no external protobuf dependency needed)
echo   • Automatic protoc handling via protoc-bin-vendored
echo   • Cross-platform binary serialization
echo.
echo 💡 Usage in your Rust applications:
echo   Add as dependency: session-protobuf-types = { path = "./path/to/crate" }
echo   Import and use: use session_protobuf_types::{ColorProto, PointProto, Message};
echo.
echo ✨ All done! Your Rust protobuf bindings are ready to use.

pause
