#!/bin/bash

# Validation script to check if the build system is properly set up

set -e

echo "🔍 Validating Build System Setup"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_file() {
    if [ -f "$1" ]; then
        echo -e "✅ ${GREEN}$1${NC} exists"
        return 0
    else
        echo -e "❌ ${RED}$1${NC} missing"
        return 1
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "✅ ${GREEN}$1${NC} is executable"
        return 0
    else
        echo -e "❌ ${RED}$1${NC} is not executable"
        return 1
    fi
}

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "✅ ${GREEN}$1${NC} is available"
        return 0
    else
        echo -e "⚠️ ${YELLOW}$1${NC} is not installed (optional for local testing)"
        return 1
    fi
}

# Validation results
errors=0

echo ""
echo "📁 Checking build scripts..."
check_file "build.bat" || ((errors++))
check_file "build.sh" || ((errors++))
check_executable "build.sh" || ((errors++))

echo ""
echo "📁 Checking GitHub Actions workflows..."
check_file ".github/workflows/build-and-release.yml" || ((errors++))
check_file ".github/workflows/test-build.yml" || ((errors++))

echo ""
echo "📁 Checking Act configuration..."
check_file ".actrc" || ((errors++))
check_file "test-with-act.sh" || ((errors++))
check_executable "test-with-act.sh" || ((errors++))
check_file "ACT_TESTING.md" || ((errors++))

echo ""
echo "📁 Checking project structure..."
check_file "CMakeLists.txt" || ((errors++))
check_file "README.md" || ((errors++))
check_file ".gitignore" || ((errors++))

if [ -d "src" ]; then
    echo -e "✅ ${GREEN}src/${NC} directory exists"
    # Check if it's a Git submodule
    if [ -f ".gitmodules" ]; then
        echo -e "✅ ${GREEN}src/${NC} is configured as Git submodule"
        if [ -f "src/CMakeLists.txt" ]; then
            echo -e "✅ ${GREEN}Submodule${NC} is properly initialized"
        else
            echo -e "⚠️ ${YELLOW}Submodule${NC} not initialized. Run: git submodule update --init --recursive"
        fi
    fi
else
    echo -e "❌ ${RED}src/${NC} directory missing"
    ((errors++))
fi

echo ""
echo "🛠️ Checking build dependencies..."
check_command "cmake"
check_command "git"

echo ""
echo "🐳 Checking Act dependencies (for local testing)..."
check_command "act"
check_command "docker"

echo ""
echo "📋 Testing build script syntax..."
if bash -n build.sh; then
    echo -e "✅ ${GREEN}build.sh${NC} syntax is valid"
else
    echo -e "❌ ${RED}build.sh${NC} has syntax errors"
    ((errors++))
fi

echo ""
echo "📋 Testing CMake configuration..."
if [ -d "build" ]; then
    echo -e "⚠️ ${YELLOW}build/${NC} directory exists (previous build)"
fi

# Test CMake configuration without building
mkdir -p test-config
if cmake -S . -B test-config \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    &> /dev/null; then
    echo -e "✅ ${GREEN}CMake configuration${NC} is valid"
    rm -rf test-config
else
    echo -e "❌ ${RED}CMake configuration${NC} failed"
    rm -rf test-config
    ((errors++))
fi

echo ""
echo "📊 Validation Summary"
echo "===================="

if [ $errors -eq 0 ]; then
    echo -e "🎉 ${GREEN}All checks passed!${NC}"
    echo ""
    echo "✨ Your build system is ready to use:"
    echo "   • Run './build.sh' to build locally"
    echo "   • Run './test-with-act.sh' to test with Act"
    echo "   • Push a tag (e.g., 'v1.0.0') to create a release"
    echo ""
    echo "📖 See ACT_TESTING.md for detailed testing instructions"
else
    echo -e "⚠️ ${YELLOW}Found $errors issues${NC}"
    echo ""
    echo "🔧 Please fix the issues above before proceeding"
fi

exit $errors
