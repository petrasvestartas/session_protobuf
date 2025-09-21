@echo off
REM Build script for Windows
REM This script builds the protobuf library for Windows using CMake

echo Building protobuf for Windows...

REM Set build configuration (default to Release)
set BUILD_TYPE=Release
if not "%1"=="" set BUILD_TYPE=%1

REM Create build directory
if not exist build mkdir build

REM Configure CMake
echo Configuring CMake...
cmake -S . -B build ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -Dprotobuf_BUILD_TESTS=OFF ^
    -Dprotobuf_BUILD_EXAMPLES=OFF ^
    -Dprotobuf_BUILD_CONFORMANCE=OFF ^
    -Dprotobuf_BUILD_SHARED_LIBS=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -Dprotobuf_BUILD_PROTOBUF_BINARIES=ON ^
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON ^
    -Dprotobuf_FORCE_FETCH_DEPENDENCIES=ON ^
    -Dprotobuf_WITH_ZLIB=OFF

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    exit /b 1
)

REM Build the project
echo Building project...
cmake --build build --config %BUILD_TYPE% --target install -j 8

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b 1
)

echo Build completed successfully!
echo Built libraries and headers are in the install-win64 directory.

REM List the contents of the install directory
if exist install-win64 (
    echo.
    echo Install directory contents:
    dir install-win64 /s /b
)

pause
