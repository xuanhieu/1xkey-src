import Foundation

// 1xAg in-app notices (same file in 1xSnap and 1xKey; keep them in sync).
// Feed: static https://1xag.com/notices.json, version 1. Plain GET of a fixed URL: no cookies, no query,
// no identifiers, nothing about the user is sent. Read ids, last check and the last good list stay in UserDefaults.

struct AppNotice: Codable, Equatable, Identifiable {
    let id: String
    let date: String          // yyyy-MM-dd
    let products: [String]
    let important: Bool       // level "important"; anything else is "info"
    let title: [String: String]
    let body: [String: String]
    let url: [String: String]

    /// Text in `lang` ("vi"/"en"), else the other language, else "".
    static func pick(_ value: [String: String], _ lang: String) -> String {
        let other = lang == "vi" ? "en" : "vi"
        if let s = value[lang], !s.isEmpty { return s }
        return value[other] ?? ""
    }
    func title(_ lang: String) -> String { Self.pick(title, lang) }
    func body(_ lang: String) -> String { Self.pick(body, lang) }
    /// Only https links are opened.
    func link(_ lang: String) -> URL? {
        let s = Self.pick(url, lang)
        guard s.lowercased().hasPrefix("https://") else { return nil }
        return URL(string: s)
    }
    /// "03/11/2026" in Vietnamese, ISO date otherwise.
    func displayDate(_ lang: String) -> String {
        let p = date.split(separator: "-")
        guard p.count == 3, lang == "vi" else { return date }
        return "\(p[2])/\(p[1])/\(p[0])"
    }
}

/// Use from the main thread; `refreshIfDue` applies its result on the main actor.
final class NoticeCenter: ObservableObject {
    static let feedURL = URL(string: "https://1xag.com/notices.json")!
    static let interval: TimeInterval = 24 * 60 * 60
    static let maxBytes = 256 * 1024

    let product: String
    private let defaults: UserDefaults
    private let fetch: (URL) async throws -> Data
    private let readKey = "notices.read"
    private let checkedKey = "notices.lastCheck"
    private let cacheKey = "notices.cache"

    /// This product's notices, newest first (cached list until the next good fetch).
    @Published private(set) var notices: [AppNotice] = []
    @Published private(set) var readIDs: Set<String> = []

    var unreadCount: Int { notices.filter { !readIDs.contains($0.id) }.count }
    var unreadIDs: [String] { notices.filter { !readIDs.contains($0.id) }.map(\.id) }

    init(product: String, defaults: UserDefaults = .standard,
         fetch: @escaping (URL) async throws -> Data = NoticeCenter.download) {
        self.product = product
        self.defaults = defaults
        self.fetch = fetch
        if let data = defaults.data(forKey: cacheKey), let list = try? JSONDecoder().decode([AppNotice].self, from: data) {
            notices = list
        }
        readIDs = Set(defaults.stringArray(forKey: readKey) ?? [])
    }

    /// "vi" when the system prefers Vietnamese, "en" otherwise.
    static func language(_ preferred: [String] = Locale.preferredLanguages) -> String {
        (preferred.first ?? "en").lowercased().hasPrefix("vi") ? "vi" : "en"
    }

    // MARK: Parsing

    /// Version-1 feed → notices; malformed entries are dropped; nil when it is not a version-1 feed.
    static func parse(_ data: Data) -> [AppNotice]? {
        guard let doc = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              doc["version"] as? Int == 1, let items = doc["notices"] as? [Any] else { return nil }
        func text(_ v: Any?) -> [String: String] {
            if let s = v as? String { return ["vi": s, "en": s] }
            guard let d = v as? [String: Any] else { return [:] }
            var out: [String: String] = [:]
            for key in ["vi", "en"] { if let s = d[key] as? String { out[key] = s } }
            return out
        }
        return items.compactMap { item in
            guard let n = item as? [String: Any], let id = n["id"] as? String, !id.isEmpty,
                  let date = n["date"] as? String else { return nil }
            let title = text(n["title"])
            guard !(title["vi"] ?? "").isEmpty || !(title["en"] ?? "").isEmpty else { return nil }
            return AppNotice(id: id, date: date, products: (n["products"] as? [Any])?.compactMap { $0 as? String } ?? [],
                             important: n["level"] as? String == "important",
                             title: title, body: text(n["body"]), url: text(n["url"]))
        }
    }

    /// Notices for one product key, newest first.
    static func filter(_ list: [AppNotice], product: String) -> [AppNotice] {
        list.filter { $0.products.contains(product) }.sorted { $0.date > $1.date }
    }

    // MARK: Checking

    /// Due when never checked, 24 h after the last attempt, or when the clock went back.
    func isDue(now: Date = Date()) -> Bool {
        guard let last = defaults.object(forKey: checkedKey) as? Date else { return true }
        let age = now.timeIntervalSince(last)
        return age >= Self.interval || age < 0
    }

    /// Fetches the feed when due (or `force`). The attempt time is stored first, so a failing network
    /// is retried after 24 h, not in a loop. Errors are silent and keep the previous list.
    func refreshIfDue(now: Date = Date(), force: Bool = false) async {
        guard force || isDue(now: now) else { return }
        defaults.set(now, forKey: checkedKey)
        guard let data = try? await fetch(Self.feedURL), let all = Self.parse(data) else { return }
        let mine = Self.filter(all, product: product)
        await MainActor.run {
            notices = mine
            if let encoded = try? JSONEncoder().encode(mine) { defaults.set(encoded, forKey: cacheKey) }
        }
    }

    /// Marks ids read; keeps only ids still in the list so the stored set does not grow forever.
    func markRead(_ ids: [String]) {
        let keep = Set(notices.map(\.id))
        readIDs = readIDs.union(ids).intersection(keep)
        defaults.set(Array(readIDs).sorted(), forKey: readKey)
    }

    /// Ephemeral session: no cookies, no cache, no credentials; fixed URL; small body only.
    static func download(_ url: URL) async throws -> Data {
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        config.httpAdditionalHeaders = ["User-Agent": "1xAg-notices", "Accept": "application/json"]
        let session = URLSession(configuration: config)
        defer { session.finishTasksAndInvalidate() }
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200, data.count <= maxBytes else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
