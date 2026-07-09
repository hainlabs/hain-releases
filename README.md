# Hain

> Early release. If something breaks or confuses you, tell us on [Discord](https://discord.gg/gtjCSv4ZPf).

A private shared space for your files. Hain syncs folders directly between your devices and the people you trust. No cloud.

Your files go straight from your machine to theirs, encrypted on the way. Nothing lands on a stranger's server, because there is no server in the middle.

## Download

Grab the installer for your platform from the [latest release](../../releases/latest), or visit [hain.sh/download](https://hain.sh/download).

| Platform | Format | Status |
|----------|--------|--------|
| macOS (Apple Silicon) | DMG | Supported |
| Linux x64 | AppImage, deb | Supported |
| Linux arm64 | AppImage, deb | Supported |
| Windows | | Planned |

### Install

- **macOS:** open the DMG and drag Hain to your Applications folder. The build is signed and notarized, so it launches with no security prompts.
- **Linux (AppImage):** make it executable and run it.
  ```bash
  chmod +x Hain-*.AppImage
  ./Hain-*.AppImage
  ```
- **Linux (deb):** install it with your package manager.
  ```bash
  sudo apt install ./hain_*.deb
  ```

## Get started

1. Open Hain and create a space. It picks a sensible home for your files, so there is nothing to configure.
2. Copy the share key.
3. Send the key to whoever is joining. They paste it, and the folder is theirs. That is the whole onboarding.

## Verify your download

Every asset ships with a `.sha256` checksum next to it. To check one:

```bash
sha256sum -c Hain-*.sha256
```

## Updates

Hain keeps itself current. On macOS it updates in the background and asks you to restart when a new version is ready. On Linux it lets you know when an update is out and links you to the download.

## Community

Questions, bug reports, and ideas are welcome on [Discord](https://discord.gg/gtjCSv4ZPf), or email us at hello@hain.sh.

Found a security issue? Please report it privately. See [SECURITY.md](SECURITY.md).

## About

Hain is made by Hain Labs. The app is free to use and closed source. Every build is signed and checksummed, so you can trust the binary you run. See [LICENSE](LICENSE).
