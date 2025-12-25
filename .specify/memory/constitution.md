<!--
Sync Impact Report
- Version: 1.3.0 -> 1.4.0
- Modified principles: None
- Added sections: XII. Documentation Organization & Standards; XIII. Specification Structure & Precision
- Removed sections: None
- Templates requiring updates: plan-template.md ✅ (already references dev/ structure), spec-template.md ✅ (already uses structured format), tasks-template.md ✅ (already aligned), checklist-template.md ✅, agent-file-template.md ✅
- Follow-up TODOs: Ensure all code has idiomatic documentation (jdoc/godoc/rustdoc/etc.); validate dev/ folder structure; consider adding TOML alternatives for YAML specs
-->

# SafeDownload Constitution

## Core Principles

### I. Professional User Experience
A fully featured download manager MUST deliver a gorgeous, professional interface that respects user attention. The CLI provides reliable functionality; the optional TUI provides visual elegance and dashboard-like clarity without sacrificing performance or consuming excessive terminal real estate. Both modes MUST be responsive, non-intrusive, and suitable for production environments.

### II. Optional Enhanced Features (No Forced Dependencies)
Core functionality requires only `curl`, `python3`, and `bash/zsh`—nothing more. Enhanced features like the Gum-powered TUI MUST be optional. Automatic fallback to simple TUI ensures the system works perfectly on any Unix-like system. Users can opt-in to beautiful interfaces; they are never blocked by missing optional dependencies.

### III. Resumable Downloads (Non-Negotiable Reliability)
Every download MUST support resumable downloads via HTTP range requests. The system automatically detects server support, tracks partial downloads with `.part` files, calculates resume positions, and retries on network transients. Interruptions are temporary inconveniences, never data losses. State is persistent in `~/.safedownload/state.json`.

### IV. Verification & Trust
Downloads MUST support cryptographic verification via SHA256, SHA512, SHA1, and MD5. Checksum mismatches are fatal—files are marked failed, not silently accepted. Size verification against remote Content-Length header MUST be performed. Users can trust that a completed download is authentic and intact.

### V. Intelligent Parallelism & Queue Management
The system supports parallel downloads with configurable concurrency (default: 3 concurrent). Downloads are managed as numbered queue items with states: queued, downloading, completed, failed, paused. Users control parallelism via CLI (`--parallel N`), TUI commands (`/parallel N`), or manifest directives. Each download runs independently; failures in one never block others.

### VI. Slash Command Interface (Dashboard Pattern)
The TUI uses slash-command syntax (`/help`, `/stop 1`, `/resume 2`, `/clear`, `/manifest file.txt`, `/quit`) inspired by professional tools like wtfutil. This pattern is learnable, discoverable (via `/help`), and extensible. Commands operate on the download queue intelligently (e.g., `/clear` removes completed; `/clear all` removes everything except in-progress).

### VII. State Persistence & Auto-Resume
Download state is automatically saved to `~/.safedownload/state.json` after every state change. Completed, failed, and in-progress downloads survive system restarts. On next TUI launch, interrupted downloads resume automatically. Users never lose progress; the system is their reliable download companion, not a stateless utility.

### VIII. Polyglot Architecture & Forward Compatibility
The project MUST remain portable beyond Bash/Zsh. The long-term core MUST move to a compiled, distributable binary in Go (primary) while preserving CLI/TUI contracts; Rust remains acceptable for modules if the contract is stable. Shell entrypoints are shims, not the core. Any new modules MUST keep the text-in/text-out contract stable so alternate frontends (Bubble Tea/Gum TUI, HTTP API, GUI) can coexist.

### IX. Privacy & Data Minimization
The system MUST NOT collect, transmit, or share any user data, telemetry, or analytics. All download metadata (URLs, filenames, checksums) remains local to `~/.safedownload/`. Logs (`safedownload.log`) contain only operational data (timestamps, errors, state transitions) and MUST NOT include credentials or sensitive headers. Users MUST have a `/purge` command (or `--purge` CLI flag) to delete all local state, logs, and PID files. Log rotation MUST cap file size at 10MB; oldest entries auto-pruned. No external services contacted except the download URLs themselves.

### X. Security Posture
Downloads MUST default to HTTPS-only; HTTP downloads require explicit `--allow-http` flag with a warning. TLS verification MUST use system CA trust store; `--insecure` flag bypasses verification but logs a security warning. Proxy support (`HTTP_PROXY`, `HTTPS_PROXY` env vars) MUST respect `NO_PROXY`. Checksum verification (SHA256/SHA512) is mandatory for production workflows; the system SHOULD support GPG signature verification via optional `--verify-sig file.asc` for defense-in-depth. No credential storage in logs or state files; HTTP Basic Auth passed via URL or `--header` flag only. Vulnerabilities disclosed via GitHub Security Advisories; critical CVEs patched within 7 days, high-severity within 30 days.

### XI. Accessibility
All TUI modes MUST be usable without color perception: status indicators combine emoji + text labels (e.g., "⏳ Queued", "✅ Completed"). High-contrast themes MUST be supported via `--theme` flag (light, dark, high-contrast). Terminal dimensions MUST be detected; output MUST gracefully degrade for narrow terminals (<80 cols) by omitting decorative elements. Screen-reader compatibility: all interactive prompts MUST emit plain-text labels before styled output. Keyboard navigation MUST NOT require mouse or arrow keys for core operations (slash commands sufficient).

### XII. Documentation Organization & Standards
All specifications, design documents, roadmaps, and architecture artifacts MUST reside in the `dev/` directory hierarchy. The structure MUST follow: `dev/roadmap.yaml` (project roadmap), `dev/specs/` (feature specifications), `dev/sprints/` (sprint planning), `dev/architecture/` (system design), `dev/standards/` (coding standards). This ensures clear separation between documentation and implementation, facilitating discoverability and maintenance. All code MUST contain idiomatic inline documentation appropriate to the language: Javadoc for Java, godoc for Go, rustdoc for Rust, docstrings for Python, JSDoc for JavaScript/TypeScript, header comments for Bash/Shell. Documentation MUST explain intent and contracts, not merely restate code structure. Complex functions MUST include examples demonstrating usage patterns.

**Rationale**: Centralized documentation prevents fragmentation and duplicate effort. Idiomatic documentation integrates naturally with language tooling (go doc, cargo doc, etc.), improving developer experience and enabling automated documentation generation. Consistent organization reduces cognitive load when navigating the project.

### XIII. Specification Structure & Precision
Roadmaps, feature specifications, and planning artifacts SHOULD prefer structured formats (YAML or TOML) over prose-heavy Markdown where precision is paramount. Use YAML/TOML for: versioning metadata, dependency trees, feature matrices, acceptance criteria checklists, sprint planning data, and configuration schemas. Reserve Markdown for: user-facing guides, design rationale, architecture decision records (ADRs), and narrative explanations. Structured formats MUST include schema versioning and be validated against schemas where possible. This reduces ambiguity, enables programmatic processing (e.g., auto-generating task lists from specs), and ensures consistency across documents.

**Rationale**: Structured data formats enforce precision and reduce interpretation errors. YAML/TOML enable tooling integration (e.g., parsing roadmaps into project management tools, validating spec completeness). Prose remains valuable for context and explanation but should not be the primary vehicle for structured requirements. The `dev/roadmap.yaml` exemplifies this principle: features, dependencies, and release plans are structured data, while narrative context lives in Markdown files.

## Technical Constraints

**Supported Languages**: Current: Bash/Zsh entrypoints with Python3 for state. Target: compiled core in Go (primary) with stable CLI contracts; Rust acceptable for modules if contract-stable; Swift/Node/TypeScript/Python3/Go allowed for auxiliary tooling if optional.

**Core Dependencies**: curl; Python3 for current state management (until migrated to native core)

**Optional Enhancements**: Bubble Tea TUI stack (Go) for the primary compiled UI; Gum for quick prompt-like flows; Lip Gloss for styling; alternative frontends (HTTP API/GUI) remain contract-compatible.

**UI/UX Standards**:
- Simple TUI: Clean, emoji-based status indicators (⏳, ⬇️, ✅, ❌, ⏸️), no excessive borders or flashing
- Gum TUI: Modern styled output with proper input handling (arrow keys, history, line editing)
- Progress bars MUST show percentage, speed (MB/s), and ETA
- Color output MUST be properly escaped ANSI codes; help text MUST use `echo -e` or equivalent
- All TUI interactions MUST be instant (no polling loops causing flashing)
- **Accessibility**: High-contrast mode support; colorblind-safe palette (avoid red/green only status); MUST NOT rely on color alone for critical information; emoji MUST be paired with text labels; terminal width/height MUST be detected and respected

**Architecture Decisions**:
- Current: Main script (`safedownload`) hosts core logic; satellite scripts extend rather than duplicate functionality
- Target: Core library in Go exposing stable CLI API; shell wrappers simply delegate; shared download/state logic lives in the compiled core
- State directory: `~/.safedownload/` (state.json, queue.json, config.json, pids/, downloads/, safedownload.log)
- Manifest format: one URL per line, optional output filename, optional checksum (e.g., `https://example.com/file.zip output.zip sha256:abc123...`)
- Background downloads write PID to `~/.safedownload/pids/N.pid` for process tracking

**Performance Standards**:
- TUI startup MUST be < 500ms
- Adding a download to queue MUST be < 100ms
- Listing downloads MUST be < 100ms (even with 100+ items)
- Resume calculation MUST be < 50ms
- No polling loops; all UI updates triggered by user command or download event

**Error Handling & Exit Codes**:
- Exit 0: Success (download completed, queue cleared, etc.)
- Exit 1: General error (invalid arguments, missing dependencies)
- Exit 2: Network error (connection timeout, DNS failure)
- Exit 3: Verification failure (checksum mismatch, size mismatch)
- Exit 4: Permission error (cannot write to output directory)
- Exit 130: User interrupt (Ctrl+C)
- Retry policy: 3 attempts with exponential backoff (1s, 2s, 4s) for transient network errors; fatal errors (404, 403, checksum mismatch) MUST NOT retry
- Graceful shutdown: SIGTERM/SIGINT MUST save state before exit; in-progress downloads marked as paused

**Platform Support**:
- **Tier 1 (fully supported, CI-tested)**: macOS (latest 2 versions), Ubuntu LTS (22.04, 24.04), Debian 12+
- **Tier 2 (best-effort, community-tested)**: Fedora, Arch, Alpine Linux
- **Tier 3 (experimental, not tested)**: BSD variants (FreeBSD, OpenBSD), Windows WSL2
- Windows native support: deferred pending Go core migration (`.exe` binary feasible)
- Installation scripts (`install.sh`, `install-tui.sh`) MUST detect OS and warn if Tier 2/3

**Configuration & State Schema Versioning**:
- All JSON files in `~/.safedownload/` MUST include `"schema_version"` field (e.g., `"schema_version": "1.0.0"`)
- Schema versioning follows semantic versioning: MAJOR for breaking changes, MINOR for backward-compatible additions, PATCH for clarifications
- Breaking schema changes MUST include automatic migration logic (read old version, transform, write new version with updated schema_version)
- Migration failures MUST prompt user to backup state and provide manual migration instructions
- Forward compatibility: newer app versions MUST gracefully degrade when reading older schemas (ignore unknown fields, apply defaults)

**Dependency & License Governance**:
- All dependencies (curl, python3, Gum, Bubble Tea libraries) MUST be open-source with permissive licenses (MIT, Apache-2.0, BSD-3-Clause)
- GPL/LGPL dependencies allowed ONLY if dynamically linked or optional runtime dependencies (not bundled in binary)
- SBOM (Software Bill of Materials) MUST be generated for compiled releases (use `go.mod` or equivalent)
- Dependency updates: patch versions auto-merged if tests pass; minor/major versions require manual review
- Curl version compatibility: MUST support curl 7.60+ (2018); test against system curl on Tier 1 platforms

## Development Workflow & Quality Gates

**Testing Requirements**:
- `test.sh` script validates core download functionality, checksum verification, and resume behavior
- TUI testing: manual interactive testing required for slash commands and display
- All new features MUST include test coverage before merge
- Installation scripts (`install.sh` and `install-tui.sh`) MUST be tested on Tier 1 platforms (macOS, Ubuntu LTS)
- Security testing: HTTPS enforcement, checksum verification, and `--insecure` flag behavior validated in test suite
- Accessibility testing: high-contrast mode and screen-reader compatibility verified manually on each release

**Documentation Standards**:
- README.md MUST include quick-start examples (basic download, checksum verification, batch manifest, TUI launch)
- README.md MUST clearly show requirements, installation steps, and usage sections for both CLI and TUI
- TUI-specific docs: `TUI_FIX_README.md`, `TUI_QUICK_REFERENCE.md` for users choosing to install Gum
- Code comments MUST explain why, not what; version numbers and API contracts MUST be documented
- CHANGELOG.md MUST exist at repository root with semantic commit-based entries (feat:, fix:, docs:, chore:, BREAKING:)
- Security advisories published via GitHub Security tab; CVEs tracked in CHANGELOG.md with patch version references

- **Idiomatic Documentation Requirements**:
  - Go: godoc-compliant comments for all exported symbols; package docs in doc.go; examples in _test.go files
  - Rust: rustdoc with `///` for public items; module-level docs with `//!`; runnable examples in doc comments
  - Python: docstrings (Google or NumPy style) for all public functions/classes/modules; type hints mandatory
  - Java: Javadoc for all public classes/methods/constructors; `@param`, `@return`, `@throws` tags required
  - JavaScript/TypeScript: JSDoc/TSDoc for all exported functions/classes; type annotations for TypeScript
  - Bash/Shell: Header comments with usage, arguments, exit codes; inline comments for complex logic only

- **Dev Folder Structure**:
  - `dev/roadmap.yaml`: Master roadmap with versioned release plans (semantic versioning)
  - `dev/specs/features/[###-feature-name]/`: Feature specifications with plan.md, spec.md, research.md
  - `dev/sprints/`: Sprint planning artifacts (backlog, velocity tracking)
  - `dev/architecture/`: System architecture docs (ADRs, diagrams, API contracts)
  - `dev/standards/`: Coding standards, style guides, tooling configs
  
- **Structured Spec Format**:
  - Feature metadata (ID, priority, story points, dependencies) MUST be YAML frontmatter or dedicated YAML files
  - Acceptance criteria MUST be structured checklists or YAML lists for programmatic validation
  - Roadmap data (releases, features, risks, metrics) MUST be YAML/TOML, not Markdown tables
  - Narrative docs (rationale, design decisions, migration guides) remain Markdown
  - All YAML/TOML files MUST include schema_version for evolution tracking

**Versioning & Releases**:
- Application version stored in `VERSION.yaml` at repository root with schema:
  ```yaml
  version: "1.3.0"
  schema_version: "1.0.0"
  release_date: "2025-12-24"
  codename: "Bubble"  # optional
  ```
- Semantic versioning (MAJOR.MINOR.PATCH):
  - MAJOR: Breaking changes to CLI interface, state schema, or constitution principles
  - MINOR: New features (slash commands, checksum algorithms, manifest enhancements, new frontends, new constitution sections)
  - PATCH: Bug fixes, documentation, performance improvements, constitution clarifications
- Constitution version tracks separately in this file's Version line (current: 1.3.0)
- Releases tagged in git with `vX.Y.Z` format; CHANGELOG.md updated before tagging
- Pre-releases allowed: `vX.Y.Z-alpha.N`, `vX.Y.Z-beta.N`, `vX.Y.Z-rc.N`

**Release Cycle & Distribution**:
- **Cadence**: Minor releases every 6-8 weeks; patch releases as needed for critical bugs/CVEs
- **Feature freeze**: 1 week before minor release; only bug fixes and docs after freeze
- **Release artifacts**:
  - Source tarball (`.tar.gz`) with VERSION.yaml, CHANGELOG.md, and all scripts
  - Compiled binary (once Go core ready): `safedownload-vX.Y.Z-darwin-arm64`, `safedownload-vX.Y.Z-linux-amd64`, etc.
  - Checksums file (`SHA256SUMS`) with all artifact hashes
  - Optional: Homebrew tap formula, Debian `.deb`, RPM `.rpm` for Tier 1 platforms
- **Channels**: `stable` (latest tagged release), `beta` (release candidates), `main` (development branch)
- **Distribution**:
  - GitHub Releases (primary)
  - Homebrew tap: `brew tap peternicholls/safedownload` (future)
  - Package managers: apt/yum repositories (future, post-Go migration)
- **Install script**: `install.sh` MUST detect latest stable release from GitHub API and install automatically
- **Upgrade path**: `safedownload --upgrade` command (or `/upgrade` TUI command) checks GitHub API and self-updates if newer version available

**Code Review Process**:
- All changes MUST be code reviewed for compliance with principles above
- TUI changes MUST be visually tested (no flashing, professional appearance)
- Dependency changes MUST maintain "no forced external deps" principle (optional only)
- Polyglot changes MUST preserve CLI contract compatibility and avoid regressions in shell wrappers during migration
- Performance regressions (TUI > 500ms startup, list > 100ms) MUST be justified and documented
- Security changes (HTTPS enforcement, checksum algorithms, TLS config) require extra scrutiny and testing
- Accessibility changes MUST be tested with high-contrast mode and screen-reader emulation
- **Documentation Review**:
  - New features MUST include updates to relevant `dev/specs/` documentation before merge
  - Code lacking idiomatic documentation (godoc, rustdoc, etc.) MUST be rejected
  - YAML spec files MUST validate against schemas (when schema defined)
  - Architecture changes MUST include ADR (Architecture Decision Record) in `dev/architecture/`

## Governance

This constitution supersedes all other project practices. Amendments require:

1. **Documentation**: Proposed change written clearly with rationale
2. **Community Approval**: Agreement from project maintainers (defined in `MAINTAINERS.md`; minimum 2 approvals for constitution changes)
3. **Migration Plan**: If breaking, a clear path for existing users with migration scripts or upgrade guides
4. **Version Bump**: Constitution version incremented appropriately (MAJOR for principle removal/redefinition, MINOR for new principle/section, PATCH for clarification/typo)

All pull requests MUST verify alignment with these principles. Exceptions require explicit documented approval and a note in the PR explaining the deviation.

**Approval Thresholds**:
- Constitution amendments: 2+ maintainer approvals
- Breaking changes (MAJOR version): 2+ maintainer approvals + migration plan
- New features (MINOR version): 1 maintainer approval
- Bug fixes/docs (PATCH version): 1 maintainer approval or auto-merge if CI passes
- Maintainers defined in `MAINTAINERS.md` with GitHub usernames and contact info

**CVE & Security Incident Handling**:
- Vulnerabilities reported via GitHub Security Advisories (private disclosure)
- Triage within 48 hours; severity assessed (critical/high/medium/low)
- Critical CVEs: patch within 7 days + emergency release
- High-severity CVEs: patch within 30 days + next scheduled release
- Medium/low CVEs: bundled into next minor/patch release
- Public disclosure after patch release; CHANGELOG.md updated with CVE-ID and credit to reporter

For runtime development guidance (coding style, common patterns, troubleshooting), see the project README.md and individual documentation files. This constitution defines the non-negotiable values and constraints; other documents provide practical implementation details.

**Version**: 1.4.0 | **Ratified**: 2025-12-24 | **Last Amended**: 2025-12-24
