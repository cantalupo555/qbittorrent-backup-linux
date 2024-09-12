# qbittorrent-backup-linux

Backup your qBitorrent client and restore anytime.
All settings, statistics and torrent list will be saved.

First, get the script and make it executable:

```bash
wget https://raw.githubusercontent.com/cantalupo555/qbittorrent-backup-linux/master/qbittorrent-backup-linux.sh
chmod +x qbittorrent-backup-linux.sh
```
Then run it:

`sudo ./qbittorrent-backup-linux.sh`


## Screenshot
![](https://i.imgur.com/TADy3tk.png)


## Video
[![qbittorrent-backup-linux](https://i.imgur.com/9NypMuC.png)](https://www.youtube.com/watch?v=MoweTpbMKNU "qbittorrent-backup-linux")


## Compatibility

**This script works with qBittorrent installed via package manager, Flatpak or both versions.**

This table lists the tested Linux distributions and their compatibility:

| Distribution       | Version(s) Tested | x86_64 | aarch64 |
|---------------------|-------------------|--------|--------|
| Ubuntu              | 22.04+            | ✅     | ✅       |
| Debian              | 11+               | ✅     | ✅       |
| Fedora              | 34, 35            | 🛑     | 🛑      |
| Arch Linux          | Latest            | 🛑     | 🛑      |
| Manjaro             | Latest            | 🛑     | 🛑      |
| openSUSE Tumbleweed | Latest            | 🛑     | 🛑      |

*Note: The script may work on other distributions with similar package management systems and environments, but compatibility has not been thoroughly verified. If you encounter any issues, please report them [here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new).*


## Todo
- [x] **Fix script alignment. Completed in commit: [2b4484f](https://github.com/cantalupo555/qbittorrent-backup-linux/commit/2b4484f9c67c412080c5ced8e78a998689b7d5f1) [da5fd9a](https://github.com/cantalupo555/qbittorrent-backup-linux/commit/da5fd9ab9828fe615abf8b5dcdc2c4e881a3b02b)** ✅
- [x] **Fix dependencies on different Debian-based distributions. Completed in commit: [cebc5b3](https://github.com/cantalupo555/qbittorrent-backup-linux/commit/cebc5b3ccd077a6f9d1a31018c30a793a932c30b)** ✅
- [x] **Create a list of Linux distributions that have tested the script. [72b7203](https://github.com/cantalupo555/qbittorrent-backup-linux/commit/72b7203d5f090c07705434c1817d1ef3940186e8)** ✅
- [x] **Make the script compatible with qBittorrent installed via flatpak.[c7364fe](https://github.com/cantalupo555/qbittorrent-backup-linux/commit/c7364fe4398d20c25c75f03c5ca817d57a95a1a4)** ✅
- [ ] Make it compatible with non-Debian distributions. 🔄


## Feedback
Any suggestions are welcome: [Click here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new)

## A problem?
Please fill a report [here](https://github.com/cantalupo555/qbittorrent-backup-linux/issues/new)
