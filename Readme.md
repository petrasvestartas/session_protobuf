# Protobuf vendor build (headers + static libs)

This folder lets you build Protocol Buffers (C++ runtime + protoc) **once per OS** and reuse the headers and static libraries from your application build. No package managers needed after this step.

After installing, you will have a per‑platform directory like:

- `macos-arm64/`
- `linux-x86_64/`
- `win64-msvc/`

Each contains:

- `include/` — protobuf headers
- `lib/` — static libraries, e.g. `libprotobuf.a`, `libprotoc.a`, `libprotobuf-lite.a`, and small third‑party archives (e.g. `utf8_range`)
- `bin/` — tools including a matching `protoc`

## One‑time build per OS

You can build protobuf using either the provided build scripts or manual CMake commands.

### Option 1: Using Build Scripts (Recommended)

#### Windows
```bat
build.bat
```
Or with custom build type:
```bat
build.bat Debug
```

#### Linux/macOS
```bash
./build.sh
```
Or with custom build type:
```bash
./build.sh Debug
```

The build scripts automatically detect your platform and install to the appropriate directory:
- `install-win64/` on Windows
- `install-linux-x86_64/` on Linux
- `install-macos-arm64/` or `install-macos-x86_64/` on macOS

### Option 2: Manual CMake Commands

#### macOS (arm64 or x86_64)
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target install -j 8
```
This installs into `macos-arm64/` (or `macos-x86_64/`) automatically.

#### Linux (x86_64)
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target install -j 8
```
Installs into `linux-x86_64/`.

#### Windows (MSVC)
Run from a "x64 Native Tools Command Prompt for VS".
```bat
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target INSTALL --config Release
```
Installs into `win64-msvc/`.

### Option 3: Download Pre-built Releases

Instead of building locally, you can download pre-built libraries from the [GitHub Releases](../../releases) page. Each release contains:

- **Windows (x64)**: `protobuf-win64.zip`
- **Linux (x86_64)**: `protobuf-linux-x86_64.tar.gz`
- **macOS (Intel)**: `protobuf-macos-x86_64.tar.gz`
- **macOS (Apple Silicon)**: `protobuf-macos-arm64.tar.gz`

Simply download and extract the appropriate archive for your platform.

## Automated Builds with GitHub Actions

This repository includes a GitHub Actions workflow (`.github/workflows/build-and-release.yml`) that automatically:

1. **Builds protobuf** on all supported platforms (Windows, Linux, macOS Intel, macOS Apple Silicon)
2. **Creates artifacts** for each platform containing the built libraries and headers
3. **Creates GitHub releases** when you push a tag (e.g., `v1.0.0`)

### Triggering a Release

To create a new release with pre-built binaries:

1. Tag your commit:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. The GitHub Actions workflow will automatically:
   - Build on all platforms
   - Create a new GitHub release
   - Upload the built artifacts to the release

### Manual Workflow Trigger

You can also manually trigger the build workflow from the GitHub Actions tab in your repository.

### Local Testing with Act

Before pushing to GitHub, you can test the workflows locally using [Act](https://github.com/nektos/act):

```bash
# Quick test (recommended first)
./test-with-act.sh

# Full workflow test
act workflow_dispatch -W .github/workflows/build-and-release.yml
```

See [ACT_TESTING.md](ACT_TESTING.md) for detailed instructions on local testing.

Notes:
- Builds are configured to produce **static** libraries for easy vendoring.
- We only build what’s needed (no tests, examples, etc.) to keep build time down.
- The build also installs a matching `protoc` binary under `<platform>/bin/`.
- The `.gitignore` file excludes build artifacts and install directories from version control.

## Using the vendor outputs in your app CMake

In your main CMake (e.g. `session_cpp/CMakeLists.txt`), prefer the vendor install if present and fall back to another approach otherwise.

```cmake
# Detect vendor protobuf install
set(PROTO_VENDOR_ROOT ${PROJECT_SOURCE_DIR}/src/third_parties)
if(APPLE)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    set(PROTO_VENDOR_DIR ${PROTO_VENDOR_ROOT}/macos-arm64)
  else()
    set(PROTO_VENDOR_DIR ${PROTO_VENDOR_ROOT}/macos-x86_64)
  endif()
elseif(WIN32)
  set(PROTO_VENDOR_DIR ${PROTO_VENDOR_ROOT}/win64-msvc)
else()
  set(PROTO_VENDOR_DIR ${PROTO_VENDOR_ROOT}/linux-x86_64)
endif()

if(EXISTS ${PROTO_VENDOR_DIR}/include AND EXISTS ${PROTO_VENDOR_DIR}/lib)
  message(STATUS "Using vendor protobuf at: ${PROTO_VENDOR_DIR}")

  # Headers
  target_include_directories(session_core SYSTEM PUBLIC ${PROTO_VENDOR_DIR}/include)

  # Link static libprotobuf
  if(WIN32)
    # If using MSVC, you may need to link by name and ensure lib path is set
    target_link_directories(session_core PUBLIC ${PROTO_VENDOR_DIR}/lib)
    target_link_libraries(session_core PUBLIC protobuf) # or libprotobuf
  else()
    # Link by full path for robustness
    target_link_libraries(session_core PUBLIC ${PROTO_VENDOR_DIR}/lib/libprotobuf.a)

    # If you hit unresolved symbols, also link the small utf8 archives:
    # target_link_libraries(session_core PUBLIC \
    #   ${PROTO_VENDOR_DIR}/lib/third_party/utf8_range/libutf8_range.a \
    #   ${PROTO_VENDOR_DIR}/lib/third_party/utf8_range/libutf8_validity.a)
  endif()

  # Use matching protoc for code generation
  set(PROTOC_EXECUTABLE ${PROTO_VENDOR_DIR}/bin/protoc)
  # Example custom generation (adjust to your project):
  # add_custom_command(
  #   OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/example.pb.cc ${CMAKE_CURRENT_BINARY_DIR}/example.pb.h
  #   COMMAND ${PROTOC_EXECUTABLE}
  #           --cpp_out=${CMAKE_CURRENT_BINARY_DIR}
  #           --proto_path=${PROJECT_SOURCE_DIR}/../session_proto
  #           ${PROJECT_SOURCE_DIR}/../session_proto/example.proto
  #   DEPENDS ${PROJECT_SOURCE_DIR}/../session_proto/example.proto
  # )
else()
  message(WARNING "Vendor protobuf not found under ${PROTO_VENDOR_DIR}. Consider building it here or use an alternative (source build/package manager).")
endif()
```

## Clean / rebuild

```bash
# From this folder
rm -rf build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target install -j 8
```

## FAQ

- Do I need Abseil libs?
  - The static `libprotobuf.a` here may work as‑is for many use cases. If you see unresolved symbols at link time, link the extra small archives under `lib/third_party/utf8_range/`. If further issues arise, you can glob and link all `.a` files in `lib/`.

- Why vendor?
  - This avoids protocol buffer version mismatches and removes the need to rebuild protobuf during normal app development. You build it once per OS, then your app builds are fast.
