//
//  LaunchAtLogin.swift
//  XKey
//
//  "Mở cùng macOS": registers 1xKey as a login item.
//  macOS 13+ uses SMAppService (shows up in System Settings > Login Items).
//  macOS 12 has no equivalent for a plain app, so it uses a LaunchAgent plist.
//

import AppKit
import Foundation
import ServiceManagement

enum LaunchAtLoginState: Equatable {
    case enabled
    case disabled
    /// Registered, but the user switched it off (or has not allowed it) in System Settings.
    case requiresApproval
}

enum LaunchAtLogin {
    private static let defaultAppliedKey = "org.xuanhieu.1xkey.loginItemDefaultApplied"
    private static let legacyLabel = "org.xuanhieu.1xkey.launch"

    // MARK: - State

    static func status() -> LaunchAtLoginState {
        if #available(macOS 13.0, *) {
            switch SMAppService.mainApp.status {
            case .enabled: return .enabled
            case .requiresApproval: return .requiresApproval
            default: return .disabled
            }
        }
        return FileManager.default.fileExists(atPath: legacyPlistURL.path) ? .enabled : .disabled
    }

    static func isEnabled() -> Bool {
        status() == .enabled
    }

    // MARK: - Change

    @discardableResult
    static func setEnabled(_ enabled: Bool) -> LaunchAtLoginState {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Already in the requested state, or macOS refused: the re-read below is the truth.
            }
        } else {
            if enabled {
                writeLegacyPlist()
            } else {
                try? FileManager.default.removeItem(at: legacyPlistURL)
            }
        }
        return status()
    }

    /// New installs start with the login item on, once. After that the user's choice wins,
    /// including turning it off. Skipped for builds running outside an Applications folder,
    /// because a login item pointing at a build directory would break on the next rebuild.
    static func applyDefaultOnce(defaults: UserDefaults = .standard,
                                 bundlePath: String = Bundle.main.bundlePath) {
        guard !defaults.bool(forKey: defaultAppliedKey) else { return }
        guard isInstalledInApplications(bundlePath) else { return }
        defaults.set(true, forKey: defaultAppliedKey)
        if status() == .disabled {
            setEnabled(true)
        }
    }

    static func isInstalledInApplications(_ bundlePath: String) -> Bool {
        let userApplications = NSHomeDirectory() + "/Applications/"
        return bundlePath.hasPrefix("/Applications/") || bundlePath.hasPrefix(userApplications)
    }

    static func openSystemSettings() {
        if #available(macOS 13.0, *) {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    // MARK: - macOS 12 fallback

    static var legacyPlistURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(legacyLabel).plist")
    }

    static func legacyPlist(executablePath: String) -> [String: Any] {
        [
            "Label": legacyLabel,
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false,
            "ProcessType": "Interactive",
        ]
    }

    private static func writeLegacyPlist() {
        guard let executable = Bundle.main.executablePath,
              let data = try? PropertyListSerialization.data(
                fromPropertyList: legacyPlist(executablePath: executable),
                format: .xml,
                options: 0)
        else { return }
        let url = legacyPlistURL
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }
}
