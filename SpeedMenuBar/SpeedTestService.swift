//
//  SpeedTestService.swift
//  SpeedMenuBar
//

import Foundation

struct SpeedTestResult {
    let download: String
    let upload: String
    let timestamp: String
    let isError: Bool

    static let empty = SpeedTestResult(download: "--", upload: "--", timestamp: "--", isError: false)
    static let testing = SpeedTestResult(download: "...", upload: "...", timestamp: "Testing", isError: false)
}

class SpeedTestService {
    func runTest(completion: @escaping (SpeedTestResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.executeFastCLI()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func executeFastCLI() -> SpeedTestResult {
        let task = Process()
        let pipe = Pipe()

        // Use /usr/bin/env to find fast in PATH
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["fast", "--upload", "--json"]
        task.standardOutput = pipe
        task.standardError = pipe

        // Set PATH to include homebrew locations
        var env = ProcessInfo.processInfo.environment
        let additionalPaths = "/opt/homebrew/bin:/usr/local/bin"
        if let existingPath = env["PATH"] {
            env["PATH"] = "\(additionalPaths):\(existingPath)"
        } else {
            env["PATH"] = additionalPaths
        }
        task.environment = env

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return parseOutput(output)
            }
        } catch {
            print("Error running fast-cli: \(error)")
        }

        return SpeedTestResult(download: "Error", upload: "Error", timestamp: currentTime(), isError: true)
    }

    private func parseOutput(_ output: String) -> SpeedTestResult {
        // fast --upload --json outputs JSON like:
        // {"downloadSpeed":260,"uploadSpeed":280,...}

        var download = "--"
        var upload = "--"

        if let data = output.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let dl = json["downloadSpeed"] as? Double {
                download = String(Int(dl))
            }
            if let ul = json["uploadSpeed"] as? Double {
                upload = String(Int(ul))
            }
        }

        let isError = download == "--" && upload == "--"
        return SpeedTestResult(download: download, upload: upload, timestamp: currentTime(), isError: isError)
    }

    private func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
