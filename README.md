# SafeDownload Placeholder README

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

