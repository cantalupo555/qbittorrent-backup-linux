# qbittorrent-backup-linux

Backup your qBittorrent client and restore anytime.
All settings, statistics and torrent list will be saved.

## Features

- Backup qBittorrent configuration, torrent metadata, and logs
- Restore from backup with a single command
- Support for both package manager and Flatpak installations
- Interactive menu or command-line arguments
- Modular and maintainable codebase

## Installation

### Quick Start (Recommended)

```bash
curl -sL qbt.cantalupo.com.br | bash
```

Or with wget:

```bash
wget -qO- qbt.cantalupo.com.br | bash
```

For manual installation (optional) and usage options, see [INSTALL.md](INSTALL.md).

## Screenshot

![](https://i.imgur.com/TADy3tk.png)

## Video

[![qbittorrent-backup-linux](https://i.imgur.com/9NypMuC.png)](https://www.youtube.com/watch?v=MoweTpbMKNU "qbittorrent-backup-linux")

## Compatibility

**This script works with qBittorrent installed via package manager, Flatpak or both versions.**

| Distribution        | Version(s) Tested | x86_64 | aarch64 |
|---------------------|-------------------|--------|---------|
| Ubuntu              | 22.04+            | ✅     | ✅      |
| Debian              | 11+               | ✅     | ✅      |
| Fedora              | 34, 35            | 🛑     | 🛑      |
| Arch Linux          | Latest            | 🛑     | 🛑      |
| Manjaro             | Latest            | 🛑     | 🛑      |
| openSUSE Tumbleweed | Latest            | 🛑     | 🛑      |

*Note: The script may work on other distributions with similar package management systems and environments, but compatibility has not been thoroughly verified. If you encounter any issues, please report them [here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new).*

## Dependencies

The following packages are required and will be installed automatically if missing:

- `zip` - Archive creation
- `unzip` - Archive extraction
- `plocate` - File system indexing

## Changelog

### v2.0.0

- Complete code refactoring with modular architecture
- Added `set -euo pipefail` for robust error handling
- Added trap for automatic cleanup on exit
- All variables properly quoted for path safety
- New installer script with curl/wget support
- Command-line arguments support (`backup`, `restore`, `-h`, `-v`)
- Reduced unnecessary sleep delays
- Improved code organization and maintainability


## Todo

### v2.0.0 - Code Refactoring

- [x] Add `set -euo pipefail` for strict error handling
- [x] Add `trap` for automatic cleanup on exit
- [x] Create ANSI color constants (`COLOR_RED`, `COLOR_GREEN`, etc.)
- [x] Use `command -v` instead of hardcoded paths (`/usr/bin/`)
- [x] Quote all variables properly for path safety
- [x] Use `mktemp` for temporary files instead of `zipCheck` in working directory
- [x] Extract duplicated code into reusable functions
- [x] Rename `o1()` function to descriptive `wait_for_enter()`
- [x] Reduce/optimize unnecessary sleep delays
- [x] Create separate functions for backup and restore operations
- [x] Modularize codebase into separate files (`src/lib/*.sh`)
- [x] Create installer script with `curl | bash` support
- [x] Add command-line arguments (`backup`, `restore`, `-h`, `-v`)

### Pending

- [ ] Make it compatible with non-Debian distributions (Fedora, Arch, etc.)
- [ ] Add automated tests
- [ ] Add backup scheduling option
- [ ] Add backup compression level options

## Feedback

Any suggestions are welcome: [Click here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new)

## A problem?

Please fill a report [here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new)

## License

This project is licensed under the [MIT License](LICENSE).
