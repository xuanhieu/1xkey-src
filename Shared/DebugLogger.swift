//
//  DebugLogger.swift
//  XKey / XKeyIM
//
//  Centralized logging utility that works in both XKey and XKeyIM
//  Optimized for high-frequency logging without blocking the caller
//

import Foundation

// Forward declaration for DebugWindowController (only available in XKey)
// This protocol allows us to reference the debug window without importing AppKit
protocol DebugWindowControllerProtocol: AnyObject {
    var isLoggingEnabled: Bool { get }
    var isVerboseLogging: Bool { get }
    func logEvent(_ message: String)
}

/// Centralized debug logger that works in both XKey and XKeyIM
/// Optimized for high-frequency logging without blocking
/// Uses fire-and-forget file writing for zero-blocking logging
class DebugLogger {

    /// Shared instance
    static let shared = DebugLogger()

    /// Log file URL (shared with DebugViewModel)
    private let logFileURL: URL
    
    /// Reference to debug window controller (set by AppDelegate in XKey)
    /// Using protocol to avoid dependency on AppKit/UI code
    weak var debugWindowController: DebugWindowControllerProtocol? {
        didSet {
            // When debug window is connected, use it for logging settings
            if let controller = debugWindowController {
                isLoggingEnabled = controller.isLoggingEnabled
                isVerboseLogging = controller.isVerboseLogging
            } else {
                // Debug window disconnected - disable file logging in XKey app
                isLoggingEnabled = false
                isVerboseLogging = false
            }
        }
    }
    
    /// Whether verbose logging is enabled
    var isVerboseLogging: Bool = true
    
    /// Whether logging is enabled (default: false, explicitly enabled by XKey/XKeyIM based on debugModeEnabled setting)
    var isLoggingEnabled: Bool = false
    
    /// Background queue for async file writing
    private let logQueue = DispatchQueue(label: "com.xkey.logger", qos: .utility)
    
    /// Lock for thread-safe file writes
    private let writeLock = NSLock()

    private init() {
        // Use same log file as DebugViewModel
        logFileURL = Self.defaultLogFileURL
    }

    // MARK: - Log File (owner-only)

    /// ~/XKey_Debug.log — shared by XKey (DebugViewModel) and XKeyIM.
    static var defaultLogFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("XKey_Debug.log")
    }

    /// POSIX permissions for the debug log: readable and writable by the owner only.
    static let logFilePermissions: Int = 0o600

    /// Create the log file (0600) with `contents`, replacing any existing file.
    static func createLogFile(at url: URL, contents: Data) {
        let attributes: [FileAttributeKey: Any] = [.posixPermissions: logFilePermissions]
        FileManager.default.createFile(atPath: url.path, contents: contents, attributes: attributes)
        // createFile keeps an existing file's mode on some paths; enforce 0600 explicitly.
        try? FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
    }

    /// Open the log file for appending, creating it with 0600 permissions when missing
    /// and tightening an existing file to 0600.
    static func openLogFileForAppending(at url: URL) throws -> FileHandle {
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.setAttributes([.posixPermissions: logFilePermissions], ofItemAtPath: url.path)
        } else {
            createLogFile(at: url, contents: Data())
        }
        return try FileHandle(forWritingTo: url)
    }

    /// Delete the log file (used when logging is turned off).
    static func removeLogFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Last line of defence for privacy: strips anything a log line could use to
    /// reconstruct what was typed (character codes, key codes, quoted text, U+ scalars)
    /// before it reaches the log file or the debug window.
    static func redact(_ text: String) -> String {
        var out = text
        for (pattern, template) in redactionRules {
            out = pattern.stringByReplacingMatches(in: out,
                                                   range: NSRange(out.startIndex..., in: out),
                                                   withTemplate: template)
        }
        return out
    }

    private static let redactionRules: [(NSRegularExpression, String)] = [
        (#"0x[0-9A-Fa-f]{2,}"#, "0x?"),
        (#"U\+[0-9A-Fa-f]{4,6}"#, "U+?"),
        (#"(?i)\b(key ?code|code|char|key|unicode|scalar)(\s*[=:]\s*)\d+"#, "$1$2?"),
        (#"'[^'\n]{1,200}'"#, "'…'"),
        (#""[^"\n]{1,200}""#, "\"…\""),
    ].map { (try! NSRegularExpression(pattern: $0.0), $0.1) }

    /// Write to file asynchronously (fire-and-forget)
    private func writeToFile(_ text: String) {
        let text = Self.redact(text)
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            let line = "[\(timestamp)] \(text)\n"
            
            guard let data = line.data(using: .utf8) else { return }
            
            do {
                let handle = try Self.openLogFileForAppending(at: self.logFileURL)
                handle.seekToEndOfFile()
                handle.write(data)
                try handle.close()
            } catch {
                // Ignore write errors - fire and forget
            }
        }
    }

    /// Log a message (non-blocking, fire-and-forget)
    /// - Parameters:
    ///   - message: The message to log
    ///   - source: The source component (e.g., "VNEngine", "MacroManager")
    ///   - level: Log level (info, warning, error)
    func log(_ message: @autoclosure () -> String, source: String = "", level: LogLevel = .info) {
        guard isLoggingEnabled else { return }

        let message = message()
        let prefix = level.emoji
        let fullMessage: String
        if prefix.isEmpty {
            fullMessage = source.isEmpty ? message : "[\(source)] \(message)"
        } else {
            fullMessage = source.isEmpty ? "\(prefix) \(message)" : "\(prefix) [\(source)] \(message)"
        }

        // Check level before writing
        switch level {
        case .error, .warning:
            // Always log errors and warnings
            writeToFile(fullMessage)
        case .info, .success:
            // Only log info/success in DEBUG mode
            writeToFile(fullMessage)
        case .debug:
            // Only log debug if verbose mode is enabled
            let verbose = debugWindowController?.isVerboseLogging ?? isVerboseLogging
            if verbose {
                writeToFile(fullMessage)
            }
        }
    }

    /// Log an info message
    func info(_ message: @autoclosure () -> String, source: String = "") {
        log(message(), source: source, level: .info)
    }

    /// Log a warning message
    func warning(_ message: @autoclosure () -> String, source: String = "") {
        log(message(), source: source, level: .warning)
    }

    /// Log an error message
    func error(_ message: @autoclosure () -> String, source: String = "") {
        log(message(), source: source, level: .error)
    }

    /// Log a success message
    func success(_ message: @autoclosure () -> String, source: String = "") {
        log(message(), source: source, level: .success)
    }

    /// Log a debug message (only if verbose logging is enabled)
    func debug(_ message: @autoclosure () -> String, source: String = "") {
        let verbose = debugWindowController?.isVerboseLogging ?? isVerboseLogging
        guard verbose else { return }
        log(message(), source: source, level: .debug)
    }
}

// MARK: - Log Level

enum LogLevel {
    case info
    case warning
    case error
    case success
    case debug

    var emoji: String {
        switch self {
        case .info: return ""
        case .warning: return "[WARN]"
        case .error: return "[ERROR]"
        case .success: return "[OK]"
        case .debug: return "[DEBUG]"
        }
    }
}

// MARK: - Convenience Global Functions

/// Log an info message to debug window
@inline(__always)
func logInfo(_ message: String, source: String = "") {
    DebugLogger.shared.info(message, source: source)
}

/// Log a warning message to debug window
@inline(__always)
func logWarning(_ message: String, source: String = "") {
    DebugLogger.shared.warning(message, source: source)
}

/// Log an error message to debug window
@inline(__always)
func logError(_ message: String, source: String = "") {
    DebugLogger.shared.error(message, source: source)
}

/// Log a success message to debug window
@inline(__always)
func logSuccess(_ message: String, source: String = "") {
    DebugLogger.shared.success(message, source: source)
}

/// Log a debug message to debug window (only if verbose logging is enabled)
@inline(__always)
func logDebug(_ message: String, source: String = "") {
    DebugLogger.shared.debug(message, source: source)
}

// MARK: - Aliases for SharedSettings compatibility

/// Alias for logInfo (used by SharedSettings)
@inline(__always)
func sharedLogInfo(_ message: String, source: String = "") {
    logInfo(message, source: source)
}

/// Alias for logWarning (used by SharedSettings)
@inline(__always)
func sharedLogWarning(_ message: String, source: String = "") {
    logWarning(message, source: source)
}

/// Alias for logError (used by SharedSettings)
@inline(__always)
func sharedLogError(_ message: String, source: String = "") {
    logError(message, source: source)
}

/// Alias for logSuccess (used by SharedSettings)
@inline(__always)
func sharedLogSuccess(_ message: String, source: String = "") {
    logSuccess(message, source: source)
}

/// Alias for logDebug (used by SharedSettings)
@inline(__always)
func sharedLogDebug(_ message: String, source: String = "") {
    logDebug(message, source: source)
}
