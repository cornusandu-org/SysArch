# SysArch

## Initial State
The `SYSTEM` user (the new root) has all capabilities and is apart of the `root` group. Its default password is `SYSTEM_`.

The `sysadmin` user is a privileged account with several abusable capabilities being granted by default. Its default password is `1234` (change this).

## Building
To build a copy of SysArch, first install the required dependencies:

### For Debian-based distros
```bash
sudo apt install podman systemd-container
```

### For Arch
```bash
sudo pacman -Syu podman systemd
```

Then, on first boot, run `osinit` as sysadmin.
