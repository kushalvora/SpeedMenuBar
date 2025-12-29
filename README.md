# SpeedMenuBar

A macOS menu bar app that displays your internet speed using [fast-cli](https://github.com/sindresorhus/fast-cli) (Netflix's speed test).

![Menu Bar Preview](screenshot.png)

## Features

- Shows download/upload speeds in the menu bar (Mbps)
- Click to see detailed speed info
- **⌘R** to refresh speed test
- Play classic dialup modem sound
- Launch at login option

## Requirements

- macOS 13.0+
- [fast-cli](https://github.com/sindresorhus/fast-cli) installed

## Installation

### Install fast-cli first

```bash
# Install Node.js if needed
brew install node

# Install fast-cli
npm install --global fast-cli
```

### Option A: Build from source (requires Xcode)

1. Clone this repo
2. Open `SpeedMenuBar.xcodeproj` in Xcode
3. Press ⌘R to build and run

### Option B: Download release

Download the latest `.app` from [Releases](../../releases) and move to Applications.

## Usage

- Click the menu bar item to see detailed speeds
- Press **⌘R** or click "Refresh Now" to run a new speed test
- Enable "Launch at login" to start automatically
- Click "Play modem sound" for nostalgia

## License

MIT
