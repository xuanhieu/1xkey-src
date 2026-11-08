import Cocoa
import Carbon
import IOKit

struct SecureInputObservation: Equatable, Sendable {
    let isEnabled: Bool
    let holderPID: pid_t
    let holderAppName: String

    static let inactive = SecureInputObservation(isEnabled: false,
                                                 holderPID: 0,
                                                 holderAppName: "Unknown")

    var statePID: pid_t {
        guard isEnabled else { return 0 }
        return holderPID == 0 ? -1 : holderPID
    }

    nonisolated static func == (
        lhs: SecureInputObservation,
        rhs: SecureInputObservation
    ) -> Bool {
        lhs.isEnabled == rhs.isEnabled
            && lhs.holderPID == rhs.holderPID
            && lhs.holderAppName == rhs.holderAppName
    }
}

protocol SecureInputDetecting {
    var observation: SecureInputObservation { get }
}

final class SystemSecureInputDetector: SecureInputDetecting {
    var observation: SecureInputObservation {
        let isEnabled = IsSecureEventInputEnabled()
        guard isEnabled else { return .inactive }

        let root = IORegistryGetRootEntry(kIOMainPortDefault)
        guard root != IO_OBJECT_NULL else {
            return SecureInputObservation(isEnabled: true,
                                          holderPID: -1,
                                          holderAppName: "Unknown")
        }
        defer { IOObjectRelease(root) }

        guard let value = IORegistryEntryCreateCFProperty(
            root,
            "IOConsoleUsers" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue(),
        let users = value as? [[String: Any]]
        else {
            return SecureInputObservation(isEnabled: true,
                                          holderPID: -1,
                                          holderAppName: "Unknown")
        }

        for user in users {
            guard user["kCGSSessionOnConsoleKey"] as? Bool == true,
                  let value = user["kCGSSessionSecureInputPID"] as? Int,
                  value != 0
            else { continue }

            let pid = pid_t(value)
            let app = NSRunningApplication(processIdentifier: pid)
            return SecureInputObservation(
                isEnabled: true,
                holderPID: pid,
                holderAppName: app?.localizedName ?? app?.bundleIdentifier ?? "PID \(pid)"
            )
        }

        return SecureInputObservation(isEnabled: true,
                                      holderPID: -1,
                                      holderAppName: "Unknown")
    }

    static var isXKeyIMSelectedInputSource: Bool {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
        else { return false }
        let identifier = Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
        return identifier.hasPrefix("org.xuanhieu.inputmethod.1xkey")
    }
}

// MARK: - What the user can do about it

/// What 1xKey can offer when another process holds Secure Input. macOS hides keystrokes from
/// every event tap while it is held, so the only real fix is to make the holder let go.
enum SecureInputRemedy: Equatable, Sendable {
    /// Nothing 1xKey can safely do (a genuine password field, a system process, unknown holder).
    case none
    /// Chromium browsers leak Secure Input from a stale password field. Their
    /// `<scheme>://restart` page relaunches the browser and restores every open tab.
    case relaunchBrowser(bundleId: String, scheme: String)
    /// Any other holder: ask it to quit (it still gets to prompt about unsaved work).
    case quitHolder(pid: pid_t)
}

struct SecureInputAdvice: Equatable, Sendable {
    enum Reason: Equatable, Sendable {
        /// The holder is frontmost and its focused field is a real password field: expected.
        case passwordField
        /// The holder is frontmost but the focused field is not a password field (or cannot be read).
        case possibleLeak
        /// The holder is not the app being typed into.
        case background
        /// loginwindow, SecurityAgent and friends.
        case system
        /// The holder's PID could not be read.
        case unknown
    }

    let holderName: String
    let reason: Reason
    let remedy: SecureInputRemedy

    var headline: String {
        switch reason {
        case .passwordField: return "Đang ở ô mật khẩu"
        case .system: return "macOS đang giữ Secure Input"
        case .unknown: return "Có ứng dụng đang giữ Secure Input"
        case .possibleLeak, .background: return "\(holderName) đang chặn bàn phím"
        }
    }

    var detail: String {
        switch reason {
        case .passwordField:
            return "1xKey tạm nghỉ để bảo vệ mật khẩu. Rời khỏi ô mật khẩu là gõ lại bình thường."
        case .system:
            return "Màn hình khóa hoặc hộp thoại hệ thống đang giữ phím. Mở khóa hoặc đóng hộp thoại là xong."
        case .unknown:
            return "Không xác định được ứng dụng nào. Khóa rồi mở khóa màn hình (⌃⌘Q) thường gỡ được."
        case .possibleLeak:
            return "\(holderName) giữ Secure Input dù bạn không ở ô mật khẩu, thường do một tab còn ô mật khẩu đang chọn. Bấm ra khỏi ô mật khẩu hoặc đóng tab đó; nếu vẫn không được thì khởi động lại."
        case .background:
            return "\(holderName) vẫn giữ Secure Input khi chạy nền. Thoát hoặc khởi động lại là gõ được."
        }
    }

    var actionTitle: String? {
        switch remedy {
        case .none: return nil
        case .relaunchBrowser: return "Khởi động lại \(holderName) (giữ nguyên tab)"
        case .quitHolder: return "Thoát \(holderName)"
        }
    }
}

enum SecureInputAdvisor {
    static let systemHolderBundleIds: Set<String> = [
        "com.apple.loginwindow",
        "com.apple.SecurityAgent",
        "com.apple.systemuiserver",
        "com.apple.UserNotificationCenter",
        "com.apple.coreservices.uiagent",
    ]

    /// Browsers whose `<scheme>://restart` relaunches them and restores the session.
    static let chromiumRestartSchemes: [String: String] = [
        "com.google.Chrome": "chrome",
        "com.google.Chrome.beta": "chrome",
        "com.google.Chrome.canary": "chrome",
        "org.chromium.Chromium": "chrome",
        "com.microsoft.edgemac": "edge",
        "com.brave.Browser": "brave",
        "com.vivaldi.Vivaldi": "vivaldi",
        "com.operasoftware.Opera": "opera",
    ]

    /// - Parameters:
    ///   - frontmostPID: the app the user is typing into.
    ///   - focusedFieldIsSecure: only meaningful when the holder is frontmost; nil = could not tell.
    static func advise(observation: SecureInputObservation,
                       holderBundleId: String?,
                       frontmostPID: pid_t?,
                       focusedFieldIsSecure: Bool?) -> SecureInputAdvice {
        let name = observation.holderAppName
        guard observation.holderPID > 0 else {
            return SecureInputAdvice(holderName: name, reason: .unknown, remedy: .none)
        }
        if let id = holderBundleId, systemHolderBundleIds.contains(id) {
            return SecureInputAdvice(holderName: name, reason: .system, remedy: .none)
        }

        let remedy: SecureInputRemedy
        if let id = holderBundleId, let scheme = chromiumRestartSchemes[id] {
            remedy = .relaunchBrowser(bundleId: id, scheme: scheme)
        } else {
            remedy = .quitHolder(pid: observation.holderPID)
        }

        if frontmostPID == observation.holderPID {
            if focusedFieldIsSecure == true {
                return SecureInputAdvice(holderName: name, reason: .passwordField, remedy: .none)
            }
            return SecureInputAdvice(holderName: name, reason: .possibleLeak, remedy: remedy)
        }
        return SecureInputAdvice(holderName: name, reason: .background, remedy: remedy)
    }
}
