# SafeDownload - Feature Summary

## Overview
A fully featured CLI download manager with terminal UI, supporting resumable downloads, SHA verification, parallel downloads, batch operations, and persistent state management.

## Core Features

### 1. Resumable Downloads ✅
- Uses HTTP range requests (curl -C -)
- Automatically detects partial downloads (.part files)
- Seamlessly resumes from the last downloaded byte
- No need to start over if interrupted

### 2. SHA Verification ✅
- SHA256, SHA512, SHA1, and MD5 support
- Automatic verification after download completes
- Clear error messages for checksum mismatches

### 3. Robust Error Handling ✅
- Automatic retry on network failures (configurable)
- Graceful handling of interruptions (Ctrl+C, network drops)
- Clear error messages and recovery instructions
- Persistent state survives crashes

### 4. Progress Tracking ✅
- Visual progress bar from curl
- Shows download speed and progress percentage
- Displays file sizes in human-readable format (B, KB, MB, GB, TB)
- Real-time status updates in both CLI and TUI modes

### 5. State Machine & Persistence ✅
- Download states: queued, downloading, paused, completed, failed, verifying
- State saved in `~/.safedownload/`
- Auto-resume on restart
- JSON-based state storage

### 6. Terminal UI Mode ✅
- Two-column layout (commands left, queue right)
- Slash command system for control
- Real-time download progress display
- Input box for commands and URL entry
- Background process management

### 7. Parallel Downloads ✅
- Configurable max parallel downloads
- Automatic queue processing
- Background download support

### 8. Manifest/Batch Support ✅
- Load URLs from text files
- Format: URL [output] [sha_type:sha]
- Comment support (# prefix)
- Batch processing

### 9. Cross-Platform Compatibility ✅
- Works on Linux, macOS, and Unix-like systems
- Portable file size detection (wc -c)
- Compatible with both bash and zsh

## Technical Implementation

### Dependencies
- **curl**: For HTTP downloads with resume support
- **python3**: For JSON state management
- **bash/zsh**: For script execution

### File Structure
```
Resumable-Downloader/
├── safedownload      # Main CLI/TUI application
├── download.sh       # Legacy simple script
├── install.sh        # Installation script
├── test.sh          # Automated test suite
├── README.md        # User documentation
├── EXAMPLES.md      # Usage examples
├── FEATURES.md      # This file
└── LICENSE          # MIT License
```

### State Directory
```
~/.safedownload/
├── state.json       # Download state and history
├── queue.json       # Download queue
├── config.json      # Configuration
├── safedownload.log # Log file
├── pids/            # Background process PIDs
└── downloads/       # Default download directory
```

### Download States
1. `queued` - Waiting to start
2. `downloading` - Currently downloading
3. `paused` - Manually stopped
4. `verifying` - Checking checksum
5. `completed` - Successfully finished
6. `failed` - Error occurred

## CLI Commands

### Basic Commands
```bash
safedownload <URL>                    # Download file
safedownload <URL> <output>           # Download with custom name
safedownload -g                       # Launch TUI mode
safedownload --status                 # Show status
safedownload --list                   # List downloads
```

### SHA Verification
```bash
safedownload <URL> --sha256 <hash>
safedownload <URL> --sha512 <hash>
safedownload <URL> --sha1 <hash>
safedownload <URL> --md5 <hash>
```

### Download Control
```bash
safedownload --stop <ID>              # Stop download
safedownload --resume <ID>            # Resume download
safedownload --clear <ID>             # Remove download
safedownload --clear                  # Clear completed
safedownload --clear all              # Clear all except in-progress
safedownload --bg                     # Background download
```

### Batch Downloads
```bash
safedownload --manifest urls.txt
safedownload --manifest urls.txt --parallel 5
```

## TUI Commands

| Command | Description |
|---------|-------------|
| `<URL>` | Add URL to download queue |
| `/help` | Show help |
| `/stop N` | Stop download #N |
| `/resume N` | Resume download #N |
| `/clear N` | Remove download #N |
| `/clear` | Clear completed |
| `/clear all` | Clear all except in-progress |
| `/list` | List downloads |
| `/status` | Detailed status |
| `/parallel N` | Set max parallel |
| `/manifest FILE` | Load manifest |
| `/quit` | Exit |

## Use Cases

### Ideal For:
- Large file downloads (ISO images, datasets, videos)
- Unreliable network connections
- Long-running downloads that may be interrupted
- Automated download scripts in CI/CD
- Batch downloading operations
- Verified downloads with checksums

### Real-World Scenarios:
- Downloading Linux distribution ISOs (2-4 GB)
- Machine learning datasets (10+ GB)
- Genome sequences and scientific data
- Docker images and software archives
- Video files and media content
- Database dumps and backups

## Testing

### Automated Tests
- Help message verification
- Command validation
- Function existence checks
- Dependency validation
- Syntax verification
- State management verification
- TUI function verification

### Quality Assurance
- ✅ Bash syntax validation
- ✅ All automated tests passing
- ✅ Cross-platform compatibility verified
- ✅ State persistence verified
- ✅ SHA verification tested

## Performance

### Efficiency
- Uses native curl for downloads
- JSON state management via python3
- Efficient file size detection
- Minimal overhead

### Scalability
- Handles files of any size (limited by disk space)
- Memory-efficient streaming downloads
- Parallel download support
- Automatic queue management

## License
MIT License - Free for any use, commercial or personal

## Support
For issues, questions, or contributions, please visit:
https://github.com/peternicholls/Resumable-Downloader
