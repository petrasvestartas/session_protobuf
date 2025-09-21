#!/bin/bash

# Script to test GitHub Actions locally with Act
# Make sure you have Act installed: brew install act

set -e

echo "🚀 Testing GitHub Actions locally with Act"
echo "=========================================="

# Check if Act is installed
if ! command -v act &> /dev/null; then
    echo "❌ Act is not installed. Please install it first:"
    echo "   macOS: brew install act"
    echo "   Linux: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    echo "   Windows: choco install act-cli"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Act and Docker are available"
echo ""

# Show available workflows
echo "📋 Available workflows:"
act -l
echo ""

# Test the simplified workflow
echo "🧪 Testing the build workflow..."
echo "This will:"
echo "  1. Test CMake configuration"
echo "  2. Validate build script syntax"
echo "  3. Create mock artifacts"
echo "  4. Run completely offline (no external dependencies)"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "🏃 Running Act..."
echo "Note: This may take a while on first run as Docker images are downloaded"
echo ""

# Run the offline test workflow (no external GitHub Actions)
echo "Running offline test workflow..."
act workflow_dispatch -W .github/workflows/test-build-offline.yml --verbose

echo ""
echo "If you want to test the full workflow (requires internet):"
echo "  act workflow_dispatch -W .github/workflows/test-build.yml --verbose"

echo ""
echo "✅ Act test completed!"
echo ""
echo "💡 Tips:"
echo "  - To test the full workflow: act -W .github/workflows/build-and-release.yml"
echo "  - To test specific job: act -j test-build-linux"
echo "  - To see what would run: act -n (dry run)"
echo "  - To use different runner: act -P ubuntu-latest=ubuntu:20.04"
echo ""
echo "🔗 Act documentation: https://github.com/nektos/act"
