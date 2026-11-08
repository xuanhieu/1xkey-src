//
//  NoticeCenterTests.swift
//  XKeyTests
//
//  1xAg notices feed: parsing, product filter, language fallback, read state, 24 h throttle.
//

import XCTest
@testable import XKey

final class NoticeCenterTests: XCTestCase {
    private let feed = """
    {"version":1,"notices":[
      {"id":"eula-2026-11-03","date":"2026-11-03","products":["convert","snap","key"],"level":"important",
       "title":{"vi":"Điều khoản mới","en":"New terms"},"body":{"vi":"Nội dung","en":"Body"},
       "url":{"vi":"https://1xag.com/key","en":"https://1xag.com/key"}},
      {"id":"snap-only","date":"2026-11-05","products":["snap"],"level":"info","title":{"vi":"Snap","en":"Snap"}},
      {"id":"old","date":"2026-10-01","products":["key"],"level":"weird","title":{"en":"Only EN"},"url":{"en":"http://x.y"}},
      {"id":"","date":"2026-11-01","products":["key"],"title":{"vi":"no id"}},
      {"id":"no-title","date":"2026-11-01","products":["key"],"title":{}}
    ]}
    """.data(using: .utf8)!

    private var defaults: UserDefaults!
    private let suite = "NoticeCenterTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    func testParsesVersionOneFeedAndDropsMalformedEntries() {
        let list = NoticeCenter.parse(feed)
        XCTAssertEqual(list?.map(\.id), ["eula-2026-11-03", "snap-only", "old"])
        XCTAssertEqual(list?.first?.important, true)
        XCTAssertEqual(list?.last?.important, false)
    }

    func testRejectsOtherDocuments() {
        XCTAssertNil(NoticeCenter.parse(Data("not json".utf8)))
        XCTAssertNil(NoticeCenter.parse(Data(#"{"version":2,"notices":[]}"#.utf8)))
        XCTAssertNil(NoticeCenter.parse(Data("<!doctype html>".utf8)))
    }

    func testFiltersByProductNewestFirst() {
        let mine = NoticeCenter.filter(NoticeCenter.parse(feed)!, product: "key")
        XCTAssertEqual(mine.map(\.id), ["eula-2026-11-03", "old"])
    }

    func testLanguageFallbackAndHttpsOnlyLinks() {
        let list = NoticeCenter.parse(feed)!
        XCTAssertEqual(list[0].title("vi"), "Điều khoản mới")
        XCTAssertEqual(list[0].title("en"), "New terms")
        XCTAssertEqual(list[2].title("vi"), "Only EN")
        XCTAssertEqual(list[0].link("en")?.absoluteString, "https://1xag.com/key")
        XCTAssertNil(list[2].link("en"))
        XCTAssertEqual(list[0].displayDate("vi"), "03/11/2026")
        XCTAssertEqual(NoticeCenter.language(["vi-VN", "en"]), "vi")
        XCTAssertEqual(NoticeCenter.language(["en-US"]), "en")
        XCTAssertEqual(NoticeCenter.language([]), "en")
    }

    func testFetchStoresListAndReadStateLocally() async {
        let data = feed
        let center = NoticeCenter(product: "key", defaults: defaults) { _ in data }
        await center.refreshIfDue(now: Date(timeIntervalSince1970: 1_000))
        XCTAssertEqual(center.notices.map(\.id), ["eula-2026-11-03", "old"])
        XCTAssertEqual(center.unreadCount, 2)
        center.markRead(["eula-2026-11-03", "gone"])
        XCTAssertEqual(center.unreadCount, 1)
        XCTAssertEqual(defaults.stringArray(forKey: "notices.read"), ["eula-2026-11-03"])

        // A new instance (next launch) sees the cached list and the read ids without the network.
        let next = NoticeCenter(product: "key", defaults: defaults) { _ in throw URLError(.notConnectedToInternet) }
        XCTAssertEqual(next.notices.count, 2)
        XCTAssertEqual(next.unreadCount, 1)
        XCTAssertEqual(next.menuTitle("vi"), "Thông báo (1)")
        XCTAssertEqual(next.accessibilityTitle("en"), "Notices, 1 unread")
    }

    func testChecksAtMostOncePer24HoursAndStaysSilentOffline() async {
        var calls = 0
        let center = NoticeCenter(product: "key", defaults: defaults) { _ in
            calls += 1
            throw URLError(.notConnectedToInternet)
        }
        let t0 = Date(timeIntervalSince1970: 1_000_000)
        await center.refreshIfDue(now: t0)
        await center.refreshIfDue(now: t0.addingTimeInterval(3600))
        XCTAssertEqual(calls, 1)
        XCTAssertTrue(center.notices.isEmpty)
        XCTAssertTrue(center.isDue(now: t0.addingTimeInterval(NoticeCenter.interval)))
        XCTAssertTrue(center.isDue(now: t0.addingTimeInterval(-60))) // clock moved back
    }
}
