//
//  SharedSettings.swift
//  XKey
//
//  Shared settings between XKey (menu bar) and XKeyIM (Input Method)
//  Uses App Group for cross-app communication
//

import Foundation
import AppKit
import Darwin

/// 1xKey is ad-hoc signed (no Team ID), so it cannot use an App Group container.
/// Both processes are non-sandboxed, so they share ~/Library/Application Support/1xKey/.
let kXKeySharedDomain = "org.xuanhieu.1xkey.shared"

/// Shared data directory for 1xKey and 1xKeyIM, created on first use (0700).
let kXKeySharedDirectory: URL = {
    let appSupport = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/1xKey", isDirectory: true)
    try? FileManager.default.createDirectory(at: appSupport,
                                             withIntermediateDirectories: true,
                                             attributes: [.posixPermissions: 0o700])
    return appSupport
}()

/// Keys for shared settings
enum SharedSettingsKey: String {
    // Hotkey settings
    case toggleHotkeyCode = "XKey.toggleHotkeyCode"
    case toggleHotkeyModifiers = "XKey.toggleHotkeyModifiers"
    case toggleHotkeyIsModifierOnly = "XKey.toggleHotkeyIsModifierOnly"
    case undoTypingEnabled = "XKey.undoTypingEnabled"
    case undoTypingHotkeyCode = "XKey.undoTypingHotkeyCode"
    case undoTypingHotkeyModifiers = "XKey.undoTypingHotkeyModifiers"
    case undoTypingHotkeyIsModifierOnly = "XKey.undoTypingHotkeyIsModifierOnly"
    case beepOnToggle = "XKey.beepOnToggle"

    // Input settings
    case inputMethod = "XKey.inputMethod"
    case codeTable = "XKey.codeTable"
    case modernStyle = "XKey.modernStyle"
    case spellCheckEnabled = "XKey.spellCheckEnabled"

    // Advanced settings
    case quickTelexEnabled = "XKey.quickTelexEnabled"
    case quickStartConsonantEnabled = "XKey.quickStartConsonantEnabled"
    case quickEndConsonantEnabled = "XKey.quickEndConsonantEnabled"
    case upperCaseFirstChar = "XKey.upperCaseFirstChar"
    case capitalizeOnlyAfterSpace = "XKey.capitalizeOnlyAfterSpace"
    case restoreIfWrongSpelling = "XKey.restoreIfWrongSpelling"
    case instantRestoreOnWrongSpelling = "XKey.instantRestoreOnWrongSpelling"
    case skipRestoreForUppercaseVietnameseAbbreviations = "XKey.skipRestoreForUppercaseVietnameseAbbreviations"

    case customConsonantEnabled = "XKey.customConsonantEnabled"
    case customConsonants = "XKey.customConsonants"
    case tempOffToolbarEnabled = "XKey.tempOffToolbarEnabled"
    case tempOffToolbarHotkeyCode = "XKey.tempOffToolbarHotkeyCode"
    case tempOffToolbarHotkeyModifiers = "XKey.tempOffToolbarHotkeyModifiers"
    case convertToolHotkeyCode = "XKey.convertToolHotkeyCode"
    case convertToolHotkeyModifiers = "XKey.convertToolHotkeyModifiers"
    case addToDictionaryHotkeyCode = "XKey.addToDictionaryHotkeyCode"
    case addToDictionaryHotkeyModifiers = "XKey.addToDictionaryHotkeyModifiers"

    // Macro settings
    case macroEnabled = "XKey.macroEnabled"
    case macroInEnglishMode = "XKey.macroInEnglishMode"
    case autoCapsMacro = "XKey.autoCapsMacro"
    case addSpaceAfterMacro = "XKey.addSpaceAfterMacro"
    case yieldMacroToSystemReplacement = "XKey.yieldMacroToSystemReplacement"
    case macros = "XKey.macros"

    // Smart switch settings
    case smartSwitchEnabled = "XKey.smartSwitchEnabled"
    case smartSwitchData = "XKey.smartSwitchData"          // JSON-encoded [String: Int] per-app language map

    // Debug settings
    case debugModeEnabled = "XKey.debugModeEnabled"
    case debugHotkeyCode = "XKey.debugHotkeyCode"
    case debugHotkeyModifiers = "XKey.debugHotkeyModifiers"
    case openDebugOnLaunch = "XKey.openDebugOnLaunch"

    // IMKit settings
    case imkitUseMarkedText = "XKey.imkitUseMarkedText"
    case switchToXKeyHotkeyCode = "XKey.switchToXKeyHotkeyCode"
    case switchToXKeyHotkeyModifiers = "XKey.switchToXKeyHotkeyModifiers"
    case switchToXKeyHotkeyIsModifierOnly = "XKey.switchToXKeyHotkeyIsModifierOnly"

    // UI settings
    case showDockIcon = "XKey.showDockIcon"
    case startAtLogin = "XKey.startAtLogin"
    case menuBarIconStyle = "XKey.menuBarIconStyle"
    case statusBarClickToToggle = "XKey.statusBarClickToToggle"
    case appLanguage = "XKey.appLanguage"
    case autoCheckForUpdates = "XKey.autoCheckForUpdates"

    // Excluded apps
    case excludedApps = "XKey.excludedApps"
    case exclusionRulesEnabled = "XKey.exclusionRulesEnabled"
    case toggleExclusionHotkeyCode = "XKey.toggleExclusionHotkeyCode"
    case toggleExclusionHotkeyModifiers = "XKey.toggleExclusionHotkeyModifiers"

    // Remote desktop injection mode
    case remoteDesktopInjectMode = "XKey.remoteDesktopInjectMode"

    // Cross-process event tap ownership and request/ack handoff barrier
    case xkeyIMTapArmed = "XKey.xkeyIMTapArmed"
    case xkeyIMTapPID = "XKey.xkeyIMTapPID"
    case xkeyMainPID = "XKey.xkeyMainPID"
    case inputHandoffRequestGeneration = "XKey.inputHandoffRequestGeneration"
    case inputHandoffRequesterPID = "XKey.inputHandoffRequesterPID"
    case inputHandoffAcknowledgedGeneration = "XKey.inputHandoffAcknowledgedGeneration"

    // Global Vietnamese on/off, shared by both processes
    case vietnameseEnabled = "XKey.vietnameseEnabled"

    // Remote desktop target mode (this machine is being remoted into)
    case isRemoteDesktopTarget = "XKey.isRemoteDesktopTarget"
    
    // Window Title Rules toggle
    case windowTitleRulesEnabled = "XKey.windowTitleRulesEnabled"
    case toggleWindowRulesHotkeyCode = "XKey.toggleWindowRulesHotkeyCode"
    case toggleWindowRulesHotkeyModifiers = "XKey.toggleWindowRulesHotkeyModifiers"

    // Input Source Management
    case inputSourceConfig = "XKey.inputSourceConfig"
    
    // Local data (macros, window title rules)
    case macrosData = "XKey.macrosData"
    case windowTitleRules = "XKey.windowTitleRules"
    case disabledBuiltInRules = "XKey.disabledBuiltInRules"        // Rules enabled by default, now disabled by user
    case enabledBuiltInRules = "XKey.enabledBuiltInRules"          // Rules disabled by default, now enabled by user
    
    // User dictionary (custom words to skip spell check)
    case userDictionaryWords = "XKey.userDictionaryWords"
}

struct InputOwnershipHandoffRequest: Equatable {
    let generation: Int
    let requesterPID: Int
}

struct InputOwnershipHandoffSnapshot: Equatable {
    let requestGeneration: Int
    let requesterPID: Int
    let acknowledgedGeneration: Int
    let mainPID: Int
    let xkeyIMTapArmed: Bool
    let xkeyIMTapPID: Int
}

protocol InputOwnershipHandoffStore: AnyObject {
    var snapshot: InputOwnershipHandoffSnapshot { get }
    func beginInputOwnershipHandoff(requesterPID: Int) -> InputOwnershipHandoffRequest
    func acknowledgeInputOwnershipHandoff(_ request: InputOwnershipHandoffRequest) -> Bool
    func cancelInputOwnershipHandoff(_ request: InputOwnershipHandoffRequest) -> Bool
    func registerXKeyMainProcess(pid: Int)
    func unregisterXKeyMainProcess(pid: Int)
}

enum InputOwnershipProcessState {
    case matching
    case absent
    case unknown
}

protocol InputOwnershipProcessChecking {
    func state(of pid: Int, expectedBundleIdentifier: String) -> InputOwnershipProcessState
}

struct SystemInputOwnershipProcessChecker: InputOwnershipProcessChecking {
    func state(of pid: Int, expectedBundleIdentifier: String) -> InputOwnershipProcessState {
        guard pid > 0, kill(pid_t(pid), 0) == 0 else { return .absent }
        guard let application = NSRunningApplication(processIdentifier: pid_t(pid)) else {
            return .unknown
        }
        return application.bundleIdentifier == expectedBundleIdentifier ? .matching : .absent
    }
}

enum InputOwnershipClaimDecision: Equatable {
    case wait
    case startAfterAcknowledgement
    case startWithoutMain
    case failSafe
}

enum MainInputSourceState: Equatable {
    case xkeyIM
    case other
    case unknown
}

enum MainInputOwnershipDecision: Equatable {
    case acknowledge
    case startMain
    case deferMain
    case retry
}

struct InputOwnershipHandoffCoordinator {
    static let mainBundleIdentifier = "org.xuanhieu.1xkey"

    let store: InputOwnershipHandoffStore
    let processChecker: InputOwnershipProcessChecking

    func beginRequest(requesterPID: Int) -> InputOwnershipHandoffRequest {
        store.beginInputOwnershipHandoff(requesterPID: requesterPID)
    }

    @discardableResult
    func cancelRequest(_ request: InputOwnershipHandoffRequest) -> Bool {
        store.cancelInputOwnershipHandoff(request)
    }

    func mainHostDecision(source: MainInputSourceState) -> MainInputOwnershipDecision {
        let snapshot = store.snapshot
        let hasPendingRequest = snapshot.requestGeneration > snapshot.acknowledgedGeneration
            && snapshot.requesterPID > 0
            && processChecker.state(
                of: snapshot.requesterPID,
                expectedBundleIdentifier: SharedSettings.xkeyIMBundleIdentifier
            ) != .absent
        if hasPendingRequest {
            return source == .xkeyIM ? .acknowledge : .retry
        }
        let hasLiveXKeyIMOwner = snapshot.xkeyIMTapArmed
            && snapshot.xkeyIMTapPID > 0
            && processChecker.state(
                of: snapshot.xkeyIMTapPID,
                expectedBundleIdentifier: SharedSettings.xkeyIMBundleIdentifier
            ) != .absent
        if hasLiveXKeyIMOwner { return .deferMain }
        switch source {
        case .xkeyIM: return .deferMain
        case .other: return .startMain
        case .unknown: return .retry
        }
    }

    func claimDecision(for request: InputOwnershipHandoffRequest,
                       timedOut: Bool) -> InputOwnershipClaimDecision {
        guard !timedOut, request.generation > 0 else { return .failSafe }
        let snapshot = store.snapshot
        guard snapshot.requestGeneration == request.generation,
              snapshot.requesterPID == request.requesterPID else { return .failSafe }
        if snapshot.acknowledgedGeneration == request.generation {
            return .startAfterAcknowledgement
        }
        switch processChecker.state(of: snapshot.mainPID,
                                    expectedBundleIdentifier: Self.mainBundleIdentifier) {
        case .absent:
            return .startWithoutMain
        case .matching, .unknown:
            return .wait
        }
    }

    @discardableResult
    func performClaim(for request: InputOwnershipHandoffRequest,
                      timedOut: Bool,
                      start: () -> Void) -> InputOwnershipClaimDecision {
        let decision = claimDecision(for: request, timedOut: timedOut)
        if decision == .startAfterAcknowledgement || decision == .startWithoutMain {
            start()
        }
        return decision
    }

    @discardableResult
    func acknowledgePendingRequest(releaseAndDrain: () -> Void) -> Bool {
        let snapshot = store.snapshot
        guard snapshot.requestGeneration > snapshot.acknowledgedGeneration,
              snapshot.requesterPID > 0 else { return false }
        let request = InputOwnershipHandoffRequest(generation: snapshot.requestGeneration,
                                                    requesterPID: snapshot.requesterPID)
        guard processChecker.state(of: request.requesterPID,
                                   expectedBundleIdentifier: SharedSettings.xkeyIMBundleIdentifier) != .absent
        else { return false }
        releaseAndDrain()
        return store.acknowledgeInputOwnershipHandoff(request)
    }
}

struct MainInputOwnershipLifecycle {
    let store: InputOwnershipHandoffStore

    func managerBecameReady(pid: Int) {
        store.registerXKeyMainProcess(pid: pid)
    }

    func terminate(pid: Int,
                   suspendAndDrain: () -> Void,
                   stop: () -> Void) {
        suspendAndDrain()
        stop()
        store.unregisterXKeyMainProcess(pid: pid)
    }
}

enum MainSettingsChangeAction: Equatable {
    case none
    case applyVietnamese(Bool)
    case deferToXKeyIM
    case restoreAfterXKeyIM
}

struct MainSettingsChangeTracker {
    private var vietnameseEnabled: Bool
    private var xkeyIMOwnsInput: Bool

    init(vietnameseEnabled: Bool, xkeyIMOwnsInput: Bool) {
        self.vietnameseEnabled = vietnameseEnabled
        self.xkeyIMOwnsInput = xkeyIMOwnsInput
    }

    var currentAction: MainSettingsChangeAction {
        xkeyIMOwnsInput ? .deferToXKeyIM : .none
    }

    mutating func update(vietnameseEnabled: Bool,
                         xkeyIMOwnsInput: Bool) -> MainSettingsChangeAction {
        let ownershipChanged = self.xkeyIMOwnsInput != xkeyIMOwnsInput
        let vietnameseChanged = self.vietnameseEnabled != vietnameseEnabled
        self.vietnameseEnabled = vietnameseEnabled
        self.xkeyIMOwnsInput = xkeyIMOwnsInput

        if ownershipChanged {
            return xkeyIMOwnsInput ? .deferToXKeyIM : .restoreAfterXKeyIM
        }
        guard !xkeyIMOwnsInput, vietnameseChanged else { return .none }
        return .applyVietnamese(vietnameseEnabled)
    }
}

final class RemoteDesktopTargetLifecycle {
    private var appliedMode: Bool?

    func apply(_ mode: Bool, onTopologyChange: (Bool) -> Void) {
        guard let previousMode = appliedMode else {
            appliedMode = mode
            return
        }
        guard previousMode != mode else { return }
        appliedMode = mode
        onTopologyChange(mode)
    }
}

// Note: Logging functions (logError, logWarning, etc.) are provided by Shared/DebugLogger.swift

/// Manager for shared settings between XKey and XKeyIM
/// ARCHITECTURE: Uses plist file directly for reliable cross-process sync
class SharedSettings {
    
    // MARK: - Singleton
    
    static let shared = SharedSettings()
    
    // MARK: - Properties

    /// Flag to prevent notification spam during batch updates
    private var isBatchUpdating: Bool = false
    
    /// Default values for settings
    private let defaultValues: [String: Any] = [
        SharedSettingsKey.inputMethod.rawValue: InputMethod.telex.rawValue,
        SharedSettingsKey.codeTable.rawValue: CodeTable.unicode.rawValue,
        SharedSettingsKey.modernStyle.rawValue: false,
        SharedSettingsKey.spellCheckEnabled.rawValue: false,
        SharedSettingsKey.quickTelexEnabled.rawValue: false,
        SharedSettingsKey.restoreIfWrongSpelling.rawValue: true,
        SharedSettingsKey.capitalizeOnlyAfterSpace.rawValue: true,
        SharedSettingsKey.smartSwitchEnabled.rawValue: true,
        SharedSettingsKey.imkitUseMarkedText.rawValue: false,
        SharedSettingsKey.exclusionRulesEnabled.rawValue: true,
        SharedSettingsKey.windowTitleRulesEnabled.rawValue: true
    ]
    
    /// Cache of plist URL (computed once)
    private lazy var plistURL: URL? = {
        return kXKeySharedDirectory.appendingPathComponent("\(kXKeySharedDomain).plist")
    }()
    
    // MARK: - In-Memory Cache

    /// Guards cachedPlistDict / cachedUserDictionaryWords (NSLock is NOT reentrant —
    /// never call another locking method while holding it).
    private let cacheLock = NSLock()

    /// Cached plist dictionary so per-keystroke setting reads (spell check, engine
    /// flags, ...) don't hit disk. BOTH processes write: the main app writes every
    /// setting, and XKeyIM writes `xkeyIMTapArmed`, `xkeyIMTapPID` and
    /// `vietnameseEnabled`. Reads are served from this cache, refreshed via the
    /// distributed settings-changed notification; writes go through mutatePlist,
    /// which merges onto the current on-disk dictionary so a stale cache can never
    /// revert what the other process wrote.
    private var cachedPlistDict: [String: Any]?

    /// Cached decoded user dictionary so per-word spell checks don't re-decode JSON.
    private var cachedUserDictionaryWords: Set<String>?

    /// Bumped on every write/invalidation (under cacheLock). Lets
    /// getUserDictionaryWords detect that the data changed while it was
    /// decoding outside the lock, so it never caches a stale Set.
    private var cacheGeneration = 0

    /// Identifies this process in distributed settings notifications so our own
    /// observer can skip invalidating the cache that mutatePlist just updated.
    private static let processTag = "xkey-\(ProcessInfo.processInfo.processIdentifier)"

    // MARK: - Initialization

    private init() {
        // Refresh cache when settings change in another process
        // (XKeyIM receives main-app writes; the main app receiving its own
        // notification just causes one extra disk read per settings change).
        // Block-based observer: SharedSettings is not an NSObject, so the
        // selector-based API is unavailable. The singleton never deallocates,
        // so the observation token is intentionally not removed.
        DistributedNotificationCenter.default().addObserver(
            forName: .xkeySettingsDidChange,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            // Skip our own writes — mutatePlist already updated the cache
            if (notification.object as? String) == Self.processTag { return }
            self?.invalidateCache()
        }
    }

    /// Drop all cached values; the next read reloads from disk
    func invalidateCache() {
        cacheLock.lock()
        cachedPlistDict = nil
        cachedUserDictionaryWords = nil
        cacheGeneration += 1
        cacheLock.unlock()
    }
    
    /// Public read-only access to the plist file path (for debug/diagnostics)
    var settingsFilePath: String {
        plistURL?.path ?? "(unavailable)"
    }

    // MARK: - Plist Read/Write Helpers
    
    /// Read the entire plist dictionary (served from the in-memory cache when warm)
    private func readPlistDict() -> [String: Any] {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cached = cachedPlistDict {
            return cached
        }

        guard let url = plistURL,
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            // Don't cache failures (missing file on fresh install, transient
            // read error) — keep retrying from disk until a successful read/write.
            return [:]
        }

        cachedPlistDict = dict
        return dict
    }

    /// Read-modify-write a set of keys under one lock hold, merging onto the CURRENT
    /// on-disk dictionary rather than this process's cache.
    ///
    /// Both XKey.app and XKeyIM write this plist. A merge onto a stale cache silently
    /// reverts whatever the other process wrote since that cache was filled — including
    /// the tap-ownership flag, which would put both processes in the keystroke path.
    ///
    private func mutatePlist(_ body: (inout [String: Any]) -> Void) {
        guard let url = plistURL else { return }

        do {
            cacheLock.lock()
            defer { cacheLock.unlock() }

            let lockURL = url.appendingPathExtension("lock")
            let lockFD = Darwin.open(lockURL.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
            guard lockFD >= 0 else {
                throw CocoaError(.fileWriteUnknown)
            }
            defer { Darwin.close(lockFD) }
            guard flock(lockFD, LOCK_EX) == 0 else {
                throw CocoaError(.fileWriteUnknown)
            }
            defer { flock(lockFD, LOCK_UN) }

            var dict: [String: Any]
            if let data = try? Data(contentsOf: url),
               let onDisk = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                dict = onDisk
            } else {
                // Missing file on a fresh install, or a transient read error: fall back
                // to the cache so a write can't drop values this process already holds.
                dict = cachedPlistDict ?? [:]
            }

            body(&dict)

            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
            // .atomic: the other process reads this file directly, and this re-reads it on
            // every write. A non-atomic write truncates in place, so a reader can catch a
            // half-written file — and a torn read here is what the fallback to
            // `cachedPlistDict ?? [:]` above turns into a lost update or a wiped file.
            try data.write(to: url, options: .atomic)
            cachedPlistDict = dict
            cachedUserDictionaryWords = nil
            cacheGeneration += 1
        } catch {
            // Outside the lock hold: the defer above runs on the way out of the do block.
            sharedLogError("Failed to write plist: \(error)")
        }
    }

    /// Read a Bool value from plist
    private func readBool(forKey key: String) -> Bool {
        let dict = readPlistDict()
        
        if let value = dict[key] as? Bool {
            return value
        }
        if let value = dict[key] as? Int {
            return value != 0
        }
        
        // Return default value if key not found
        return defaultValues[key] as? Bool ?? false
    }
    
    /// Write a Bool value to plist
    private func writeBool(_ value: Bool, forKey key: String) {
        mutatePlist { $0[key] = value }
    }
    
    /// Read an Int value from plist
    private func readInt(forKey key: String) -> Int {
        let dict = readPlistDict()
        
        if let value = dict[key] as? Int {
            return value
        }
        
        // Return default value if key not found
        return defaultValues[key] as? Int ?? 0
    }
    
    /// Write an Int value to plist
    private func writeInt(_ value: Int, forKey key: String) {
        mutatePlist { $0[key] = value }
    }

    /// True when the key was written at least once. A cleared hotkey is stored as
    /// 0/0, which reads back the same as a missing key, so only key presence can
    /// tell "user cleared it" from "never configured".
    private func hasStoredValue(forKey key: String) -> Bool {
        readPlistDict()[key] != nil
    }
    
    /// Read a String value from plist
    private func readString(forKey key: String) -> String? {
        let dict = readPlistDict()
        return dict[key] as? String
    }
    
    /// Write a String value to plist
    private func writeString(_ value: String, forKey key: String) {
        mutatePlist { $0[key] = value }
    }
    
    /// Read a Data value from plist
    private func readData(forKey key: String) -> Data? {
        let dict = readPlistDict()
        return dict[key] as? Data
    }
    
    /// Write a Data value to plist
    private func writeData(_ value: Data, forKey key: String) {
        mutatePlist { $0[key] = value }
    }
    
    // MARK: - Hotkey Settings

    var toggleHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.toggleHotkeyCode.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleHotkeyCode.rawValue) }
    }

    var toggleHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.toggleHotkeyModifiers.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleHotkeyModifiers.rawValue) }
    }

    var toggleHotkeyIsModifierOnly: Bool {
        get { readBool(forKey: SharedSettingsKey.toggleHotkeyIsModifierOnly.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.toggleHotkeyIsModifierOnly.rawValue) }
    }

    var undoTypingEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set { writeBool(newValue, forKey: SharedSettingsKey.undoTypingEnabled.rawValue) }
    }

    var undoTypingHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.undoTypingHotkeyCode.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.undoTypingHotkeyCode.rawValue) }
    }

    var undoTypingHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.undoTypingHotkeyModifiers.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.undoTypingHotkeyModifiers.rawValue) }
    }

    var undoTypingHotkeyIsModifierOnly: Bool {
        get { readBool(forKey: SharedSettingsKey.undoTypingHotkeyIsModifierOnly.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.undoTypingHotkeyIsModifierOnly.rawValue) }
    }

    var beepOnToggle: Bool {
        get { readBool(forKey: SharedSettingsKey.beepOnToggle.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.beepOnToggle.rawValue) }
    }

    // MARK: - Input Method Settings

    var inputMethod: Int {
        get { readInt(forKey: SharedSettingsKey.inputMethod.rawValue) }
        set {
            writeInt(newValue, forKey: SharedSettingsKey.inputMethod.rawValue)
            notifySettingsChanged()
        }
    }

    var codeTable: Int {
        get { readInt(forKey: SharedSettingsKey.codeTable.rawValue) }
        set {
            writeInt(newValue, forKey: SharedSettingsKey.codeTable.rawValue)
            notifySettingsChanged()
        }
    }

    var modernStyle: Bool {
        get { readBool(forKey: SharedSettingsKey.modernStyle.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.modernStyle.rawValue)
            notifySettingsChanged()
        }
    }

    var spellCheckEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.spellCheckEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    // MARK: - Advanced Settings

    var quickTelexEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.quickTelexEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var quickStartConsonantEnabled: Bool {
        get { readBool(forKey: SharedSettingsKey.quickStartConsonantEnabled.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.quickStartConsonantEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var quickEndConsonantEnabled: Bool {
        get { readBool(forKey: SharedSettingsKey.quickEndConsonantEnabled.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.quickEndConsonantEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var upperCaseFirstChar: Bool {
        get { readBool(forKey: SharedSettingsKey.upperCaseFirstChar.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.upperCaseFirstChar.rawValue) }
    }

    var capitalizeOnlyAfterSpace: Bool {
        get { readBool(forKey: SharedSettingsKey.capitalizeOnlyAfterSpace.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.capitalizeOnlyAfterSpace.rawValue) }
    }

    var restoreIfWrongSpelling: Bool {
        get { readBool(forKey: SharedSettingsKey.restoreIfWrongSpelling.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.restoreIfWrongSpelling.rawValue)
            notifySettingsChanged()
        }
    }

    var instantRestoreOnWrongSpelling: Bool {
        get { readBool(forKey: SharedSettingsKey.instantRestoreOnWrongSpelling.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.instantRestoreOnWrongSpelling.rawValue)
            notifySettingsChanged()
        }
    }

    var skipRestoreForUppercaseVietnameseAbbreviations: Bool {
        get { readBool(forKey: SharedSettingsKey.skipRestoreForUppercaseVietnameseAbbreviations.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.skipRestoreForUppercaseVietnameseAbbreviations.rawValue)
            notifySettingsChanged()
        }
    }


    var customConsonantEnabled: Bool {
        get { readBool(forKey: SharedSettingsKey.customConsonantEnabled.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.customConsonantEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var customConsonants: String {
        get { readString(forKey: SharedSettingsKey.customConsonants.rawValue) ?? Preferences.defaultCustomConsonants }
        set {
            writeString(newValue, forKey: SharedSettingsKey.customConsonants.rawValue)
            notifySettingsChanged()
        }
    }
    
    var tempOffToolbarEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.tempOffToolbarEnabled.rawValue)
            notifyToolbarChanged()
        }
    }

    var tempOffToolbarHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.tempOffToolbarHotkeyCode.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.tempOffToolbarHotkeyCode.rawValue)
            notifyToolbarChanged()
        }
    }

    var tempOffToolbarHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.tempOffToolbarHotkeyModifiers.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.tempOffToolbarHotkeyModifiers.rawValue)
            notifyToolbarChanged()
        }
    }

    var convertToolHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.convertToolHotkeyCode.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.convertToolHotkeyCode.rawValue)
            notifyConvertToolHotkeyChanged()
        }
    }

    var convertToolHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.convertToolHotkeyModifiers.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.convertToolHotkeyModifiers.rawValue)
            notifyConvertToolHotkeyChanged()
        }
    }

    /// Notify that convert tool hotkey has changed
    private func notifyConvertToolHotkeyChanged() {
        guard !isBatchUpdating else { return }
        NotificationCenter.default.post(
            name: .convertToolHotkeyDidChange,
            object: nil
        )
    }

    var addToDictionaryHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.addToDictionaryHotkeyCode.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.addToDictionaryHotkeyCode.rawValue)
            notifyAddToDictionaryHotkeyChanged()
        }
    }

    var addToDictionaryHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.addToDictionaryHotkeyModifiers.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.addToDictionaryHotkeyModifiers.rawValue)
            notifyAddToDictionaryHotkeyChanged()
        }
    }

    /// Notify that the add-to-dictionary hotkey has changed
    private func notifyAddToDictionaryHotkeyChanged() {
        guard !isBatchUpdating else { return }
        NotificationCenter.default.post(
            name: .addToDictionaryHotkeyDidChange,
            object: nil
        )
    }

    /// Notify that toolbar settings have changed
    private func notifyToolbarChanged() {
        guard !isBatchUpdating else { return }
        NotificationCenter.default.post(
            name: .tempOffToolbarSettingsDidChange,
            object: nil
        )
    }

    // MARK: - Macro Settings

    var macroEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.macroEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var macroInEnglishMode: Bool {
        get { readBool(forKey: SharedSettingsKey.macroInEnglishMode.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.macroInEnglishMode.rawValue) }
    }

    var autoCapsMacro: Bool {
        get { readBool(forKey: SharedSettingsKey.autoCapsMacro.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.autoCapsMacro.rawValue) }
    }

    var addSpaceAfterMacro: Bool {
        get { readBool(forKey: SharedSettingsKey.addSpaceAfterMacro.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.addSpaceAfterMacro.rawValue) }
    }

    var yieldMacroToSystemReplacement: Bool {
        get { readBool(forKey: SharedSettingsKey.yieldMacroToSystemReplacement.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.yieldMacroToSystemReplacement.rawValue) }
    }

    func getMacros() -> Data? {
        return readData(forKey: SharedSettingsKey.macros.rawValue)
    }

    func setMacros(_ data: Data) {
        writeData(data, forKey: SharedSettingsKey.macros.rawValue)
        notifySettingsChanged()
    }

    // MARK: - Smart Switch Settings

    var smartSwitchEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set { writeBool(newValue, forKey: SharedSettingsKey.smartSwitchEnabled.rawValue) }
    }
    
    // MARK: - Smart Switch Data
    
    func getSmartSwitchData() -> Data? {
        return readData(forKey: SharedSettingsKey.smartSwitchData.rawValue)
    }
    
    /// Merge one app into the latest on-disk Smart Switch map. Both processes write
    /// this value, so replacing it from either process's cached manager loses entries.
    func updateSmartSwitchLanguage(bundleIdentifier: String, language: Int) -> Data? {
        var updatedData: Data?
        mutatePlist { dict in
            let key = SharedSettingsKey.smartSwitchData.rawValue
            var map = (dict[key] as? Data)
                .flatMap { try? JSONDecoder().decode([String: Int].self, from: $0) }
                ?? [:]
            map[bundleIdentifier] = language
            guard let data = try? JSONEncoder().encode(map) else { return }
            dict[key] = data
            updatedData = data
        }
        guard updatedData != nil else { return nil }
        notifySettingsChanged()
        return updatedData
    }

    // MARK: - Debug Settings

    var debugModeEnabled: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.debugModeEnabled.rawValue)
            notifyDebugSettingsChanged()
        }
    }

    var debugHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.debugHotkeyCode.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.debugHotkeyCode.rawValue)
            notifyDebugSettingsChanged()
        }
    }

    var debugHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.debugHotkeyModifiers.rawValue)) }
        set {
            writeInt(Int(newValue), forKey: SharedSettingsKey.debugHotkeyModifiers.rawValue)
            notifyDebugSettingsChanged()
        }
    }

    /// Open debug window automatically when app launches
    var openDebugOnLaunch: Bool {
        get { false /* 1xKey minimal profile */ }
        set { writeBool(newValue, forKey: SharedSettingsKey.openDebugOnLaunch.rawValue) }
    }

    /// Notify that debug settings have changed
    private func notifyDebugSettingsChanged() {
        guard !isBatchUpdating else { return }
        NotificationCenter.default.post(
            name: .debugSettingsDidChange,
            object: nil
        )
    }

    // MARK: - IMKit Settings

    var imkitUseMarkedText: Bool {
        get { readBool(forKey: SharedSettingsKey.imkitUseMarkedText.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.imkitUseMarkedText.rawValue)
            notifySettingsChanged()
        }
    }

    var switchToXKeyHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.switchToXKeyHotkeyCode.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.switchToXKeyHotkeyCode.rawValue) }
    }

    var switchToXKeyHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.switchToXKeyHotkeyModifiers.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.switchToXKeyHotkeyModifiers.rawValue) }
    }

    var switchToXKeyHotkeyIsModifierOnly: Bool {
        get { readBool(forKey: SharedSettingsKey.switchToXKeyHotkeyIsModifierOnly.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.switchToXKeyHotkeyIsModifierOnly.rawValue) }
    }

    // MARK: - UI Settings

    var showDockIcon: Bool {
        get { readBool(forKey: SharedSettingsKey.showDockIcon.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.showDockIcon.rawValue) }
    }

    var startAtLogin: Bool {
        get { readBool(forKey: SharedSettingsKey.startAtLogin.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.startAtLogin.rawValue) }
    }

    var menuBarIconStyle: String {
        get { readString(forKey: SharedSettingsKey.menuBarIconStyle.rawValue) ?? "X" }
        set { writeString(newValue, forKey: SharedSettingsKey.menuBarIconStyle.rawValue) }
    }

    var statusBarClickToToggle: Bool {
        get { readBool(forKey: SharedSettingsKey.statusBarClickToToggle.rawValue) }
        set { writeBool(newValue, forKey: SharedSettingsKey.statusBarClickToToggle.rawValue) }
    }

    var appLanguage: String {
        // Default to Vietnamese on first launch — matches Preferences.appLanguage default
        // so loadPreferences() from an empty plist yields the same value as a fresh
        // Preferences() struct.
        get { readString(forKey: SharedSettingsKey.appLanguage.rawValue) ?? AppLanguage.vi.rawValue }
        set { writeString(newValue, forKey: SharedSettingsKey.appLanguage.rawValue) }
    }

    var autoCheckForUpdates: Bool {
        get {
            let dict = readPlistDict()
            // Default to false (1xKey: updates are opt-in)
            if let value = dict[SharedSettingsKey.autoCheckForUpdates.rawValue] as? Bool {
                return value
            }
            return false
        }
        set { writeBool(newValue, forKey: SharedSettingsKey.autoCheckForUpdates.rawValue) }
    }

    // MARK: - Excluded Apps

    func getExcludedApps() -> Data? {
        return readData(forKey: SharedSettingsKey.excludedApps.rawValue)
    }

    func setExcludedApps(_ data: Data) {
        writeData(data, forKey: SharedSettingsKey.excludedApps.rawValue)
    }

    var exclusionRulesEnabled: Bool {
        get { readBool(forKey: SharedSettingsKey.exclusionRulesEnabled.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.exclusionRulesEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var remoteDesktopInjectMode: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.remoteDesktopInjectMode.rawValue)
            notifySettingsChanged()
        }
    }

    // MARK: - Vietnamese On/Off (shared by both processes)

    /// Global Vietnamese on/off. Lives here because BOTH the tap path
    /// (KeyboardEventHandler) and the marked-text path (XKeyIMController) must read
    /// one truth — XKeyIM used to keep a private in-memory flag that neither
    /// persisted nor synced, which is exactly the desync class this replaces.
    /// Defaults to true so a fresh install types Vietnamese.
    var vietnameseEnabled: Bool {
        get {
            // readPlistDict() returns a non-optional [String: Any] in this file, so
            // the only optional here is the key lookup itself: key absent -> true.
            guard let value = readPlistDict()[SharedSettingsKey.vietnameseEnabled.rawValue] as? Bool
            else { return true }
            return value
        }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.vietnameseEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    // MARK: - XKeyIM Tap Ownership

    /// True while XKeyIM's event tap is armed. Armed and disarmed only by XKeyIM; the
    /// one write from XKey.app is clearing an orphan whose arming process is gone.
    var xkeyIMTapArmed: Bool {
        get { readBool(forKey: SharedSettingsKey.xkeyIMTapArmed.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.xkeyIMTapArmed.rawValue)
            notifySettingsChanged()
        }
    }

    /// PID of the XKeyIM process that armed the tap, so a crashed XKeyIM cannot
    /// keep XKey.app locked out forever.
    var xkeyIMTapPID: Int {
        get { readInt(forKey: SharedSettingsKey.xkeyIMTapPID.rawValue) }
        set {
            writeInt(newValue, forKey: SharedSettingsKey.xkeyIMTapPID.rawValue)
            notifySettingsChanged()
        }
    }

    /// Called by XKeyIM when its tap goes live. Flag and PID move together in one
    /// mutation: two separate writes leave a window where the other process can read
    /// "armed" against the previous owner's PID.
    func armXKeyIMTap(pid: Int) {
        mutatePlist {
            $0[SharedSettingsKey.xkeyIMTapPID.rawValue] = pid
            $0[SharedSettingsKey.xkeyIMTapArmed.rawValue] = true
        }
        notifySettingsChanged()
    }

    /// Called by XKeyIM on deactivate and on terminate.
    func disarmXKeyIMTap() {
        mutatePlist {
            $0[SharedSettingsKey.xkeyIMTapArmed.rawValue] = false
            $0[SharedSettingsKey.xkeyIMTapPID.rawValue] = 0
        }
        notifySettingsChanged()
    }

    func registerXKeyMainProcess(pid: Int) {
        mutatePlist { $0[SharedSettingsKey.xkeyMainPID.rawValue] = pid }
        notifySettingsChanged()
    }

    func unregisterXKeyMainProcess(pid: Int) {
        mutatePlist { dict in
            guard (dict[SharedSettingsKey.xkeyMainPID.rawValue] as? Int) == pid else { return }
            dict[SharedSettingsKey.xkeyMainPID.rawValue] = 0
        }
        notifySettingsChanged()
    }

    /// The question XKey.app asks: should I keep my hands off the keyboard?
    /// True only when SOME OTHER process armed the tap and that process really is
    /// XKeyIM, still running — the arming process itself is never the audience for
    /// this question, so it must never read `true` for its own PID (otherwise
    /// XKeyIM's own tap delegate would yield to itself and stop processing every
    /// keystroke).
    ///
    /// Liveness alone is not enough. Flag and PID live in a persistent plist, so a
    /// kernel panic or hard power-off leaves them set (applicationWillTerminate never
    /// runs), and XKeyIM's login-launched PID sits in the low range reassigned early
    /// on the next boot. `kill(pid, 0)` would then succeed against whatever unrelated
    /// process inherited the PID and lock XKey.app out of the keyboard permanently,
    /// with no UI indication — so verify identity, not just existence. `kill(pid, 0)`
    /// stays as the cheap pre-check ahead of the bundle lookup.
    ///
    /// XKey.app does not suspend its tap while XKeyIM is armed — it yields per event —
    /// so this is read on EVERY keystroke, and both the `kill(2)` and the
    /// LaunchServices lookup are too expensive to pay there. The answer is memoised on
    /// `cacheGeneration`, which every write goes through (`armXKeyIMTap`,
    /// `disarmXKeyIMTap`) and which the distributed settings notification bumps through
    /// `invalidateCache()`, so a real ownership change from either process is still
    /// seen on the very next event.
    var isXKeyIMTapOwningInput: Bool {
        let generation = currentCacheGeneration
        let now = ProcessInfo.processInfo.systemUptime

        ownershipMemoLock.lock()
        if let memo = ownershipMemo,
           memo.generation == generation,
           now - memo.capturedAt < Self.ownershipMemoMaxAge {
            ownershipMemoLock.unlock()
            return memo.value
        }
        ownershipMemoLock.unlock()

        // Computed outside the memo lock: the compute path can write the plist (the
        // self-heal below), and no lock in this type may be held across that.
        let value = computeIsXKeyIMTapOwningInput()

        ownershipMemoLock.lock()
        ownershipMemo = (value, generation, now)
        ownershipMemoLock.unlock()
        return value
    }

    private func computeIsXKeyIMTapOwningInput() -> Bool {
        guard xkeyIMTapArmed else { return false }
        let pid = xkeyIMTapPID
        guard pid > 0 else { return false }
        guard pid != Int(getpid()) else { return false }
        guard kill(pid_t(pid), 0) == 0 else {
            clearOrphanedTapOwnership(pid: pid)
            return false
        }
        let runningApp = NSRunningApplication(processIdentifier: pid_t(pid))
        // NOT treated as an orphan: NSRunningApplication can return nil for a live,
        // correct XKeyIM, and clearing the flag here would put both processes back in
        // the keystroke path. Log it instead — failing this check silently is how
        // "1xKey transforms every keystroke twice" comes back as an unreproducible report.
        guard runningApp?.bundleIdentifier == Self.xkeyIMBundleIdentifier else {
            logTapOwnershipIdentityMismatch(pid: pid, identity: runningApp?.bundleIdentifier)
            return false
        }
        return true
    }

    /// Rate-limited: this only runs on a memo miss, which already bounds it to a few per
    /// second, and a few log lines per second forever on the keystroke path is its own
    /// freeze.
    private func logTapOwnershipIdentityMismatch(pid: Int, identity: String?) {
        guard shouldLogTapOwnershipWarning() else { return }
        sharedLogWarning("1xKeyIM tap ownership armed for live PID \(pid), but its identity is \(identity ?? "unavailable") rather than \(Self.xkeyIMBundleIdentifier) — not yielding the keyboard")
    }

    /// One throttle for both tap-ownership warnings: both fire from the memo-miss path,
    /// which repeats for as long as the condition lasts. Sharing the timestamp can
    /// suppress one warning behind the other — acceptable for two diagnostics about the
    /// same flag, and cheaper than a second timer to keep in step.
    private func shouldLogTapOwnershipWarning() -> Bool {
        let now = ProcessInfo.processInfo.systemUptime
        ownershipMemoLock.lock()
        defer { ownershipMemoLock.unlock() }
        guard now - lastTapOwnershipWarningLogAt >= Self.tapOwnershipWarningLogInterval else {
            return false
        }
        lastTapOwnershipWarningLogAt = now
        return true
    }

    /// Clear an ownership flag whose arming process is definitively gone. `kill(2)`
    /// failing is the kernel-panic / hard-power-off case: applicationWillTerminate never
    /// ran, and leaving the flag on disk means the next boot can reassign that low PID to
    /// an unrelated process, at which point liveness starts passing again.
    ///
    /// No notification: the process that would care is the one that died, mutatePlist has
    /// already updated this process's cache, and a synchronous distributed post on the
    /// keystroke path is its own freeze risk. Bumping the cache generation is what
    /// retires the memo.
    private func clearOrphanedTapOwnership(pid: Int) {
        // One attempt per cache generation. A successful write bumps the generation and
        // the flag then reads false, so this only bites when the write FAILED (full disk,
        // read-only container): nothing changed, the memo expires 250 ms later, and the
        // heal would otherwise repeat a synchronous plist read and write four times a
        // second forever, on the main thread inside a CGEventTap callback. Any real
        // ownership change bumps the generation and re-arms the heal.
        let generation = currentCacheGeneration
        ownershipMemoLock.lock()
        let alreadyAttempted = lastOrphanHealAttemptGeneration == generation
        lastOrphanHealAttemptGeneration = generation
        ownershipMemoLock.unlock()
        guard !alreadyAttempted else { return }

        if shouldLogTapOwnershipWarning() {
            sharedLogWarning("1xKeyIM tap ownership armed for dead PID \(pid) — clearing the orphaned flag")
        }
        mutatePlist { dict in
            // Clear only the PID this compute decided was dead. mutatePlist has just
            // re-read the current dictionary from disk, and XKeyIM may have re-armed with
            // a fresh PID since the read that started this compute — overwriting that is
            // the lost update mutatePlist exists to prevent, and it puts both processes
            // in the keystroke path with no notification to correct it.
            guard (dict[SharedSettingsKey.xkeyIMTapPID.rawValue] as? Int) == pid else { return }
            dict[SharedSettingsKey.xkeyIMTapArmed.rawValue] = false
            dict[SharedSettingsKey.xkeyIMTapPID.rawValue] = 0
        }
    }

    /// XKeyIM's CFBundleIdentifier (XKeyIM/Info.plist) — the identity the ownership
    /// flag must belong to. Internal so a test can pin it against that plist: a typo
    /// here leaves the suite green while XKey.app never yields the keyboard again.
    static let xkeyIMBundleIdentifier = "org.xuanhieu.inputmethod.1xkey"

    /// Guards `ownershipMemo`, `lastTapOwnershipWarningLogAt` and
    /// `lastOrphanHealAttemptGeneration`. Separate from
    /// `cacheLock`, and never held while the memo is being computed, so the compute
    /// path stays free to write the plist.
    private let ownershipMemoLock = NSLock()
    private var ownershipMemo: (value: Bool, generation: Int, capturedAt: TimeInterval)?
    private var lastTapOwnershipWarningLogAt: TimeInterval = -.infinity
    private var lastOrphanHealAttemptGeneration: Int?

    /// Backstop for the ownership change no write can announce: XKeyIM dying without
    /// disarming leaves the flag armed on disk, so nothing bumps the cache generation
    /// and the memo would otherwise answer `true` until some unrelated setting changed.
    ///
    /// ponytail: polling ceiling — that one case is seen up to 250 ms late, during which
    /// XKey.app keeps yielding to a process that is gone. Observe the owner directly
    /// (NSWorkspace.didTerminateApplicationNotification) if that window ever matters.
    ///
    /// Internal so the memo test can measure against the real window instead of pinning a
    /// copy of the literal that drifts the day this one changes.
    static let ownershipMemoMaxAge: TimeInterval = 0.25

    /// At most one tap-ownership warning per this interval.
    private static let tapOwnershipWarningLogInterval: TimeInterval = 60

    private var currentCacheGeneration: Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cacheGeneration
    }

    var isRemoteDesktopTarget: Bool {
        get { false /* 1xKey minimal profile */ }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.isRemoteDesktopTarget.rawValue)
            notifySettingsChanged()
        }
    }

    var toggleExclusionHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.toggleExclusionHotkeyCode.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleExclusionHotkeyCode.rawValue) }
    }

    var toggleExclusionHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.toggleExclusionHotkeyModifiers.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleExclusionHotkeyModifiers.rawValue) }
    }

    // MARK: - Window Title Rules Toggle

    var windowTitleRulesEnabled: Bool {
        get { readBool(forKey: SharedSettingsKey.windowTitleRulesEnabled.rawValue) }
        set {
            writeBool(newValue, forKey: SharedSettingsKey.windowTitleRulesEnabled.rawValue)
            notifySettingsChanged()
        }
    }

    var toggleWindowRulesHotkeyCode: UInt16 {
        get { UInt16(readInt(forKey: SharedSettingsKey.toggleWindowRulesHotkeyCode.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleWindowRulesHotkeyCode.rawValue) }
    }

    var toggleWindowRulesHotkeyModifiers: UInt {
        get { UInt(readInt(forKey: SharedSettingsKey.toggleWindowRulesHotkeyModifiers.rawValue)) }
        set { writeInt(Int(newValue), forKey: SharedSettingsKey.toggleWindowRulesHotkeyModifiers.rawValue) }
    }

    // MARK: - Input Source Management

    func getInputSourceConfig() -> Data? {
        return readData(forKey: SharedSettingsKey.inputSourceConfig.rawValue)
    }

    func setInputSourceConfig(_ data: Data) {
        writeData(data, forKey: SharedSettingsKey.inputSourceConfig.rawValue)
    }
    
    // MARK: - Macros Data
    
    func getMacrosData() -> Data? {
        return readData(forKey: SharedSettingsKey.macrosData.rawValue)
    }
    
    func setMacrosData(_ data: Data) {
        writeData(data, forKey: SharedSettingsKey.macrosData.rawValue)
        // writeData alone is silent; notify observers that the macro list changed.
        notifySettingsChanged()
    }
    
    // MARK: - Window Title Rules
    
    func getWindowTitleRulesData() -> Data? {
        return readData(forKey: SharedSettingsKey.windowTitleRules.rawValue)
    }
    
    func setWindowTitleRulesData(_ data: Data) {
        writeData(data, forKey: SharedSettingsKey.windowTitleRules.rawValue)
        // writeData alone is silent; notify observers that the rules changed.
        notifySettingsChanged()
    }
    
    // MARK: - Disabled Built-in Rules
    
    /// Get the list of disabled built-in rule names
    func getDisabledBuiltInRules() -> Set<String> {
        guard let data = readData(forKey: SharedSettingsKey.disabledBuiltInRules.rawValue),
              let names = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(names)
    }
    
    /// Set the list of disabled built-in rule names
    func setDisabledBuiltInRules(_ names: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(names)) {
            writeData(data, forKey: SharedSettingsKey.disabledBuiltInRules.rawValue)
        }
    }
    
    /// Get the list of enabled built-in rule names (for rules that are disabled by default)
    func getEnabledBuiltInRules() -> Set<String> {
        guard let data = readData(forKey: SharedSettingsKey.enabledBuiltInRules.rawValue),
              let names = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(names)
    }
    
    /// Set the list of enabled built-in rule names (for rules that are disabled by default)
    func setEnabledBuiltInRules(_ names: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(names)) {
            writeData(data, forKey: SharedSettingsKey.enabledBuiltInRules.rawValue)
        }
    }
    
    // MARK: - User Dictionary (Custom Words)
    
    /// Get the list of user-defined words (to skip spell check)
    func getUserDictionaryWords() -> Set<String> {
        cacheLock.lock()
        let cached = cachedUserDictionaryWords
        let generation = cacheGeneration
        cacheLock.unlock()
        if let cached = cached {
            return cached
        }

        // Decode outside the lock — readData() takes cacheLock internally.
        let words: Set<String>
        if let data = readData(forKey: SharedSettingsKey.userDictionaryWords.rawValue),
           let list = try? JSONDecoder().decode([String].self, from: data) {
            words = Set(list)
        } else {
            words = []
        }

        cacheLock.lock()
        // Only cache if no write/invalidation happened while we were decoding —
        // otherwise this Set may be stale and would be served indefinitely.
        if cacheGeneration == generation {
            cachedUserDictionaryWords = words
        }
        cacheLock.unlock()
        return words
    }
    
    /// Set the list of user-defined words
    func setUserDictionaryWords(_ words: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(words).sorted()) {
            writeData(data, forKey: SharedSettingsKey.userDictionaryWords.rawValue)
            notifySettingsChanged()
        }
    }
    
    /// Add a word to the user dictionary
    func addUserDictionaryWord(_ word: String) {
        let normalized = word.lowercased().trimmingCharacters(in: .whitespaces)
        var words = getUserDictionaryWords()
        words.insert(normalized)
        setUserDictionaryWords(words)
    }

    /// Remove a word from the user dictionary
    func removeUserDictionaryWord(_ word: String) {
        let normalized = word.lowercased().trimmingCharacters(in: .whitespaces)
        var words = getUserDictionaryWords()
        words.remove(normalized)
        setUserDictionaryWords(words)
    }
    
    /// Check if a word exists in the user dictionary
    func isWordInUserDictionary(_ word: String) -> Bool {
        let words = getUserDictionaryWords()
        return words.contains(word.lowercased().trimmingCharacters(in: .whitespaces))
    }

    // MARK: - Sync

    /// Synchronize settings to disk
    /// Note: With plist-only approach, settings are written immediately
    /// This function is kept for compatibility but does nothing
    func synchronize() {
        // No-op: plist writes are immediate
    }
    
    /// Force write all current settings to plist file
    /// This is used before Sparkle restarts the app after an update
    /// to ensure settings are saved to the current App Group container
    /// In case of App Group path change between versions, this ensures
    /// settings are written to the correct location
    func forceWriteCurrentSettings() {
        // Empty body on purpose: the job is to guarantee the file exists in the current
        // App Group container, not to change any value, and mutatePlist round-trips the
        // CURRENT on-disk dictionary to do it. Rebuilding the dictionary from the cache
        // and writing the whole thing back would push this process's possibly-stale copy
        // of xkeyIMTapArmed over whatever XKeyIM wrote since — right before a restart,
        // and with no notification — leaving both processes in the keystroke path.
        var count = 0
        mutatePlist { count = $0.count }

        if count == 0 {
            sharedLogWarning("forceWriteCurrentSettings: No settings to save")
        } else {
            sharedLogSuccess("Force saved \(count) settings to plist")
        }
    }

    /// Notify that settings have changed (for observers)
    private func notifySettingsChanged() {
        // Skip notification if we're in batch update mode
        guard !isBatchUpdating else { return }

        // Post notification for local observers
        NotificationCenter.default.post(
            name: .sharedSettingsDidChange,
            object: nil
        )

        // Post distributed notification for cross-app communication.
        // object carries the sender's process tag so our own observer can skip
        // the redundant cache invalidation. XKeyIM observes with object: nil but
        // TapController compares the delivered object against a process tag it builds
        // in the same format, to drop its own posts — so the format is load-bearing in
        // both processes. If the two ever drift apart that filter fails open and XKeyIM
        // pays one redundant tap-environment rebuild per self-posted change.
        // deliverImmediately: XKeyIM is a background IMK process — without it
        // the notification can be coalesced/held and its settings cache would
        // stay stale until the next delivery.
        DistributedNotificationCenter.default().postNotificationName(
            .xkeySettingsDidChange,
            object: Self.processTag,
            userInfo: nil,
            deliverImmediately: true
        )
    }
    
    // MARK: - Device-local Keys

    /// Live tap-ownership/handoff state: device-local, never exported or restored.
    private static let localOwnershipKeys: Set<String> = [
        SharedSettingsKey.xkeyIMTapArmed.rawValue,
        SharedSettingsKey.xkeyIMTapPID.rawValue,
        SharedSettingsKey.xkeyMainPID.rawValue,
        SharedSettingsKey.inputHandoffRequestGeneration.rawValue,
        SharedSettingsKey.inputHandoffRequesterPID.rawValue,
        SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue,
    ]

    static func removeTransientOwnershipState(from dict: inout [String: Any]) {
        for key in localOwnershipKeys { dict.removeValue(forKey: key) }
    }

    // MARK: - Export/Import Settings

    /// Export all settings to a plist file
    /// - Returns: The exported plist data (XML format for human readability), or nil if export failed
    func exportSettings() -> Data? {
        var exportDict = readPlistDict()
        Self.removeTransientOwnershipState(from: &exportDict)
        
        // Add metadata for version tracking
        exportDict["_exportVersion"] = 1
        exportDict["_exportDate"] = ISO8601DateFormatter().string(from: Date())
        exportDict["_appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        
        // Convert to XML plist for human readability
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: exportDict, format: .xml, options: 0)
            return data
        } catch {
            sharedLogError("Failed to export settings: \(error)")
            return nil
        }
    }
    
    /// Import settings from a plist file
    /// - Parameter data: The plist data to import
    /// - Returns: True if import was successful
    @discardableResult
    func importSettings(from data: Data) -> Bool {
        do {
            guard var importDict = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                sharedLogError("Invalid plist format")
                return false
            }
            
            // Remove metadata keys before writing
            importDict.removeValue(forKey: "_exportVersion")
            importDict.removeValue(forKey: "_exportDate")
            importDict.removeValue(forKey: "_appVersion")
            
            // Write all settings, but keep the live tap-ownership state: it is device-local
            // state rather than a setting, so a backup exported while XKeyIM was not armed
            // would otherwise remove the flag on restore, leaving both processes in the
            // keystroke path with nothing to heal it — the heal only runs for a flag that
            // reads armed. The current values come out of the on-disk dictionary
            // mutatePlist hands us, not out of this process's cache.
            //
            // Only the local ownership/handoff keys, deliberately: vietnameseEnabled and
            // isRemoteDesktopTarget are the user's own saved state, and a restore should
            // bring them back.
            mutatePlist { dict in
                let preserved = Self.localOwnershipKeys.map { ($0, dict[$0]) }
                dict = importDict
                for (key, value) in preserved { dict[key] = value }
            }
            sharedLogSuccess("Imported settings successfully")

            // Sync app language to UserDefaults.standard so AppLanguage.applyLanguage()
            // picks up the imported value on next launch (it reads from standard defaults,
            // not from the shared plist, for early-launch access).
            if let langRaw = importDict[SharedSettingsKey.appLanguage.rawValue] as? String,
               AppLanguage(rawValue: langRaw) != nil {
                UserDefaults.standard.set(langRaw, forKey: "appLanguage")
            }

            // Notify observers
            notifySettingsChanged()
            // Post macros notification if available (XKey only, not XKeyIM)
            if let macrosNotification = Notification.Name(rawValue: "XKey.macrosDidChange") as Notification.Name? {
                NotificationCenter.default.post(name: macrosNotification, object: nil)
            }
            
            return true
        } catch {
            sharedLogError("Failed to import settings: \(error)")
            return false
        }
    }
    
    /// Get the suggested filename for export
    func getExportFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return "1xKey-Settings-\(dateString).plist"
    }
    
    // MARK: - Reset to Factory Default
    
    /// Reset all settings to factory defaults by deleting the plist file.
    /// All getters will automatically fall back to `defaultValues`.
    /// This is the only method needed since ALL config is now centralized in the plist.
    @discardableResult
    func resetToDefaults() -> Bool {
        // Delete the plist file — all getters auto-fallback to defaultValues
        if let url = plistURL {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                sharedLogError("Failed to delete plist file: \(error)")
                return false
            }
        }

        // Cache must not outlive the deleted plist
        invalidateCache()

        // Notify all observers that settings have been reset
        notifySettingsChanged()
        notifyToolbarChanged()
        notifyConvertToolHotkeyChanged()
        notifyDebugSettingsChanged()
        
        sharedLogSuccess("Settings reset to factory defaults")
        return true
    }
    
    // MARK: - Load/Save Preferences Object

    /// Load all settings as a Preferences object
    /// 1xKey is deliberately minimal: it only types Vietnamese correctly. Every side
    /// feature (macros, spell check, quick typing, smart switch, floating toolbar, debug,
    /// remote desktop, extra hotkeys) is forced off here, the single place every host
    /// reads preferences from, so no stale plist value can switch one back on.
    /// Window title rules stay on: they are what keeps diacritics intact in Chrome,
    /// Electron chats and terminals.
    static func applyMinimalProfile(to prefs: inout Preferences) {
        let none = Hotkey(keyCode: 0, modifiers: [])
        // No global hotkeys at all: ⌘⇧V and friends belong to other apps. Switching
        // Vietnamese on/off happens only from the menu bar popover.
        prefs.toggleHotkey = none
        prefs.statusBarClickToToggle = false
        prefs.showDockIcon = false
        prefs.excludedApps = []
        prefs.tempOffToolbarEnabled = false
        prefs.tempOffToolbarHotkey = none
        prefs.convertToolHotkey = none
        prefs.addToDictionaryHotkey = none
        prefs.debugHotkey = none
        prefs.toggleExclusionHotkey = none
        prefs.toggleWindowRulesHotkey = none
        prefs.switchToXKeyHotkey = nil
        prefs.undoTypingEnabled = false
        prefs.undoTypingHotkey = nil
        prefs.macroEnabled = false
        prefs.macroInEnglishMode = false
        prefs.spellCheckEnabled = false
        prefs.quickTelexEnabled = false
        prefs.quickStartConsonantEnabled = false
        prefs.quickEndConsonantEnabled = false
        prefs.upperCaseFirstChar = false
        prefs.customConsonantEnabled = false
        prefs.smartSwitchEnabled = false
        prefs.debugModeEnabled = false
        prefs.openDebugOnLaunch = false
        prefs.beepOnToggle = false
        prefs.remoteDesktopInjectMode = false
        prefs.isRemoteDesktopTarget = false
        prefs.autoCheckForUpdates = false
        prefs.imkitUseMarkedText = false
        prefs.windowTitleRulesEnabled = true
        prefs.codeTable = .unicode
        if prefs.inputMethod != .telex && prefs.inputMethod != .vni { prefs.inputMethod = .telex }
    }

    func loadPreferences() -> Preferences {
        var prefs = Preferences()

        // Hotkey settings
        let hotkeyCode = toggleHotkeyCode
        let hotkeyModifiers = toggleHotkeyModifiers
        if hasStoredValue(forKey: SharedSettingsKey.toggleHotkeyCode.rawValue) {
            prefs.toggleHotkey = Hotkey(
                keyCode: hotkeyCode,
                modifiers: ModifierFlags(rawValue: hotkeyModifiers),
                isModifierOnly: toggleHotkeyIsModifierOnly
            )
        }
        prefs.undoTypingEnabled = undoTypingEnabled
        
        // Undo typing hotkey
        let undoHotkeyCode = undoTypingHotkeyCode
        let undoHotkeyModifiers = undoTypingHotkeyModifiers
        if undoHotkeyCode != 0 || undoHotkeyModifiers != 0 {
            prefs.undoTypingHotkey = Hotkey(
                keyCode: undoHotkeyCode,
                modifiers: ModifierFlags(rawValue: undoHotkeyModifiers),
                isModifierOnly: undoTypingHotkeyIsModifierOnly
            )
        }
        prefs.beepOnToggle = beepOnToggle

        // Input settings
        if let method = InputMethod(rawValue: inputMethod) {
            prefs.inputMethod = method
        }
        if let table = CodeTable(rawValue: codeTable) {
            prefs.codeTable = table
        }
        prefs.modernStyle = modernStyle
        prefs.spellCheckEnabled = spellCheckEnabled

        // Advanced settings
        prefs.quickTelexEnabled = quickTelexEnabled
        prefs.quickStartConsonantEnabled = quickStartConsonantEnabled
        prefs.quickEndConsonantEnabled = quickEndConsonantEnabled
        prefs.upperCaseFirstChar = upperCaseFirstChar
        prefs.capitalizeOnlyAfterSpace = capitalizeOnlyAfterSpace
        prefs.restoreIfWrongSpelling = restoreIfWrongSpelling
        prefs.instantRestoreOnWrongSpelling = instantRestoreOnWrongSpelling
        prefs.skipRestoreForUppercaseVietnameseAbbreviations = skipRestoreForUppercaseVietnameseAbbreviations

        // Custom consonants (2-prop: enabled + list)
        prefs.customConsonantEnabled = customConsonantEnabled
        prefs.customConsonants = customConsonants
        prefs.tempOffToolbarEnabled = tempOffToolbarEnabled

        // Temp off toolbar hotkey
        let toolbarHotkeyCode = tempOffToolbarHotkeyCode
        let toolbarHotkeyModifiers = tempOffToolbarHotkeyModifiers
        if hasStoredValue(forKey: SharedSettingsKey.tempOffToolbarHotkeyCode.rawValue) {
            prefs.tempOffToolbarHotkey = Hotkey(
                keyCode: toolbarHotkeyCode,
                modifiers: ModifierFlags(rawValue: toolbarHotkeyModifiers)
            )
        }

        // Convert tool hotkey
        let convertHotkeyCode = convertToolHotkeyCode
        let convertHotkeyModifiers = convertToolHotkeyModifiers
        if convertHotkeyCode != 0 || convertHotkeyModifiers != 0 {
            prefs.convertToolHotkey = Hotkey(
                keyCode: convertHotkeyCode,
                modifiers: ModifierFlags(rawValue: convertHotkeyModifiers)
            )
        }

        // Add-to-dictionary hotkey
        let dictHotkeyCode = addToDictionaryHotkeyCode
        let dictHotkeyModifiers = addToDictionaryHotkeyModifiers
        if dictHotkeyCode != 0 || dictHotkeyModifiers != 0 {
            prefs.addToDictionaryHotkey = Hotkey(
                keyCode: dictHotkeyCode,
                modifiers: ModifierFlags(rawValue: dictHotkeyModifiers)
            )
        }

        // Macro settings
        prefs.macroEnabled = macroEnabled
        prefs.macroInEnglishMode = macroInEnglishMode
        prefs.autoCapsMacro = autoCapsMacro
        prefs.addSpaceAfterMacro = addSpaceAfterMacro
        prefs.yieldMacroToSystemReplacement = yieldMacroToSystemReplacement

        prefs.smartSwitchEnabled = smartSwitchEnabled

        // Debug
        prefs.debugModeEnabled = debugModeEnabled

        // IMKit
        prefs.imkitUseMarkedText = imkitUseMarkedText

        // Switch to XKey hotkey (optional)
        let switchHotkeyCode = switchToXKeyHotkeyCode
        let switchHotkeyModifiers = switchToXKeyHotkeyModifiers
        if switchHotkeyCode != 0 || switchHotkeyModifiers != 0 {
            prefs.switchToXKeyHotkey = Hotkey(
                keyCode: switchHotkeyCode,
                modifiers: ModifierFlags(rawValue: switchHotkeyModifiers),
                isModifierOnly: switchToXKeyHotkeyIsModifierOnly
            )
        }

        // UI settings
        prefs.showDockIcon = showDockIcon
        prefs.startAtLogin = startAtLogin
        if let style = MenuBarIconStyle(rawValue: menuBarIconStyle) {
            prefs.menuBarIconStyle = style
        }
        prefs.statusBarClickToToggle = statusBarClickToToggle
        if let lang = AppLanguage(rawValue: appLanguage) {
            prefs.appLanguage = lang
        }
        prefs.autoCheckForUpdates = autoCheckForUpdates

        // Excluded apps
        if let data = getExcludedApps(),
           let apps = try? JSONDecoder().decode([ExcludedApp].self, from: data) {
            prefs.excludedApps = apps
        }
        prefs.exclusionRulesEnabled = exclusionRulesEnabled
        prefs.remoteDesktopInjectMode = remoteDesktopInjectMode
        prefs.isRemoteDesktopTarget = isRemoteDesktopTarget
        let exclHotkeyCode = toggleExclusionHotkeyCode
        let exclHotkeyModifiers = toggleExclusionHotkeyModifiers
        if exclHotkeyCode != 0 || exclHotkeyModifiers != 0 {
            prefs.toggleExclusionHotkey = Hotkey(
                keyCode: exclHotkeyCode,
                modifiers: ModifierFlags(rawValue: exclHotkeyModifiers)
            )
        }

        // Window Title Rules toggle
        prefs.windowTitleRulesEnabled = windowTitleRulesEnabled
        let wtrHotkeyCode = toggleWindowRulesHotkeyCode
        let wtrHotkeyModifiers = toggleWindowRulesHotkeyModifiers
        if wtrHotkeyCode != 0 || wtrHotkeyModifiers != 0 {
            prefs.toggleWindowRulesHotkey = Hotkey(
                keyCode: wtrHotkeyCode,
                modifiers: ModifierFlags(rawValue: wtrHotkeyModifiers)
            )
        }

        // Debug settings
        prefs.debugModeEnabled = debugModeEnabled
        prefs.openDebugOnLaunch = openDebugOnLaunch
        let dbgHotkeyCode = debugHotkeyCode
        let dbgHotkeyModifiers = debugHotkeyModifiers
        if hasStoredValue(forKey: SharedSettingsKey.debugHotkeyCode.rawValue) {
            prefs.debugHotkey = Hotkey(
                keyCode: dbgHotkeyCode,
                modifiers: ModifierFlags(rawValue: dbgHotkeyModifiers)
            )
        }

        Self.applyMinimalProfile(to: &prefs)
        return prefs
    }

    /// Save a Preferences object to shared settings
    func savePreferences(_ prefs: Preferences) {
        // Enable batch mode to prevent notification spam
        isBatchUpdating = true
        defer {
            // Always disable batch mode when done, even if error occurs
            isBatchUpdating = false
        }

        // Hotkey settings
        toggleHotkeyCode = prefs.toggleHotkey.keyCode
        toggleHotkeyModifiers = prefs.toggleHotkey.modifiers.rawValue
        toggleHotkeyIsModifierOnly = prefs.toggleHotkey.isModifierOnly
        undoTypingEnabled = prefs.undoTypingEnabled
        
        // Undo typing hotkey (optional)
        if let undoHotkey = prefs.undoTypingHotkey {
            undoTypingHotkeyCode = undoHotkey.keyCode
            undoTypingHotkeyModifiers = undoHotkey.modifiers.rawValue
            undoTypingHotkeyIsModifierOnly = undoHotkey.isModifierOnly
        } else {
            // Clear the hotkey settings when nil (use default Esc)
            undoTypingHotkeyCode = 0
            undoTypingHotkeyModifiers = 0
            undoTypingHotkeyIsModifierOnly = false
        }
        beepOnToggle = prefs.beepOnToggle

        // Input settings
        inputMethod = prefs.inputMethod.rawValue
        codeTable = prefs.codeTable.rawValue
        modernStyle = prefs.modernStyle
        spellCheckEnabled = prefs.spellCheckEnabled

        // Advanced settings
        quickTelexEnabled = prefs.quickTelexEnabled
        quickStartConsonantEnabled = prefs.quickStartConsonantEnabled
        quickEndConsonantEnabled = prefs.quickEndConsonantEnabled
        upperCaseFirstChar = prefs.upperCaseFirstChar
        capitalizeOnlyAfterSpace = prefs.capitalizeOnlyAfterSpace
        restoreIfWrongSpelling = prefs.restoreIfWrongSpelling
        instantRestoreOnWrongSpelling = prefs.instantRestoreOnWrongSpelling
        skipRestoreForUppercaseVietnameseAbbreviations = prefs.skipRestoreForUppercaseVietnameseAbbreviations

        customConsonantEnabled = prefs.customConsonantEnabled
        customConsonants = prefs.customConsonants
        tempOffToolbarEnabled = prefs.tempOffToolbarEnabled
        tempOffToolbarHotkeyCode = prefs.tempOffToolbarHotkey.keyCode
        tempOffToolbarHotkeyModifiers = prefs.tempOffToolbarHotkey.modifiers.rawValue
        convertToolHotkeyCode = prefs.convertToolHotkey.keyCode
        convertToolHotkeyModifiers = prefs.convertToolHotkey.modifiers.rawValue
        addToDictionaryHotkeyCode = prefs.addToDictionaryHotkey.keyCode
        addToDictionaryHotkeyModifiers = prefs.addToDictionaryHotkey.modifiers.rawValue

        // Macro settings
        macroEnabled = prefs.macroEnabled
        macroInEnglishMode = prefs.macroInEnglishMode
        autoCapsMacro = prefs.autoCapsMacro
        addSpaceAfterMacro = prefs.addSpaceAfterMacro
        yieldMacroToSystemReplacement = prefs.yieldMacroToSystemReplacement

        smartSwitchEnabled = prefs.smartSwitchEnabled

        // Debug
        debugModeEnabled = prefs.debugModeEnabled
        openDebugOnLaunch = prefs.openDebugOnLaunch

        // IMKit
        imkitUseMarkedText = prefs.imkitUseMarkedText

        // Switch to XKey hotkey (optional)
        if let switchHotkey = prefs.switchToXKeyHotkey {
            switchToXKeyHotkeyCode = switchHotkey.keyCode
            switchToXKeyHotkeyModifiers = switchHotkey.modifiers.rawValue
            switchToXKeyHotkeyIsModifierOnly = switchHotkey.isModifierOnly
        } else {
            // Clear the hotkey if nil
            switchToXKeyHotkeyCode = 0
            switchToXKeyHotkeyModifiers = 0
            switchToXKeyHotkeyIsModifierOnly = false
        }

        // UI settings
        showDockIcon = prefs.showDockIcon
        startAtLogin = prefs.startAtLogin
        menuBarIconStyle = prefs.menuBarIconStyle.rawValue
        statusBarClickToToggle = prefs.statusBarClickToToggle
        appLanguage = prefs.appLanguage.rawValue
        autoCheckForUpdates = prefs.autoCheckForUpdates

        // Excluded apps
        if let data = try? JSONEncoder().encode(prefs.excludedApps) {
            setExcludedApps(data)
        }
        exclusionRulesEnabled = prefs.exclusionRulesEnabled
        toggleExclusionHotkeyCode = prefs.toggleExclusionHotkey.keyCode
        toggleExclusionHotkeyModifiers = prefs.toggleExclusionHotkey.modifiers.rawValue
        remoteDesktopInjectMode = prefs.remoteDesktopInjectMode
        isRemoteDesktopTarget = prefs.isRemoteDesktopTarget

        // Window Title Rules toggle
        windowTitleRulesEnabled = prefs.windowTitleRulesEnabled
        toggleWindowRulesHotkeyCode = prefs.toggleWindowRulesHotkey.keyCode
        toggleWindowRulesHotkeyModifiers = prefs.toggleWindowRulesHotkey.modifiers.rawValue

        // Debug settings — written BEFORE the notifications below so observers
        // (XKeyIM) never re-read the plist while these are still unwritten
        debugModeEnabled = prefs.debugModeEnabled
        debugHotkeyCode = prefs.debugHotkey.keyCode
        debugHotkeyModifiers = prefs.debugHotkey.modifiers.rawValue

        // Batch update is done - settings are already written to plist via setters
        isBatchUpdating = false

        // Send ONE notification to notify observers
        notifySettingsChanged()

        // Also notify toolbar settings changed (so toolbar can be enabled/disabled immediately)
        notifyToolbarChanged()

        // Also notify convert tool hotkey changed
        notifyConvertToolHotkeyChanged()

        // Also notify add-to-dictionary hotkey changed
        notifyAddToDictionaryHotkeyChanged()

        // Also notify debug settings changed
        notifyDebugSettingsChanged()
    }
}

extension SharedSettings: InputOwnershipHandoffStore {
    var snapshot: InputOwnershipHandoffSnapshot {
        invalidateCache()
        let dict = readPlistDict()
        return InputOwnershipHandoffSnapshot(
            requestGeneration: dict[SharedSettingsKey.inputHandoffRequestGeneration.rawValue] as? Int ?? 0,
            requesterPID: dict[SharedSettingsKey.inputHandoffRequesterPID.rawValue] as? Int ?? 0,
            acknowledgedGeneration: dict[SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue] as? Int ?? 0,
            mainPID: dict[SharedSettingsKey.xkeyMainPID.rawValue] as? Int ?? 0,
            xkeyIMTapArmed: dict[SharedSettingsKey.xkeyIMTapArmed.rawValue] as? Bool ?? false,
            xkeyIMTapPID: dict[SharedSettingsKey.xkeyIMTapPID.rawValue] as? Int ?? 0
        )
    }

    func beginInputOwnershipHandoff(requesterPID: Int) -> InputOwnershipHandoffRequest {
        var request = InputOwnershipHandoffRequest(generation: 0, requesterPID: requesterPID)
        mutatePlist { dict in
            let requested = dict[SharedSettingsKey.inputHandoffRequestGeneration.rawValue] as? Int ?? 0
            let acknowledged = dict[SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue] as? Int ?? 0
            request = InputOwnershipHandoffRequest(generation: max(requested, acknowledged) + 1,
                                                    requesterPID: requesterPID)
            dict[SharedSettingsKey.inputHandoffRequestGeneration.rawValue] = request.generation
            dict[SharedSettingsKey.inputHandoffRequesterPID.rawValue] = requesterPID
        }
        notifySettingsChanged()
        return request
    }

    func acknowledgeInputOwnershipHandoff(_ request: InputOwnershipHandoffRequest) -> Bool {
        var acknowledged = false
        mutatePlist { dict in
            guard (dict[SharedSettingsKey.inputHandoffRequestGeneration.rawValue] as? Int) == request.generation,
                  (dict[SharedSettingsKey.inputHandoffRequesterPID.rawValue] as? Int) == request.requesterPID,
                  request.requesterPID > 0,
                  (dict[SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue] as? Int ?? 0) < request.generation
            else { return }
            if (dict[SharedSettingsKey.xkeyIMTapPID.rawValue] as? Int) != request.requesterPID {
                dict[SharedSettingsKey.xkeyIMTapArmed.rawValue] = false
                dict[SharedSettingsKey.xkeyIMTapPID.rawValue] = 0
            }
            dict[SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue] = request.generation
            acknowledged = true
        }
        if acknowledged { notifySettingsChanged() }
        return acknowledged
    }

    func cancelInputOwnershipHandoff(_ request: InputOwnershipHandoffRequest) -> Bool {
        var cancelled = false
        mutatePlist { dict in
            guard (dict[SharedSettingsKey.inputHandoffRequestGeneration.rawValue] as? Int) == request.generation,
                  (dict[SharedSettingsKey.inputHandoffRequesterPID.rawValue] as? Int) == request.requesterPID,
                  request.requesterPID > 0,
                  (dict[SharedSettingsKey.inputHandoffAcknowledgedGeneration.rawValue] as? Int ?? 0) < request.generation
            else { return }
            dict[SharedSettingsKey.inputHandoffRequesterPID.rawValue] = 0
            cancelled = true
        }
        if cancelled { notifySettingsChanged() }
        return cancelled
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when shared settings change (local)
    static let sharedSettingsDidChange = Notification.Name("XKey.sharedSettingsDidChange")
    
    /// Posted when settings change (distributed, cross-app)
    static let xkeySettingsDidChange = Notification.Name("XKey.settingsDidChange")
    
    /// Posted when temp off toolbar settings change (enabled/disabled or hotkey)
    static let tempOffToolbarSettingsDidChange = Notification.Name("XKey.tempOffToolbarSettingsDidChange")

    /// Posted when convert tool hotkey changes
    static let convertToolHotkeyDidChange = Notification.Name("XKey.convertToolHotkeyDidChange")

    /// Posted when the add-to-dictionary hotkey changes
    static let addToDictionaryHotkeyDidChange = Notification.Name("XKey.addToDictionaryHotkeyDidChange")

    /// Posted when debug settings change
    static let debugSettingsDidChange = Notification.Name("XKey.debugSettingsDidChange")

    /// Posted when a macro is added, edited, deleted, or reordered so the typing engine
    /// and any open macro management UI reload from the plist.
    static let macrosDidChange = Notification.Name("XKey.macrosDidChange")

    /// Posted when hotkey recording starts/stops. UserInfo contains "isRecording": Bool
    static let hotkeyRecordingStateChanged = Notification.Name("XKey.hotkeyRecordingStateChanged")
}
