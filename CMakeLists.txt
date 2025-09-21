cmake_minimum_required(VERSION 3.22)
project(protobuf LANGUAGES C CXX)

# Follow upstream guidance: build in-tree from this directory, using upstream cmake modules.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Options per README
set(protobuf_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_CONFORMANCE OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_PROTOBUF_BINARIES ON CACHE BOOL "" FORCE)
set(protobuf_BUILD_PROTOC_BINARIES ON CACHE BOOL "" FORCE)
set(protobuf_FORCE_FETCH_DEPENDENCIES ON CACHE BOOL "" FORCE)
set(protobuf_LOCAL_DEPENDENCIES_ONLY OFF CACHE BOOL "" FORCE)
# Avoid requiring zlib for gzip streams in libprotobuf
set(protobuf_WITH_ZLIB OFF CACHE BOOL "" FORCE)

# Prevent accidental libatomic link before targets exist
set(protobuf_LINK_LIBATOMIC OFF CACHE BOOL "" FORCE)
set(protobuf_HAVE_BUILTIN_ATOMICS TRUE CACHE BOOL "" FORCE)

# Platform-specific install directory to avoid cross-platform conflicts
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # Determine platform suffix
  if(APPLE)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
      set(PLATFORM_SUFFIX "macos-arm64")
    else()
      set(PLATFORM_SUFFIX "macos-x86_64")
    endif()
  elseif(WIN32)
    set(PLATFORM_SUFFIX "win64")
  else()
    set(PLATFORM_SUFFIX "linux-x86_64")
  endif()
  
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/install-${PLATFORM_SUFFIX}" CACHE PATH "" FORCE)
endif()
message(STATUS "Protobuf install prefix: ${CMAKE_INSTALL_PREFIX}")

# Delegate to upstream protobuf source located in ./src
set(_UPSTREAM_SRC "${CMAKE_CURRENT_LIST_DIR}/src")
set(_UPSTREAM_BIN "${CMAKE_BINARY_DIR}/upstream")
add_subdirectory("${_UPSTREAM_SRC}" "${_UPSTREAM_BIN}")

# Usage (from this directory):
#   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS=OFF
#   cmake --build build --target install -j 8
