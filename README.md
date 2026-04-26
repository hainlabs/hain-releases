# Hain

Collaborative workspace — CLI and TUI.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hainlabs/hain-releases/main/install.sh | bash
```

After install, add to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Options

```bash
# Install a specific version
curl -fsSL https://... | bash -s -- --version 0.1.0

# Custom install directory
curl -fsSL https://... | bash -s -- --install-dir /opt/hain --bin-dir /usr/local/bin

# Uninstall
curl -fsSL https://... | bash -s -- --uninstall
```

### Manual download

Download a tarball from the [latest release](https://github.com/hainlabs/hain-releases/releases/latest) and extract it:

```bash
tar xzf hain-<version>-<platform>-<arch>.tar.gz
./hain-<version>-<platform>-<arch>/bin/hain --help
```

## Platform support

| Platform | Architecture | Asset |
|----------|-------------|-------|
| Linux    | x64         | `hain-<ver>-linux-x64.tar.gz` |
| Linux    | arm64       | `hain-<ver>-linux-arm64.tar.gz` |
| macOS    | x64         | `hain-<ver>-darwin-x64.tar.gz` |
| macOS    | arm64       | `hain-<ver>-darwin-arm64.tar.gz` |

Each release includes `.sha256` checksum files. The install script verifies checksums automatically.

## Quick start

```bash
hain --help
hain vault init ~/my-vault
hain                        # launch interactive TUI
```

## Community

Join the discussion on [Discord](https://discord.gg/gtjCSv4ZPf).
