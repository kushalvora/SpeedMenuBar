# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SpeedMenuBar is a native macOS menu bar app that displays internet speed using fast-cli (Netflix's speed test). The app shows download/upload speeds in the menu bar and provides a dropdown with detailed info, modem sound playback, and launch at login.

**GitHub:** https://github.com/kushalvora/SpeedMenuBar

## Prerequisites

- **Xcode** (full version from Mac App Store)
- **fast-cli**: `npm install --global fast-cli`
- **Node.js**: `brew install node` (if needed)

## Build Commands

```bash
# Build from terminal (run from SpeedMenuBar/SpeedMenuBar directory)
xcodebuild -project SpeedMenuBar.xcodeproj -scheme SpeedMenuBar -configuration Release build

# Clean build (fixes caching issues)
rm -rf ~/Library/Developer/Xcode/DerivedData/SpeedMenuBar-*
xcodebuild -project SpeedMenuBar.xcodeproj -scheme SpeedMenuBar -configuration Debug build

# Run the built app
open ~/Library/Developer/Xcode/DerivedData/SpeedMenuBar-*/Build/Products/Debug/SpeedMenuBar.app
```

## Architecture

Pure SwiftUI macOS app using `MenuBarExtra` (no AppDelegate). Configured as menu bar-only via `LSUIElement = true` and `ENABLE_APP_SANDBOX = NO` (required to shell out to fast-cli).

**Files:**
- `SpeedMenuBarApp.swift` - App entry point with MenuBarExtra scene, SpeedTestManager class
- `SpeedTestService.swift` - Runs `fast --upload --json` via Process, parses JSON
- `modem.mp3` - Dialup modem sound effect (bundled resource)

**Key classes:**
- `SpeedTestManager` (@Observable) - Manages state, sound playback (AVAudioPlayer), launch at login (SMAppService)
- `SpeedTestService` - Executes fast-cli in background thread, returns SpeedTestResult

**Data flow:**
1. MenuBarExtra displays `speedTest.menuBarTitle`
2. On refresh, SpeedTestService runs `fast --upload --json` in background
3. JSON parsed for downloadSpeed/uploadSpeed
4. @Observable updates UI automatically

## Creating Releases

```bash
# Build Release version
xcodebuild -project SpeedMenuBar.xcodeproj -scheme SpeedMenuBar -configuration Release build

# Copy and zip
cp -R ~/Library/Developer/Xcode/DerivedData/SpeedMenuBar-*/Build/Products/Release/SpeedMenuBar.app .
zip -r SpeedMenuBar-vX.X.zip SpeedMenuBar.app

# Create GitHub release
gh release create vX.X SpeedMenuBar-vX.X.zip --title "SpeedMenuBar vX.X" --notes "Release notes here"
```

## External Dependency

The app shells out to `fast` via `/usr/bin/env fast` with PATH augmented to include `/opt/homebrew/bin:/usr/local/bin`. If fast-cli isn't found, check `which fast`.
