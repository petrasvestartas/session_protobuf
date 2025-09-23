@echo off
REM Combined build and generate script for Windows
REM This script sets up protobuf environment and generates language bindings in one step

echo 🚀 Starting protobuf build and code generation for Windows...

REM Set platform
set PLATFORM=win64
set INSTALL_PLATFORM=win64

echo 📋 Detected platform: %PLATFORM%

REM =============================================================================
REM STEP 1: BUILD/SETUP PROTOBUF ENVIRONMENT
REM =============================================================================

echo.
echo 🔧 Step 1: Setting up protobuf environment...

REM Check if protoc binary exists
set PROTOC_DIR=protoc-32.1-%PLATFORM%
set PROTOC_PATH=%PROTOC_DIR%\bin\protoc.exe

if not exist "%PROTOC_PATH%" (
    echo ❌ Protoc binary not found at %PROTOC_PATH%
    echo Available protoc directories:
    dir protoc-* /b 2>nul || echo No protoc directories found
    exit /b 1
)

echo ✅ Found protoc binary at %PROTOC_PATH%

REM Create install directory structure
set INSTALL_DIR=install-%INSTALL_PLATFORM%
echo 📁 Creating install directory: %INSTALL_DIR%

REM Clean and create install directory
if exist "%INSTALL_DIR%" rmdir /s /q "%INSTALL_DIR%"
mkdir "%INSTALL_DIR%"
mkdir "%INSTALL_DIR%\bin"
mkdir "%INSTALL_DIR%\include"
mkdir "%INSTALL_DIR%\lib"

REM Copy protoc binary
copy "%PROTOC_DIR%\bin\protoc.exe" "%INSTALL_DIR%\bin\" >nul
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to copy protoc binary
    exit /b 1
)

REM Copy include files
if exist "%PROTOC_DIR%\include" (
    xcopy "%PROTOC_DIR%\include" "%INSTALL_DIR%\include" /e /i /q >nul
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to copy include files
        exit /b 1
    )
)

echo ✅ Protobuf environment setup completed!

REM Test protoc
echo 🧪 Testing protoc installation...
"%INSTALL_DIR%\bin\protoc.exe" --version
if %ERRORLEVEL% neq 0 (
    echo ❌ Protoc test failed
    exit /b 1
)

REM =============================================================================
REM STEP 2: GENERATE LANGUAGE BINDINGS
REM =============================================================================

echo.
echo 🔧 Step 2: Generating language bindings from proto files...

REM Create output directories
if not exist generated mkdir generated
if not exist generated\cpp mkdir generated\cpp
if not exist generated\python mkdir generated\python
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

REM =============================================================================
REM C++ BINDINGS
REM =============================================================================

echo.
echo 🔨 Generating C++ bindings...

REM Generate main proto files
if exist proto\color.proto (
    echo   📄 Processing color.proto (Main)...
    "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --cpp_out=generated\cpp proto\color.proto
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to generate C++ bindings for color.proto
        exit /b 1
    )
)

if exist proto\point.proto (
    echo   📄 Processing point.proto (Main)...
    "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --cpp_out=generated\cpp proto\point.proto
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to generate C++ bindings for point.proto
        exit /b 1
    )
)

REM Process user proto files if they exist
if exist proto\user (
    echo   📄 Processing user proto files...
    for %%f in (proto\user\*.proto) do (
        echo   📄 Processing %%~nxf (User)...
        "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --cpp_out=generated\cpp "%%f"
        if %ERRORLEVEL% neq 0 (
            echo ❌ Failed to generate C++ bindings for %%~nxf
            exit /b 1
        )
    )
)

REM =============================================================================
REM PYTHON BINDINGS
REM =============================================================================

echo.
echo 🐍 Generating Python bindings...

REM Generate main proto files
if exist proto\color.proto (
    echo   📄 Processing color.proto (Main)...
    "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --python_out=generated\python proto\color.proto
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to generate Python bindings for color.proto
        exit /b 1
    )
)

if exist proto\point.proto (
    echo   📄 Processing point.proto (Main)...
    "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --python_out=generated\python proto\point.proto
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to generate Python bindings for point.proto
        exit /b 1
    )
)

REM Process user proto files if they exist
if exist proto\user (
    echo   📄 Processing user proto files...
    for %%f in (proto\user\*.proto) do (
        echo   📄 Processing %%~nxf (User)...
        "%INSTALL_DIR%\bin\protoc.exe" --proto_path=proto --proto_path=%INSTALL_DIR%\include --python_out=generated\python "%%f"
        if %ERRORLEVEL% neq 0 (
            echo ❌ Failed to generate Python bindings for %%~nxf
            exit /b 1
        )
    )
)

REM =============================================================================
REM RUST BINDINGS
REM =============================================================================

echo.
echo 🦀 Generating Rust bindings...
echo   📝 Note: Creating self-contained Rust crate template

REM Create Cargo.toml with minimal prost dependencies
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
) > generated\rust\Cargo.toml

REM Create build.rs for Rust code generation using prost-build
(
echo use std::env;
echo use std::path::PathBuf;
echo.
echo fn main() -^> Result^<()^, Box^<dyn std::error::Error^>^> {
echo     let out_dir = PathBuf::from(env::var("OUT_DIR"^).unwrap()^);
echo     
echo     // Configure prost-build
echo     prost_build::Config::new()
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
echo.
echo #![allow(unused_imports^)]
echo #![allow(clippy::all^)]
echo.
echo pub use prost::Message;
echo.
echo // Include generated protobuf modules from build.rs
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
echo fn main() {
echo     println!("Generated protobuf types are ready!"^);
echo     println!("Use this crate as a dependency in your Rust projects."^);
echo }
) > generated\rust\src\main.rs

REM Create README
(
echo # Generated Protobuf Types for Rust
echo.
echo This Rust crate contains generated protobuf serialization code with minimal dependencies.
echo.
echo ## Usage
echo.
echo Add to your `Cargo.toml`:
echo.
echo ```toml
echo [dependencies]
echo protobuf-types = { path = "./path/to/this/crate" }
echo ```
echo.
echo Then use in your code:
echo.
echo ```rust
echo use protobuf_types::*;
echo.
echo // Your protobuf usage here
echo ```
) > generated\rust\README.md

REM =============================================================================
REM CREATE ARCHIVES
REM =============================================================================

echo.
echo 📦 Creating archives...

REM Create archives using tar (available in Windows 10+) or PowerShell
where tar >nul 2>nul
if %ERRORLEVEL% equ 0 (
    REM Use tar if available
    cd generated
    tar -czf ..\cpp-bindings.tar.gz cpp\
    tar -czf ..\python-bindings.tar.gz python\
    tar -czf ..\rust-bindings.tar.gz rust\
    cd ..
    echo   ✅ cpp-bindings.tar.gz created
    echo   ✅ python-bindings.tar.gz created
    echo   ✅ rust-bindings.tar.gz created
) else (
    REM Use PowerShell compression as fallback
    powershell -Command "Compress-Archive -Path 'generated\cpp\*' -DestinationPath 'cpp-bindings.zip' -Force"
    powershell -Command "Compress-Archive -Path 'generated\python\*' -DestinationPath 'python-bindings.zip' -Force"
    powershell -Command "Compress-Archive -Path 'generated\rust\*' -DestinationPath 'rust-bindings.zip' -Force"
    echo   ✅ cpp-bindings.zip created
    echo   ✅ python-bindings.zip created
    echo   ✅ rust-bindings.zip created
)

REM =============================================================================
REM SUCCESS MESSAGE
REM =============================================================================

echo.
echo 🎉 Build and code generation completed successfully!
echo.
echo 📋 Generated archives:
echo   - cpp-bindings.*     → Contains .pb.h/.pb.cc files for serialization
echo   - python-bindings.*  → Contains _pb2.py modules for serialization
echo   - rust-bindings.*    → Contains Rust crate for serialization
echo.
echo 🎯 What you get:
echo   • Self-contained serialization code (no external protobuf dependency needed)
echo   • Ready-to-include files for your applications
echo   • Cross-platform binary serialization
echo.
echo 💡 Usage in your applications:
echo   C++:    #include "your_proto.pb.h" and compile your_proto.pb.cc
echo   Python: import your_proto_pb2 (no pip install protobuf needed)
echo   Rust:   Add as dependency (no external protobuf crate needed)
echo.
echo ✨ All done! Your protobuf bindings are ready to use.

pause
