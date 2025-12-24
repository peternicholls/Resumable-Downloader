# Usage Examples

This document provides various examples of using SafeDownload and the legacy download script.

## SafeDownload CLI Examples

### Basic Download

```bash
# Download with automatic filename
safedownload https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso

# Download with custom filename
safedownload https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso ubuntu.iso
```

### Download with SHA Verification

```bash
# Verify SHA256 checksum
safedownload https://example.com/file.tar.gz --sha256 abc123def456...

# Verify SHA512 checksum
safedownload https://example.com/file.tar.gz --sha512 abc123def456...

# Verify MD5 checksum (for legacy systems)
safedownload https://example.com/file.tar.gz --md5 abc123def456...
```

### Background Downloads

```bash
# Start download in background
safedownload https://example.com/large-file.zip --bg

# Check status
safedownload --status

# Resume a specific download
safedownload --resume 1
```

### Parallel Batch Downloads

```bash
# Download from manifest file with 5 parallel downloads
safedownload --manifest urls.txt --parallel 5
```

### Download Queue Management

```bash
# View all downloads
safedownload --list

# View detailed status
safedownload --status

# Stop a download
safedownload --stop 1

# Resume a download
safedownload --resume 1

# Clear completed downloads
safedownload --clear

# Remove specific download
safedownload --clear 3

# Clear all except in-progress
safedownload --clear all
```

## Terminal UI Mode

### Launch TUI

```bash
safedownload -g
```

### TUI Commands

Once in the TUI, you can use these commands:

```
# Add a download (just type the URL and press Enter)
https://example.com/file.zip

# Get help
/help

# Stop download #1
/stop 1

# Resume download #1
/resume 1

# List all downloads
/list

# Show detailed status
/status

# Clear completed downloads
/clear

# Set max parallel downloads to 5
/parallel 5

# Load a manifest file
/manifest urls.txt

# Exit
/quit
```

## Manifest File Examples

### Basic Manifest (urls.txt)

```text
# Downloads list - comments start with #
https://example.com/file1.zip
https://example.com/file2.zip
https://example.com/file3.zip
```

### Manifest with Custom Filenames

```text
# Custom output filenames
https://example.com/file1.zip download1.zip
https://example.com/file2.zip download2.zip
https://example.com/some-long-filename-v2.3.4.tar.gz myfile.tar.gz
```

### Manifest with SHA Verification

```text
# With checksums
https://example.com/file1.zip file1.zip sha256:abc123...
https://example.com/file2.zip file2.zip sha512:def456...
https://example.com/file3.zip file3.zip md5:789abc...
```

## Real-World Use Cases

### Download Linux ISOs with Verification

```bash
# Ubuntu with SHA256 verification
safedownload https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso \
    --sha256 a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd
```

### Download Multiple ML Datasets

Create `datasets.txt`:
```text
# Machine Learning Datasets
https://example.com/cifar-10.tar.gz cifar10.tar.gz sha256:...
https://example.com/mnist.tar.gz mnist.tar.gz sha256:...
https://example.com/imagenet.tar.gz imagenet.tar.gz sha256:...
```

Then:
```bash
safedownload --manifest datasets.txt --parallel 3
```

### Resumable Large Download

```bash
# Start downloading a large file
safedownload https://example.com/50gb-dataset.tar.gz

# If interrupted, check status
safedownload --status

# Resume
safedownload --resume 1

# Or simply re-run the same command
safedownload https://example.com/50gb-dataset.tar.gz
```

## Legacy Script Examples

The original `download.sh` script is still available for simple use cases:

### Basic Download

```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso
```

### Download with Custom Filename

```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso ubuntu.iso
```

### Resume an Interrupted Download

```bash
# First attempt (gets interrupted)
./download.sh https://example.com/large-dataset.tar.gz data.tar.gz
# Press Ctrl+C or connection drops

# Resume by running the same command
./download.sh https://example.com/large-dataset.tar.gz data.tar.gz
```

## Integration Examples

### Use in a Makefile

```makefile
data/dataset.tar.gz:
	safedownload https://example.com/dataset.tar.gz $@ \
		--sha256 abc123...

download: data/dataset.tar.gz
```

### Use in a CI/CD Pipeline

```yaml
# .github/workflows/download.yml
jobs:
  download:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install SafeDownload
        run: |
          ./install.sh
          export PATH="$PATH:$HOME/.local/bin"
      
      - name: Download verified dataset
        run: |
          safedownload https://example.com/dataset.tar.gz dataset.tar.gz \
            --sha256 abc123def456...
```

### Use in a Docker Build

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl python3

COPY safedownload /usr/local/bin/
RUN chmod +x /usr/local/bin/safedownload

RUN safedownload https://example.com/data.tar.gz /data/data.tar.gz \
    --sha256 abc123...
```

### Use with systemd Timer

Create `/etc/systemd/system/download-updates.service`:
```ini
[Unit]
Description=Download Updates

[Service]
Type=oneshot
ExecStart=/usr/local/bin/safedownload --manifest /etc/download-updates.txt --parallel 2
```

Create `/etc/systemd/system/download-updates.timer`:
```ini
[Unit]
Description=Daily Download Updates

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

## Tips and Tricks

### Check Available Disk Space

```bash
# Check free space before downloading
df -h .

# Then download
safedownload https://example.com/large-file.iso
```

### Monitor Downloads in Background

```bash
# Start background download
safedownload https://example.com/file.zip --bg

# Watch status
watch -n 2 'safedownload --status'
```

### Clean Up Old Downloads

```bash
# Clear completed downloads
safedownload --clear

# Clear everything except in-progress (with confirmation)
safedownload --clear all
```

### State Directory Cleanup

```bash
# View state directory
ls -la ~/.safedownload/

# Reset all state
rm -rf ~/.safedownload

# View logs
cat ~/.safedownload/safedownload.log
```

## Troubleshooting

### Server Doesn't Support Resume

```bash
safedownload https://example.com/file.zip
# [WARNING] Server may not support resumable downloads
# Download proceeds anyway, but can't resume if interrupted
```

### Checksum Mismatch

```bash
safedownload https://example.com/file.zip --sha256 wrong_hash
# [ERROR] Checksum mismatch!
# The download may be corrupted or the hash may be incorrect
```

### Manual Cleanup of Partial Files

```bash
# Remove all .part files
rm *.part

# Or remove a specific one
rm myfile.zip.part
```
