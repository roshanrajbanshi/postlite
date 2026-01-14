# PostLite

PostLite is a small, lightweight post-exploitation helper script for Linux and Windows.

It performs basic checks to highlight potentially interesting privilege-escalation
and abuse signals, without dumping excessive system information or attempting
exploitation.

This script is intended for:
- CTFs
- Lab environments
- Learning post-exploitation basics

## What It Does

PostLite checks for a limited set of common signals.

Linux:
- Interesting SUID binaries
- Writable PATH directories
- Basic sudo misconfigurations
- Simple container-related signals (e.g., LXD group)
- Kernel version display

Windows:
- Current privilege context
- UAC configuration
- Basic token and named pipe signals
- Presence of common auto-elevated binaries
- Windows build information

PostLite does not attempt exploitation.
All findings require manual verification.

## Usage

Linux:
chmod +x postlite.sh
./postlite.sh

Windows:
powershell -ExecutionPolicy Bypass -File postlite.ps1

No dependencies.
Single-file scripts.

## Project Structure

postlite/
├── linux/
│   └── postlite.sh
└── windows/
    └── postlite.ps1

## Disclaimer

For educational use and authorized testing only.

## License

MIT License
