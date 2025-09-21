cmake_minimum_required(VERSION 3.22)
project(protobuf_vendor LANGUAGES C CXX)

# Build protobuf with a minimal, fast configuration
set(protobuf_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_CONFORMANCE OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
set(protobuf_BUILD_PROTOC_BINARIES ON CACHE BOOL "" FORCE)
set(protobuf_FORCE_FETCH_DEPENDENCIES ON CACHE BOOL "" FORCE)
set(protobuf_LOCAL_DEPENDENCIES_ONLY OFF CACHE BOOL "" FORCE)

# Determine platform subdirectory for install
if(APPLE)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    set(_PLATFORM "macos-arm64")
  else()
    set(_PLATFORM "macos-x86_64")
  endif()
elseif(WIN32)
  set(_PLATFORM "win64-msvc")
else()
  set(_PLATFORM "linux-x86_64")
endif()

# Default install prefix to third_parties/<platform>/ inside this folder
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/${_PLATFORM}" CACHE PATH "" FORCE)
endif()
message(STATUS "Protobuf vendor install prefix: ${CMAKE_INSTALL_PREFIX}")

# Add upstream protobuf source (parent directory)
# Use a dedicated binary dir to avoid cluttering the vendor build dir
set(_PROTOBUF_BINARY_DIR "${CMAKE_BINARY_DIR}/protobuf-src")
add_subdirectory(".." "${_PROTOBUF_BINARY_DIR}")

# Usage:
#   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
#   cmake --build build --target install -j 8
