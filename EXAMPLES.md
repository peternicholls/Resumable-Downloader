# Usage Examples

This document provides various examples of using the Resumable Download Manager.

## Basic Examples

### Download with automatic filename
The script automatically extracts the filename from the URL:
```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso
```

### Download with custom filename
Specify your own filename for the download:
```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso ubuntu.iso
```

## Resuming Downloads

### Resume an interrupted download
If your download gets interrupted, simply run the same command again:
```bash
# First attempt (gets interrupted)
./download.sh https://example.com/large-dataset.tar.gz data.tar.gz
# Press Ctrl+C or connection drops

# Resume by running the same command
./download.sh https://example.com/large-dataset.tar.gz data.tar.gz
```

The script will:
- Detect the partial `.part` file
- Display how much has already been downloaded
- Resume from where it left off

## Real-World Use Cases

### Downloading Linux ISOs
Download large Linux distribution images:
```bash
# Ubuntu Desktop
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso

# Fedora Workstation
./download.sh https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso fedora.iso
```

### Downloading Large Datasets
Download datasets for machine learning or data analysis:
```bash
# Example: ImageNet dataset (hypothetical URL)
./download.sh https://example.com/datasets/imagenet-2023.tar.gz imagenet.tar.gz

# Example: Genome sequences
./download.sh https://example.com/genomes/human-genome-hg38.fa.gz genome.fa.gz
```

### Downloading Software Archives
Download large software packages or archives:
```bash
# Docker images (exported)
./download.sh https://example.com/docker/large-image.tar large-image.tar

# Video files
./download.sh https://example.com/videos/conference-2023.mp4 conference.mp4
```

## Advanced Usage

### Downloading from authenticated sources
If the URL contains authentication:
```bash
./download.sh "https://username:password@example.com/private/file.zip" file.zip
```

### Downloading from URLs with query parameters
Use quotes when the URL contains special characters:
```bash
./download.sh "https://example.com/download?file=data&version=2.0" data-v2.0.zip
```

### Batch Downloads
Create a simple script to download multiple files:
```bash
#!/bin/bash
# download-batch.sh

urls=(
    "https://example.com/file1.zip"
    "https://example.com/file2.zip"
    "https://example.com/file3.zip"
)

for url in "${urls[@]}"; do
    ./download.sh "$url"
done
```

## Tips and Tricks

### Check available disk space before downloading
```bash
# Check free space
df -h .

# Then download
./download.sh https://example.com/large-file.iso
```

### Run download in background
Use `nohup` to run the download in background:
```bash
nohup ./download.sh https://example.com/large-file.iso &
```

Or use `screen` or `tmux`:
```bash
# Using screen
screen -S download
./download.sh https://example.com/large-file.iso
# Press Ctrl+A then D to detach

# Reattach later
screen -r download
```

### Monitor download progress
The script shows a progress bar automatically, but you can also monitor the `.part` file:
```bash
# In another terminal
watch -n 1 ls -lh *.part
```

## Troubleshooting Examples

### Server doesn't support resume
If you see the warning about no resume support, the download will still work:
```bash
./download.sh https://example.com/file.zip
# [WARNING] Server may not support resumable downloads
# Download proceeds anyway, but can't resume if interrupted
```

### Existing file warning
If the file already exists, you'll be prompted:
```bash
./download.sh https://example.com/file.zip myfile.zip
# [WARNING] File 'myfile.zip' already exists
# Do you want to overwrite it? (y/N):
```

### Manual cleanup of partial files
If needed, you can manually remove partial downloads:
```bash
# Remove all .part files
rm *.part

# Or remove a specific one
rm myfile.zip.part
```

## Integration Examples

### Use in a Makefile
```makefile
data/dataset.tar.gz:
	./download.sh https://example.com/dataset.tar.gz $@

download: data/dataset.tar.gz
```

### Use in a CI/CD pipeline
```yaml
# .github/workflows/download.yml
steps:
  - name: Download dataset
    run: |
      chmod +x download.sh
      ./download.sh https://example.com/dataset.tar.gz dataset.tar.gz
```

### Use in a Docker build
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl bc
COPY download.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/download.sh
RUN download.sh https://example.com/data.tar.gz /data/data.tar.gz
```
