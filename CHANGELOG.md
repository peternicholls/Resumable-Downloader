# Changelog

All notable changes to SafeDownload will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup with constitution v1.3.0
- VERSION.yaml for semantic versioning tracking
- CHANGELOG.md for release notes

## [0.1.0] - 2025-12-24

### Added
- Core download functionality with curl
- Resumable downloads via HTTP range requests
- SHA256/SHA512/SHA1/MD5 checksum verification
- Simple TUI with emoji-based status indicators
- State persistence in ~/.safedownload/state.json
- Batch download support via manifest files
- Slash command interface (/help, /stop, /resume, /clear, etc.)
- Parallel download support (configurable concurrency)
- Background download mode with PID tracking

### Security
- HTTPS-only default with --allow-http opt-out
- System CA trust store for TLS verification
- No telemetry or data collection

[Unreleased]: https://github.com/peternicholls/SafeDownload/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/peternicholls/SafeDownload/releases/tag/v0.1.0
