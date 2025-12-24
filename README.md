# Resumable Downloader

A simple, powerful, and resumable terminal download manager/script for very large files. Works with bash and zsh.

## Features

- ✅ **Resumable Downloads**: Automatically resumes interrupted downloads from where they left off
- 📊 **Progress Tracking**: Visual progress bar with download speed and ETA
- 🔄 **Automatic Retry**: Retries on transient network errors
- 🎯 **Server Support Check**: Verifies if the server supports resumable downloads
- 📏 **Size Verification**: Compares downloaded file size with remote file size
- 🎨 **Colored Output**: Easy-to-read colored terminal output
- 🛡️ **Error Handling**: Graceful handling of interruptions and errors

## Requirements

- `curl` - For downloading files
- `bash` or `zsh` - Compatible with both shells

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/peternicholls/Resumable-Downloader.git
   cd Resumable-Downloader
   ```

2. Make the script executable:
   ```bash
   chmod +x download.sh
   ```

## Usage

### Basic Usage

```bash
./download.sh <URL>
```

The script will automatically extract the filename from the URL.

### Specify Output Filename

```bash
./download.sh <URL> <output_filename>
```

### Examples

Download a file with automatic filename:
```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso
```

Download and save with a custom filename:
```bash
./download.sh https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso ubuntu.iso
```

### Resuming Downloads

If a download is interrupted (Ctrl+C, network failure, etc.), simply run the same command again. The script will automatically detect the partial download and resume from where it left off:

```bash
./download.sh https://example.com/largefile.zip myfile.zip
# ... download interrupted ...
# Run the same command again to resume:
./download.sh https://example.com/largefile.zip myfile.zip
```

## How It Works

1. **Server Check**: The script first checks if the server supports resumable downloads by looking for the `Accept-Ranges` header
2. **Partial File Detection**: If a `.part` file exists, it calculates the resume position
3. **Resume Download**: Uses curl's `-C -` option to resume from the last byte downloaded
4. **Verification**: After download completes, verifies the file size matches the remote file size
5. **Cleanup**: Moves the `.part` file to the final filename on successful completion

## Advanced Features

### Automatic Retry

The script automatically retries failed downloads up to 5 times with a 3-second delay between attempts.

### Size Verification

After download completion, the script verifies that the downloaded file size matches the server's reported size, warning you if there's a mismatch.

### Partial File Handling

Interrupted downloads are saved with a `.part` extension. When you resume, the script continues from the partial file and only renames it to the final filename after successful completion.

## Troubleshooting

### Server Doesn't Support Resume

If you see a warning that the server doesn't support resumable downloads, the download will still proceed, but you won't be able to resume if interrupted. You'll need to start from scratch.

### File Size Mismatch

If the script reports a size mismatch after download, the file may be corrupted or the server may have sent an incorrect Content-Length header. Try downloading again or verify the file manually.

### Missing Dependencies

If you get errors about missing commands:
- Install curl: `sudo apt install curl` (Ubuntu/Debian) or `brew install curl` (macOS)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this script for any purpose.

## Author

Peter Nicholls
