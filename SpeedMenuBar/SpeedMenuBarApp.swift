//
//  SpeedMenuBarApp.swift
//  SpeedMenuBar
//
//  Created by Kushal Vora on 12/28/25.
//

import SwiftUI
import AVFoundation
import ServiceManagement

@main
struct SpeedMenuBarApp: App {
    @State private var speedTest = SpeedTestManager()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 4) {
                Text("Network Speed Monitor")
                    .font(.headline)

                Divider()

                Text("Download: \(speedTest.result.download) Mbps")
                Text("Upload: \(speedTest.result.upload) Mbps")
                Text("Updated: \(speedTest.result.timestamp)")

                Divider()

                Button("Refresh Now") {
                    speedTest.runTest()
                }
                .keyboardShortcut("r")

                Divider()

                Button(speedTest.isPlayingSound ? "■ Stop modem sound" : "▶ Play modem sound") {
                    speedTest.toggleSound()
                }

                Toggle("Launch at login", isOn: $speedTest.launchAtLogin)

                Divider()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .padding(8)
        } label: {
            Text(speedTest.menuBarTitle)
        }
    }
}

@Observable
class SpeedTestManager: NSObject, AVAudioPlayerDelegate {
    var result = SpeedTestResult.empty
    var isTesting = false
    var isPlayingSound = false
    var launchAtLogin: Bool {
        didSet {
            setLaunchAtLogin(launchAtLogin)
        }
    }

    private let service = SpeedTestService()
    private var audioPlayer: AVAudioPlayer?

    var menuBarTitle: String {
        if isTesting {
            return "Testing..."
        } else if result.isError {
            return "⚠ Error"
        } else if result.download == "--" {
            return "-- ↓ / -- ↑ Mbps"
        } else {
            return "\(result.download) ↓ / \(result.upload) ↑ Mbps"
        }
    }

    override init() {
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
        super.init()
        runTest()
    }

    func runTest() {
        isTesting = true
        service.runTest { [weak self] result in
            self?.result = result
            self?.isTesting = false
        }
    }

    func toggleSound() {
        if isPlayingSound {
            stopSound()
        } else {
            playSound()
        }
    }

    private func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "modem", withExtension: "mp3") else {
            NSSound.beep()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlayingSound = true
        } catch {
            NSSound.beep()
        }
    }

    private func stopSound() {
        audioPlayer?.stop()
        isPlayingSound = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingSound = false
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to set launch at login: \(error)")
        }
    }
}
