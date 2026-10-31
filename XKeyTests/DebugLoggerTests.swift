//
//  DebugLoggerTests.swift
//  XKeyTests
//
//  Guards the @autoclosure logging contract: when logging is disabled, the message
//  expression must NOT be evaluated (zero cost on the hot path). Regressing the
//  parameter back to a plain String would silently reintroduce per-keystroke string
//  building — this test fails loudly if that happens.
//

import XCTest
@testable import XKey

final class DebugLoggerTests: XCTestCase {

    /// Reference box so the message autoclosure records evaluation without inout capture.
    private final class Flag { var evaluated = false }

    private var previousEnabled = false

    override func setUp() {
        super.setUp()
        previousEnabled = DebugLogger.shared.isLoggingEnabled
    }

    override func tearDown() {
        DebugLogger.shared.isLoggingEnabled = previousEnabled
        super.tearDown()
    }

    /// Returns a string while recording that the (auto)closure was actually invoked.
    private func trackedMessage(_ flag: Flag) -> String {
        flag.evaluated = true
        return "tracked"
    }

    // MARK: - Disabled: message autoclosure must not be evaluated

    func testLogDoesNotEvaluateMessageWhenDisabled() {
        DebugLogger.shared.isLoggingEnabled = false
        let flag = Flag()
        DebugLogger.shared.log(trackedMessage(flag))
        XCTAssertFalse(flag.evaluated, "message must not be built when logging is disabled")
    }

    func testInfoDoesNotEvaluateMessageWhenDisabled() {
        DebugLogger.shared.isLoggingEnabled = false
        let flag = Flag()
        DebugLogger.shared.info(trackedMessage(flag))
        XCTAssertFalse(flag.evaluated, "info() must not build its message when logging is disabled")
    }

    func testWarningDoesNotEvaluateMessageWhenDisabled() {
        // guard isLoggingEnabled short-circuits before the level switch, so even
        // always-written levels build nothing while logging is off.
        DebugLogger.shared.isLoggingEnabled = false
        let flag = Flag()
        DebugLogger.shared.warning(trackedMessage(flag))
        XCTAssertFalse(flag.evaluated, "guard isLoggingEnabled short-circuits all levels while disabled")
    }

    // MARK: - Enabled: message autoclosure is evaluated

    func testLogEvaluatesMessageWhenEnabled() {
        DebugLogger.shared.isLoggingEnabled = true
        let flag = Flag()
        DebugLogger.shared.log(trackedMessage(flag))
        XCTAssertTrue(flag.evaluated, "message must be built and logged when logging is enabled")
    }

    func testInfoEvaluatesMessageWhenEnabled() {
        DebugLogger.shared.isLoggingEnabled = true
        let flag = Flag()
        DebugLogger.shared.info(trackedMessage(flag))
        XCTAssertTrue(flag.evaluated, "info() must build its message when logging is enabled")
    }
}

final class DebugLogRedactionTests: XCTestCase {
    func testRedactsCharacterCodesKeyCodesAndQuotedText() {
        let line = #"charData[1] = getCharacterCode(typingWord[1]) = 0x2001ED3 keyCode=0 text="việt" U+1EC7 'a'"#
        let out = DebugLogger.redact(line)
        XCTAssertFalse(out.contains("0x2001ED3"))
        XCTAssertFalse(out.contains("keyCode=0"))
        XCTAssertFalse(out.contains("việt"))
        XCTAssertFalse(out.contains("1EC7"))
        XCTAssertFalse(out.contains("'a'"))
        XCTAssertTrue(out.contains("charData[1]"), "structure stays readable")
    }

    func testLeavesCountsAndPlainStatusAlone() {
        let line = "Inject: bs=1, chars=3, method=fast"
        XCTAssertEqual(DebugLogger.redact(line), line)
    }
}
