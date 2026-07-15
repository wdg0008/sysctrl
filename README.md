# sysctrl

A set of infrastructure-as-code files for setting up and configuring machines to do useful stuff.

## About

Currently focused on WinGet configuration through PowerShell commandlets, but will likely expand in the future.

```
windows/
  ├── config.winget                   # Main orchestrator (imports others)
  ├── segments/
  │   ├── 00-system-features.winget   # WSL, SSH, VM platform, Sandbox
  │   ├── 01-system-settings.winget   # Registry tweaks (Sudo, LongPaths)
  │   ├── 02-app-removals.winget      # Store app cleanup
  │   ├── 03-core-dev-tools.winget    # Terminal, VSCode, Git, PowerShell
  │   ├── 04-build-toolchain.winget   # CMake, Ninja, Rust, Python, Java
  │   ├── 05-containers.winget        # Docker, Podman
  │   └── 06-productivity-apps.winget # Obsidian, VLC, KeePass, etc.
```
