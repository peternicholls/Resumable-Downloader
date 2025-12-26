# R04: Accessible Terminal UI Patterns - Research Findings

**Research ID**: R04  
**Status**: Complete  
**Last Updated**: 2025-12-26  
**Researcher**: Agent  
**Time Spent**: 3.5 hours

---

## Executive Summary

This research establishes comprehensive accessibility guidelines for SafeDownload's terminal UI, covering screen reader compatibility, WCAG-compliant color palettes, colorblind-safe design, and keyboard navigation standards.

**Key Findings:**
1. Screen readers interact with terminals through the terminal emulator, not the application directly - **plain text mode is essential**
2. The `NO_COLOR` environment variable is an industry standard that MUST be respected
3. Emoji + text pattern (constitution requirement) is validated as the correct approach
4. ANSI 16-color palettes should be used for maximum terminal compatibility
5. Dual navigation (vim-style AND arrow keys) provides best accessibility

**Recommendations:**
1. Implement `--plain` flag and auto-detect `NO_COLOR`, `TERM=dumb`
2. Use IBM's colorblind-safe palette as basis for status colors
3. Always pair color with emoji AND text labels (triple redundancy)
4. Support both vim-style (j/k) and arrow key navigation

---

## Screen Reader Compatibility

### How Screen Readers Handle Terminals

Screen readers **do not process terminal output directly**. Instead, they gather information from the terminal emulator through accessibility APIs. Key insights:

1. **Terminal emulator compatibility varies**: On Linux, xterm is NOT compatible with Orca, but GNOME Terminal IS compatible - despite identical visual appearance
2. **Screen readers read the text buffer**: They speak what's in the terminal's text buffer, including ANSI escape codes if not stripped
3. **Each program must be separately tested**: Visual similarity doesn't guarantee accessibility

### VoiceOver (macOS)

- **Built into macOS**: Activate with Cmd+F5
- **Terminal.app works reasonably well**: VoiceOver can read text output sequentially
- **Known issues**: Dynamic updates (like progress bars) can cause reading problems
- **Alternative**: TDSR (Terminal Screen Reader) provides better terminal-specific support
  - Navigation: Option+u (up line), Option+i (current line), Option+o (down line)
  - Speaks all output as it comes, unlike VoiceOver which may skip

### NVDA (Windows)

- **Free, open-source screen reader** for Windows
- **Works with CMD, PowerShell, and Windows Terminal**
- **Configuration matters**: Must be configured properly per terminal app
- **May skip lines** if not configured correctly, especially in MSYS2

### Orca (Linux)

- **Integrated with GNOME**: Works with gnome-terminal
- **Bundled with Ubuntu, Fedora**: No separate installation needed
- **Terminal compatibility**: GNOME Terminal (compatible), xterm (NOT compatible)
- **Speakup alternative**: Works with console-based applications when Orca doesn't

### Best Practices for Screen Reader Compatibility

1. **Emit plain-text labels before styled output** for interactive prompts
2. **Avoid reliance on ANSI escape codes** for critical information
3. **Progress updates should be textual**: "45% complete" not just a progress bar
4. **Auto-detect screen reader mode**:
   - Check `TERM=dumb`
   - Check `NO_COLOR` environment variable
   - Check for `SCREEN_READER` environment variable (custom)
5. **Avoid animated spinners**: They're "extremely problematic for screenreaders"
6. **Use plain progress text**: Log percentage instead of animated bar

---

## Color Palettes

### WCAG 2.1 AA Requirements

- **Minimum contrast ratio for normal text**: 4.5:1
- **Minimum contrast ratio for large text**: 3:1
- **Non-text contrast (UI components)**: 3:1

Key WCAG principles for terminal UIs:
- **1.4.1 Use of Color**: Color MUST NOT be the only visual means of conveying information
- **1.4.3 Contrast (Minimum)**: 4.5:1 for normal text
- **1.3.3 Sensory Characteristics**: Don't rely solely on color, size, visual location

### Light Theme Palette (ANSI Colors)

Based on terminal defaults with high contrast on light backgrounds:

| Element | ANSI Code | Color Name | Hex (approx) | Contrast vs #FFFFFF |
|---------|-----------|------------|--------------|---------------------|
| Normal text | 30 | Black | #000000 | 21:1 ✓ |
| Success | 32 | Green | #008000 | 5.1:1 ✓ |
| Error | 31 | Red | #CC0000 | 5.9:1 ✓ |
| Warning | 33 | Yellow/Brown | #806600 | 5.2:1 ✓ |
| Info | 34 | Blue | #0000CC | 6.6:1 ✓ |
| Muted | 90 | Bright Black | #666666 | 5.7:1 ✓ |

### Dark Theme Palette (ANSI Colors)

Bright variants for dark backgrounds:

| Element | ANSI Code | Color Name | Hex (approx) | Contrast vs #1A1A1A |
|---------|-----------|------------|--------------|---------------------|
| Normal text | 97 | Bright White | #FFFFFF | 18.1:1 ✓ |
| Success | 92 | Bright Green | #00FF00 | 8.2:1 ✓ |
| Error | 91 | Bright Red | #FF5555 | 5.5:1 ✓ |
| Warning | 93 | Bright Yellow | #FFFF55 | 15.4:1 ✓ |
| Info | 96 | Bright Cyan | #55FFFF | 12.1:1 ✓ |
| Muted | 37 | White | #AAAAAA | 8.6:1 ✓ |

### High-Contrast Theme Palette

Maximum contrast using only black, white, and bold:

| Element | ANSI Code | Color | Background | Contrast |
|---------|-----------|-------|------------|----------|
| Normal text | 0;37 | White | Black | 21:1 ✓ |
| Success | 1;37 | Bold White | Black | 21:1 ✓ |
| Error | 7 | Inverse | Black/White | 21:1 ✓ |
| Warning | 1;37 | Bold White | Black | 21:1 ✓ |
| Info | 0;37 | White | Black | 21:1 ✓ |
| Emphasis | 1 | Bold | N/A | N/A |

**High-contrast mode uses shape differentiation instead of color:**
- Success: `[OK]` prefix
- Error: `[ERROR]` prefix  
- Warning: `[WARN]` prefix

---

## Colorblind-Safe Design

### Types of Color Blindness

| Type | Affected | Population | Avoid |
|------|----------|------------|-------|
| Protanopia | Red-blind | 1% male | Red/Green pairs |
| Deuteranopia | Green-blind | 6% male | Red/Green pairs |
| Tritanopia | Blue-blind | 0.01% | Blue/Yellow pairs |

**Red-blindness (deuteranopia) is most common** - this is why red/green for error/success is problematic.

### IBM Color-Blind Safe Palette

IBM Design Library provides a validated colorblind-safe palette:

| Color | Hex | Use Case |
|-------|-----|----------|
| Ultramarine 40 | #648FFF | Info, links |
| Magenta 50 | #DC267F | Accent, emphasis |
| Gold 20 | #FFB000 | Warning |
| Orange 40 | #FE6100 | Error alternative |
| Indigo 50 | #785EF0 | Secondary accent |

### Safe Color Combinations for Terminal

**Recommended approach for SafeDownload:**

| Status | Color | Alternative | Safe With |
|--------|-------|-------------|-----------|
| Success | Cyan (#55FFFF) | Blue | All types |
| Error | Magenta (#DC267F) | Red+Bold | Deuteranopia |
| Warning | Yellow/Gold (#FFB000) | Orange | Protanopia |
| Info | Blue (#648FFF) | Cyan | All types |
| Neutral | White/Gray | N/A | All types |

**Key principle**: Avoid red+green combinations entirely. Use blue/orange or blue/magenta instead.

### Alternative Indicators (Beyond Color)

Constitution requirement: **triple redundancy** (emoji + text + optional color)

1. **Emoji prefixes**: Universally understood symbols
2. **Text labels**: Always spelled out
3. **Color**: Enhancement only, never sole indicator
4. **Shapes/patterns**: In progress bars (e.g., `[=====>----]` vs `[█████░░░░░]`)

---

## Status Indicator Pattern

### Current Constitution Requirement

> Status indicators combine emoji + text labels (e.g., "⏳ Queued", "✅ Completed")

### Validation: CONFIRMED ✓

This pattern aligns perfectly with accessibility best practices:

1. **WCAG 1.4.1**: Color is not the only means (emoji provides shape)
2. **WCAG 1.3.3**: Not relying on sensory characteristics alone (text provides meaning)
3. **Screen reader friendly**: Text label is read aloud
4. **Colorblind safe**: Emoji shape distinguishes status

### Recommended Indicators (Final)

| Status | Emoji | Text | ANSI Color | Plain Mode |
|--------|-------|------|------------|------------|
| Queued | ⏳ | Queued | 33 (Yellow) | `[QUEUED]` |
| Downloading | ⬇️ | Downloading | 96 (Cyan) | `[DOWNLOADING]` |
| Completed | ✅ | Completed | 92 (Green) | `[OK]` |
| Failed | ❌ | Failed | 91 (Red) | `[FAILED]` |
| Paused | ⏸️ | Paused | 37 (White) | `[PAUSED]` |
| Verifying | 🔍 | Verifying | 95 (Magenta) | `[VERIFYING]` |

### Display Format

```
Standard: ⏳ Queued    file.zip
Plain:    [QUEUED]    file.zip
```

---

## Keyboard Navigation

### Recommendation: Support BOTH Styles

For maximum accessibility, support **both** vim-style and standard navigation:

### vim-style Navigation (Power Users)

| Key | Action | Rationale |
|-----|--------|-----------|
| j | Move down | Vim standard |
| k | Move up | Vim standard |
| g | Go to top | Vim: `gg` |
| G | Go to bottom | Vim standard |
| / | Search/filter | Vim search |
| q | Quit | Universal |

### Standard Navigation (Accessibility)

| Key | Action | Rationale |
|-----|--------|-----------|
| ↓ / Tab | Move down | Standard UI |
| ↑ / Shift+Tab | Move up | Standard UI |
| Enter | Select/confirm | Standard UI |
| Escape | Cancel/back | Standard UI |
| Home | Go to top | Standard UI |
| End | Go to bottom | Standard UI |

### Slash Commands (Safari-style discoverability)

| Command | Action |
|---------|--------|
| /help | Show all commands |
| /pause N | Pause download N |
| /resume N | Resume download N |
| /cancel N | Cancel download N |
| /clear | Clear completed |
| /quit | Exit TUI |

### WCAG Compliance

- **2.1.1 Keyboard**: All functionality accessible via keyboard ✓
- **2.1.2 No Keyboard Trap**: Escape/quit always available ✓
- **2.4.7 Focus Visible**: Current selection highlighted ✓

---

## Testing Approach

### Without Specialized Hardware

#### 1. Using Built-in Screen Readers

**macOS (VoiceOver)**:
```bash
# Enable: System Settings → Accessibility → VoiceOver
# Or: Cmd+F5
# Test: Run safedownload --help and listen
```

**Linux (Orca)**:
```bash
# Install: sudo apt install orca
# Enable: orca --replace &
# Use with: gnome-terminal (NOT xterm)
```

#### 2. Text-to-Speech Testing

```bash
# Pipe output to espeak-ng
safedownload --help | espeak-ng

# If output is comprehensible, it's screen-reader friendly
```

#### 3. Grayscale Testing

```bash
# Take screenshot of TUI
# Convert to grayscale in image editor
# Verify all statuses are distinguishable
```

#### 4. Simulated Color Blindness

Online tools:
- [Coblis Color Blindness Simulator](https://www.color-blindness.com/coblis-color-blindness-simulator/)
- [Colorblinding Chrome Extension](https://chrome.google.com/webstore/detail/colorblinding)

#### 5. Plain Mode Testing

```bash
# Test plain mode explicitly
NO_COLOR=1 safedownload
TERM=dumb safedownload
safedownload --plain
```

### Automated Testing Checklist

Add to CI pipeline:

1. **Color detection**: Verify `NO_COLOR` and `TERM=dumb` produce no ANSI codes
2. **Output parsing**: Pipe `--help` through `cat -v` to check for escape codes
3. **Status indicators**: Regex test that all statuses have emoji + text
4. **Keyboard coverage**: E2E tests for all keyboard shortcuts

---

## --plain Flag Specification

### Purpose

1. **Machine-readable output** for scripts and log files
2. **Accessible output** for screen readers
3. **Low-bandwidth terminals** or serial consoles

### Behavior

When `--plain` is active (explicitly or auto-detected):

| Feature | Standard Mode | Plain Mode |
|---------|--------------|------------|
| ANSI colors | Yes | No |
| Emoji | Yes | ASCII alternatives |
| Progress bar | `[████░░░░]` | `45% complete` |
| Spinners | Animated | None |
| Decorative borders | Box-drawing chars | None |
| Status format | `✅ Completed` | `[OK] Completed` |

### Auto-Detection Rules

Plain mode MUST be automatically enabled when:

1. `NO_COLOR` environment variable is set (to any non-empty value)
2. `TERM=dumb`
3. stdout is not a TTY (piped/redirected)

```go
func shouldUsePlainMode() bool {
    // NO_COLOR standard: https://no-color.org/
    if noColor := os.Getenv("NO_COLOR"); noColor != "" {
        return true
    }
    // Dumb terminal
    if os.Getenv("TERM") == "dumb" {
        return true
    }
    // Not a TTY
    if !term.IsTerminal(int(os.Stdout.Fd())) {
        return true
    }
    return false
}
```

### CLI Override

```bash
# Force plain mode
safedownload --plain

# Force color even if auto-detected plain
safedownload --color=always
```

---

## termenv Library Integration

For Bubble Tea TUI (v1.1.0+), use **termenv** for terminal capability detection:

```go
import "github.com/muesli/termenv"

// Detect terminal color support
profile := termenv.ColorProfile()
switch profile {
case termenv.TrueColor:   // 16 million colors
case termenv.ANSI256:     // 256 colors
case termenv.ANSI:        // 16 colors
case termenv.Ascii:       // No color support
}

// Check NO_COLOR
if termenv.EnvNoColor() {
    // Use plain mode
}
```

**termenv features:**
- ★1600 GitHub stars
- Supports `NO_COLOR` standard
- Detects terminal capabilities
- MIT license
- Used by Bubble Tea ecosystem

---

## Key Quotes and References

### From NO_COLOR Standard (no-color.org)
> "Command-line software which adds ANSI color to its output by default should check for a `NO_COLOR` environment variable that, when present and not an empty string (regardless of its value), prevents the addition of ANSI color."

### From Seirdy's CLI Best Practices
> "Nearly all animated spinners are extremely problematic for screenreaders. A simple progress meter and/or numeric percentage combined with flags to enable/disable them is preferable."

> "Send your tool's output through a program like `espeak-ng` and listen to it. Can you make sense of the output?"

### From WCAG 2.1
> "Color is not used as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element." — WCAG 1.4.1

### From PCC Accessibility Guide
> "Two programs that present substantially the same interface may have different levels of accessibility. For example, on Linux, xterm terminal windows are not compatible with the Orca screen reader while GNOME terminals are compatible, even though the visual difference between the two is minimal."

---

## Research Sources

1. **WCAG 2.1 Quick Reference** - https://www.w3.org/WAI/WCAG21/quickref/
2. **NO_COLOR Standard** - https://no-color.org/
3. **Best practices for inclusive CLIs** - https://seirdy.one/posts/2022/06/10/cli-best-practices/
4. **IBM Color-Blind Safe Palette** - IBM Design Library
5. **Terminal colours are tricky** - Julia Evans (jvns.ca)
6. **PCC Screen Readers Introduction** - spot.pcc.edu
7. **termenv Library** - https://github.com/muesli/termenv

---

## Recommendations Summary

### MUST Implement (v0.2.0)

1. ✅ `--plain` flag with auto-detection
2. ✅ Respect `NO_COLOR` environment variable
3. ✅ Emoji + text for ALL status indicators
4. ✅ Colorblind-safe palette (avoid red/green)
5. ✅ Keyboard navigation without mouse requirement

### SHOULD Implement (v0.2.0)

1. 📋 `--theme` flag (light, dark, high-contrast)
2. 📋 Terminal width detection and adaptive layout
3. 📋 Both vim-style and arrow key navigation
4. 📋 ASCII fallback for emoji

### MAY Implement (v1.1.0+)

1. 🔮 SIGWINCH handling for terminal resize
2. 🔮 Custom theme configuration
3. 🔮 Sound alerts (optional)
4. 🔮 Braille display optimization

---

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2025-12-25 | Created document | - |
| 2025-12-26 | Completed research: screen readers, WCAG colors, colorblind safety, NO_COLOR standard, keyboard navigation | Agent |
