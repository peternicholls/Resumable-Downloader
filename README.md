# SafeDownload

A fully featured CLI download manager with terminal UI, supporting resumable downloads, SHA verification, parallel downloads, and persistent state management. Works with bash and zsh.

## Features

### Core Features
- ✅ **Resumable Downloads**: Automatically resumes interrupted downloads from where they left off
- 🔐 **SHA Verification**: Support for SHA256, SHA512, SHA1, and MD5 checksum verification
- 📊 **Progress Tracking**: Visual progress bar with download speed tracking
- 🔄 **Automatic Retry**: Retries on transient network errors (configurable)
- 🎯 **Server Support Check**: Verifies if the server supports resumable downloads
- 📏 **Size Verification**: Compares downloaded file size with remote file size
- 🎨 **Colored Output**: Easy-to-read colored terminal output
- 🛡️ **Error Handling**: Graceful handling of interruptions and errors

### Advanced Features
- 🖥️ **Terminal UI Mode**: Interactive two-column interface with command system
- 📋 **Download Queue**: Manage multiple downloads with numbered IDs
- ⚡ **Parallel Downloads**: Download multiple files simultaneously
- 📄 **Manifest Support**: Load URLs from a manifest/text file
- 💾 **Persistent State**: State saved in `~/.safedownload/` for auto-resume
- 🔢 **Batch Operations**: Process multiple downloads with ease
- ⏸️ **Stop/Resume**: Control individual downloads by ID

## Requirements

- `curl` - For downloading files
- `python3` - For JSON state management
- `bash` or `zsh` - Compatible with both shells

## Installation

### Quick Install

1. Clone this repository:
   ```bash
   git clone https://github.com/peternicholls/Resumable-Downloader.git
   cd Resumable-Downloader
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

3. Add to PATH (if prompted):
   ```bash
   export PATH="$PATH:$HOME/.local/bin"
   ```

### Manual Installation

```bash
# Copy the script to your PATH
sudo cp safedownload /usr/local/bin/
sudo chmod +x /usr/local/bin/safedownload
```

## Usage

### Command Line Mode

#### Basic Download

```bash
safedownload <URL>
safedownload <URL> <output_filename>
```

#### Download with SHA Verification

```bash
safedownload https://example.com/file.zip --sha256 abc123def456...
safedownload https://example.com/file.zip --sha512 abc123def456...
safedownload https://example.com/file.zip --md5 abc123def456...
```

#### Background Download

```bash
safedownload https://example.com/large-file.zip --bg
```

#### Check Status

```bash
safedownload --status    # Show all downloads with progress
safedownload --list      # List downloads
```

#### Manage Downloads

```bash
safedownload --stop 1     # Stop download #1
safedownload --resume 1   # Resume download #1
safedownload --clear 1    # Remove download #1
safedownload --clear      # Clear completed downloads
safedownload --clear all  # Clear all except in-progress
```

#### Manifest File

```bash
safedownload --manifest urls.txt --parallel 5
```

### Terminal UI Mode

Launch the interactive terminal UI:

```bash
safedownload -g
```

The TUI provides a two-column interface:
- **Left Column**: Command output and history
- **Right Column**: Download queue with progress
- **Bottom**: Input box for commands

#### TUI Commands

| Command | Description |
|---------|-------------|
| `<URL>` | Add URL to download queue |
| `/help`, `/h` | Show help |
| `/stop N` | Stop download #N |
| `/resume N` | Resume download #N |
| `/clear N` | Remove download #N |
| `/clear` | Clear completed downloads |
| `/clear all` | Clear all except in-progress |
| `/list`, `/ls` | List all downloads |
| `/status`, `/s` | Show detailed status |
| `/parallel N` | Set max parallel downloads |
| `/manifest FILE` | Load manifest file |
| `/quit`, `/q` | Exit SafeDownload |

### Examples

#### Download a Linux ISO

```bash
safedownload https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso
```

#### Download with Checksum Verification

```bash
safedownload https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso \
    --sha256 a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd
```

#### Batch Download from Manifest

Create a `urls.txt` file:
```text
# Downloads list (comments start with #)
https://example.com/file1.zip
https://example.com/file2.zip output2.zip
https://example.com/file3.zip file3.zip sha256:abc123...
```

Then run:
```bash
safedownload --manifest urls.txt --parallel 3
```

#### Resume After Restart

Downloads are automatically tracked. If your terminal closes or system restarts:

```bash
safedownload --status    # See what was interrupted
safedownload --resume 1  # Resume specific download
```

Or launch the TUI which auto-resumes interrupted downloads:
```bash
safedownload -g
```

## State Directory

SafeDownload maintains state in `~/.safedownload/`:

```
~/.safedownload/
├── state.json      # Download state and history
├── queue.json      # Download queue
├── config.json     # Configuration
├── safedownload.log # Log file
├── pids/           # Background process PIDs
└── downloads/      # Default download directory
```

## Legacy Script

The original simple `download.sh` script is still available for basic use cases:

```bash
./download.sh <URL>
./download.sh <URL> <output_filename>
```

## How It Works

1. **Server Check**: Checks if the server supports resumable downloads (Accept-Ranges header)
2. **State Management**: Tracks downloads in JSON state file
3. **Partial File Detection**: If a `.part` file exists, calculates resume position
4. **Resume Download**: Uses curl's `-C -` option to resume from the last byte
5. **SHA Verification**: Verifies checksum after download completes
6. **Cleanup**: Moves `.part` file to final filename on success

## Troubleshooting

### Server Doesn't Support Resume

If you see a warning that the server doesn't support resumable downloads, the download will still proceed, but you won't be able to resume if interrupted.

### Checksum Mismatch

If the checksum verification fails, the download may be corrupted. Try downloading again.

### Missing Dependencies

```bash
# Ubuntu/Debian
sudo apt install curl python3

# macOS
brew install curl python3

# Fedora
sudo dnf install curl python3
```

### State Reset

To reset all state and start fresh:
```bash
rm -rf ~/.safedownload
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this script for any purpose.

## Author

Peter Nicholls
