//
//  AppVersion.swift
//  XKey
//
//  Utility to get app version from Info.plist
//

import AppKit

struct AppVersion {
    /// Get the app version from CFBundleShortVersionString in Info.plist
    static var current: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0" // Fallback
    }
    
    /// Get the build number from CFBundleVersion in Info.plist
    static var build: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1" // Fallback
    }
    
    /// Get full version string (e.g., "1.0.0 (1)")
    static var fullVersion: String {
        return "\(current) (\(build))"
    }
}

/// Author credit shown in Settings, the menu bar popover, the debug window and every alert.
enum AppCredits {
    static let author = "Phạm Xuân Hiếu"
    static let website = "1x.xuanhieu.org/key"
    /// One-line credit, e.g. "1xKey 1.2.25 · © 2026 Phạm Xuân Hiếu"
    static var line: String { "1xKey \(AppVersion.current) · © 2026 \(author)" }
    static let builtBy = "Phát triển bởi Phạm Xuân Hiếu"
    static let slogan = "Bộ gõ đơn giản, tối giản, thuận tiện cho người Việt chỉ muốn gõ tiếng Việt chuẩn."
    static let upstream = "Dựa trên XKey (xmannv, MIT) và OpenKey (Mai Vũ Tuyên, GPL-3.0)"
}

extension NSAlert {
    /// NSAlert carrying the 1xKey credit line under its buttons.
    static func withCredits() -> NSAlert {
        let alert = NSAlert()
        let label = NSTextField(labelWithString: AppCredits.line)
        label.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        label.textColor = .secondaryLabelColor
        label.sizeToFit()
        alert.accessoryView = label
        return alert
    }
}
