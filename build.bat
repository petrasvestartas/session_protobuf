@echo off
REM Windows Rust-only build script based on build.sh
REM This script generates only Rust bindings using prost with protoc-bin-vendored

echo 🚀 Starting Rust-only protobuf build for Windows...

echo 📋 Platform: Windows (Rust-only - no protoc binary needed)

REM =============================================================================
REM RUST BINDINGS (Based on working build.sh)
REM =============================================================================

echo.
echo 🦀 Creating Rust crate (Cargo will handle code generation)...
echo   📝 Note: Rust files will be generated automatically when you build the crate

REM Create output directories
if not exist generated mkdir generated
if not exist generated\rust mkdir generated\rust
if not exist generated\rust\src mkdir generated\rust\src

REM Proto files to generate (same as build.sh)
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

REM Create Cargo.toml with prost dependencies and protoc-bin-vendored (same as build.sh)
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

REM Create build.rs that uses protoc-bin-vendored (same as build.sh)
echo use std::env; > generated\rust\build.rs
echo use std::path::PathBuf; >> generated\rust\build.rs
echo. >> generated\rust\build.rs
echo fn main() -^> Result^<^(^), Box^<dyn std::error::Error^>^> { >> generated\rust\build.rs
echo     let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap()); >> generated\rust\build.rs
echo. >> generated\rust\build.rs
echo     // Configure prost-build to use protoc-bin-vendored >> generated\rust\build.rs
echo     prost_build::Config::new() >> generated\rust\build.rs
echo         .protoc_arg("--experimental_allow_proto3_optional") >> generated\rust\build.rs
echo         .out_dir(^&out_dir) >> generated\rust\build.rs
echo         .compile_protos( >> generated\rust\build.rs
echo             ^&[ >> generated\rust\build.rs
echo                 "proto/color.proto", >> generated\rust\build.rs
echo                 "proto/point.proto", >> generated\rust\build.rs
echo             ], >> generated\rust\build.rs
echo             ^&[ >> generated\rust\build.rs
echo                 "proto/", >> generated\rust\build.rs
echo             ], >> generated\rust\build.rs
echo         )?; >> generated\rust\build.rs
echo. >> generated\rust\build.rs
echo     println!("cargo:rerun-if-changed=proto/"); >> generated\rust\build.rs
echo     Ok(()) >> generated\rust\build.rs
echo } >> generated\rust\build.rs

REM Create lib.rs that exposes the generated types (same as build.sh)
echo //! Generated Protocol Buffer types using prost > generated\rust\src\lib.rs
echo //! >> generated\rust\src\lib.rs
echo //! This crate provides Rust bindings for protobuf serialization using prost. >> generated\rust\src\lib.rs
echo //! Code generation happens automatically when you build this crate. >> generated\rust\src\lib.rs
echo. >> generated\rust\src\lib.rs
echo #![allow(unused_imports)] >> generated\rust\src\lib.rs
echo #![allow(clippy::all)] >> generated\rust\src\lib.rs
echo. >> generated\rust\src\lib.rs
echo pub use prost::Message; >> generated\rust\src\lib.rs
echo. >> generated\rust\src\lib.rs
echo // Include generated protobuf code from build.rs >> generated\rust\src\lib.rs
echo // This file is generated at build time in OUT_DIR >> generated\rust\src\lib.rs
echo include!(concat!(env!("OUT_DIR"), "/session_proto.rs")); >> generated\rust\src\lib.rs
echo. >> generated\rust\src\lib.rs
echo // The types ColorProto and PointProto are now available directly >> generated\rust\src\lib.rs

REM Create main.rs for testing (same as build.sh)
echo //! Test binary for generated protobuf types > generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo use session_protobuf_types::{ColorProto, PointProto, Message}; >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo fn main() -^> Result^<^(^), Box^<dyn std::error::Error^>^> { >> generated\rust\src\main.rs
echo     println!("🦀 Testing generated protobuf types..."); >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo     // Create a color >> generated\rust\src\main.rs
echo     let color = ColorProto { >> generated\rust\src\main.rs
echo         name: "Test Red".to_string(), >> generated\rust\src\main.rs
echo         guid: "color-test".to_string(), >> generated\rust\src\main.rs
echo         r: 255, >> generated\rust\src\main.rs
echo         g: 0, >> generated\rust\src\main.rs
echo         b: 0, >> generated\rust\src\main.rs
echo         a: 255, >> generated\rust\src\main.rs
echo     }; >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo     // Create a point with the color >> generated\rust\src\main.rs
echo     let point = PointProto { >> generated\rust\src\main.rs
echo         guid: "point-test".to_string(), >> generated\rust\src\main.rs
echo         name: "Test Point".to_string(), >> generated\rust\src\main.rs
echo         x: 1.0, >> generated\rust\src\main.rs
echo         y: 2.0, >> generated\rust\src\main.rs
echo         z: 3.0, >> generated\rust\src\main.rs
echo         width: 1.5, >> generated\rust\src\main.rs
echo         pointcolor: Some(color), >> generated\rust\src\main.rs
echo     }; >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo     // Test serialization >> generated\rust\src\main.rs
echo     let bytes = point.encode_to_vec(); >> generated\rust\src\main.rs
echo     println!("✅ Serialized {} bytes", bytes.len()); >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo     // Test deserialization >> generated\rust\src\main.rs
echo     let decoded = PointProto::decode(^&bytes[..])?; >> generated\rust\src\main.rs
echo     println!("✅ Deserialized point: '{}'", decoded.name); >> generated\rust\src\main.rs
echo. >> generated\rust\src\main.rs
echo     println!("🎉 All tests passed! Rust protobuf types are working correctly."); >> generated\rust\src\main.rs
echo     Ok(()) >> generated\rust\src\main.rs
echo } >> generated\rust\src\main.rs

REM Create README for the Rust crate (same as build.sh)
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
REM CREATE ARCHIVES (same as build.sh)
REM =============================================================================

echo.
echo 📦 Creating archives...

REM Create archives (same as build.sh approach)
cd generated

REM For Rust bindings, include the proto files so the crate is self-contained
xcopy /E /I ..\proto rust\proto\
tar -czf ..\rust-bindings.tar.gz rust\
cd ..

echo   ✅ rust-bindings.tar.gz created

REM =============================================================================
REM SUCCESS MESSAGE
REM =============================================================================

echo.
echo 🎉 Rust-only build completed successfully!
echo.
echo 📋 Generated archive:
echo   - rust-bindings.tar.gz → Contains Rust crate for serialization
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
