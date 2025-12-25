# SafeDownload TUI Improvement Guide

## Current Issues

The existing TUI implementation has several problems:

1. **Flashing** - Full screen redraws cause flickering
2. **Broken arrow keys** - Arrow keys send escape sequences that aren't handled
3. **Poor input handling** - Reading one character at a time is fragile
4. **Manual terminal control** - Using raw `tput` commands is error-prone

## Recommended Solution: Charm Gum

### Why Gum?

**Gum** (https://github.com/charmbracelet/gum) is a modern TUI toolkit that provides:

- ✅ Proper keyboard input handling (including arrow keys)
- ✅ Beautiful, professional UI components
- ✅ Single binary installation (no dependencies)
- ✅ Composable components (input, choose, filter, table, etc.)
- ✅ Cross-platform (macOS, Linux, Windows)
- ✅ Active development by Charm (creators of Bubble Tea framework)

### Installation

```bash
# macOS
brew install gum

# Linux (via snap)
sudo snap install gum

# Or download binary from:
# https://github.com/charmbracelet/gum/releases
```

### Alternative Options

If Gum is not available, consider:

1. **Dialog** - Traditional but robust
   ```bash
   # Install on macOS
   brew install dialog
   
   # Usually pre-installed on Linux
   sudo apt install dialog  # Debian/Ubuntu
   ```

2. **Whiptail** - Lightweight, often pre-installed
   - Available by default on Debian/Ubuntu
   - Simpler than Dialog but fewer features

## Implementation Strategy

### Option 1: Full Gum Integration (Recommended)

Replace the entire TUI with Gum components:
- Use `gum input` for command input
- Use `gum table` for download queue display
- Use `gum spin` for download progress
- Use `gum log` for command output

### Option 2: Hybrid Approach

Keep the layout but use Gum for input handling:
- Use Gum's input component for reliable keyboard input
- Keep the two-column display
- Add proper input buffering

### Option 3: Dialog-based Alternative

Use Dialog for a different but robust interface:
- Menu-driven interface
- Built-in input forms
- Works on any system with dialog installed

## Key Improvements Needed

1. **Input Handling**
   - Use a proper input library instead of `read -n 1`
   - Handle escape sequences for arrow keys
   - Implement input history

2. **Display Updates**
   - Use double buffering to prevent flashing
   - Only update changed regions
   - Use proper ANSI escape sequences

3. **Signal Handling**
   - Properly handle SIGWINCH (terminal resize)
   - Clean up on SIGINT/SIGTERM
   - Restore terminal state on exit

## Example Gum Implementation

See `safedownload-gum` for a complete implementation using Gum components.

## Testing

After implementing improvements:

1. Test arrow key navigation
2. Test rapid input (no lag or lost characters)
3. Test terminal resize
4. Test with different terminal emulators
5. Verify no screen flashing

## Performance Benefits

Using Gum or Dialog will:
- Reduce CPU usage (no constant polling)
- Eliminate screen flashing
- Provide proper input buffering
- Handle edge cases automatically
- Improve overall user experience

## Migration Path

1. Install Gum on your system
2. Test the new `safedownload-gum` implementation
3. Once stable, replace the `-g` flag implementation
4. Keep fallback to CLI mode if Gum not installed
