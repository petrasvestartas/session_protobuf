# Local GitHub Actions Testing with Act

This guide helps you test the GitHub Actions workflows locally using [Act](https://github.com/nektos/act) before pushing to GitHub.

## Prerequisites

### 1. Install Act

**macOS:**
```bash
brew install act
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

**Windows:**
```bash
choco install act-cli
# or
winget install nektos.act
```

### 2. Install Docker

Act requires Docker to run the workflows in containers. Make sure Docker is installed and running.

## Quick Start

### 1. Test the Simplified Workflow

Run the test script that validates the build configuration:

```bash
./test-with-act.sh
```

This will:
- Check if Act and Docker are available
- Run a simplified workflow that tests CMake configuration
- Validate build script syntax
- Create mock artifacts

### 2. Test Specific Components

**Test just the Linux build job:**
```bash
act -j test-build-linux -W .github/workflows/test-build.yml
```

**Dry run to see what would execute:**
```bash
act -n -W .github/workflows/test-build.yml
```

**Test the full build workflow (takes longer):**
```bash
act workflow_dispatch -W .github/workflows/build-and-release.yml
```

## Act Configuration

The repository includes several Act configuration files:

### `.actrc`
Contains default settings for Act:
- Platform mappings for different OS runners
- Default secrets
- Verbose output enabled

### Custom Docker Image
For faster testing, you can build a custom image with CMake pre-installed:

```bash
# Build custom image
docker build -t act-ubuntu-cmake .github/act/Dockerfile.ubuntu-cmake

# Use custom image
act -P ubuntu-latest=act-ubuntu-cmake
```

## Testing Scenarios

### 1. Offline Validation (Recommended)
Tests CMake configuration and build script syntax completely offline:

```bash
act workflow_dispatch -W .github/workflows/test-build-offline.yml
```

This workflow:
- Doesn't require internet access
- No external GitHub Actions dependencies
- Validates build system structure
- Creates mock artifacts for testing

### 2. Online Validation
Tests with external GitHub Actions (requires internet):

```bash
act workflow_dispatch -W .github/workflows/test-build.yml
```

**Note:** This may fail with authentication errors if you don't have GitHub credentials configured.

### 2. Full Build Test (Linux only)
Tests the actual build process on Linux (takes 20-30 minutes):

```bash
act -j build -W .github/workflows/build-and-release.yml \
    --matrix os:ubuntu-latest \
    --matrix platform:linux-x86_64
```

### 3. Artifact Testing
Tests artifact creation and upload:

```bash
act workflow_dispatch -W .github/workflows/test-build.yml
```

## Limitations of Act

### Platform Support
- ✅ **Linux**: Full support
- ⚠️ **macOS**: Limited (runs on Linux container)
- ❌ **Windows**: Not supported (runs on Linux container)

### Actions Compatibility
Most GitHub Actions work with Act, but some may have limitations:
- File system permissions might differ
- Some GitHub-specific features may not work
- Network access might be restricted

### Performance
- First run downloads Docker images (slow)
- Subsequent runs are faster
- Building protobuf takes significant time even locally

## Troubleshooting

### Common Issues

**1. Authentication errors with GitHub Actions:**
```
authentication required: Invalid username or token
```
**Solution:** Use the offline workflow instead:
```bash
act workflow_dispatch -W .github/workflows/test-build-offline.yml
```

**2. Docker not running:**
```
Error: Cannot connect to the Docker daemon
```
**Solution:** Start Docker Desktop or Docker daemon

**2. Permission denied:**
```
Error: permission denied while trying to connect to Docker
```
**Solution:** Add your user to docker group or run with sudo

**3. Image pull failures:**
```
Error: failed to pull image
```
**Solution:** Check internet connection or use different image:
```bash
act -P ubuntu-latest=ubuntu:20.04
```

**4. Out of disk space:**
```
Error: no space left on device
```
**Solution:** Clean up Docker images:
```bash
docker system prune -a
```

### Debug Mode

Run with extra debugging:
```bash
act --verbose --dry-run
```

### Custom Environment Variables

Set environment variables for testing:
```bash
act -s GITHUB_TOKEN=your_token -e .env
```

## Workflow Files

### `test-build.yml`
Simplified workflow for quick validation:
- Tests CMake configuration
- Validates script syntax
- Creates mock artifacts
- Fast execution (< 5 minutes)

### `build-and-release.yml`
Full production workflow:
- Builds on multiple platforms
- Creates real artifacts
- Tests release process
- Slow execution (20-30 minutes per platform)

## Best Practices

1. **Start with test workflow** before testing the full build
2. **Use dry run** (`-n`) to validate workflow syntax
3. **Test incrementally** - one job at a time
4. **Clean up** Docker images regularly to save space
5. **Use custom images** for faster repeated testing

## Next Steps

After successful local testing:

1. Push your changes to a test branch
2. Verify the workflow runs on GitHub
3. Create a tag to test the release process
4. Merge to main when everything works

## Resources

- [Act Documentation](https://github.com/nektos/act)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
