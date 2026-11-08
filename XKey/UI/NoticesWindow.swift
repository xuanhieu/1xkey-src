import AppKit
import SwiftUI

// "Thông báo" window for the 1xAg notices feed (same file in 1xSnap and 1xKey; keep them in sync).

struct NoticesView: View {
    @ObservedObject var center: NoticeCenter
    /// Ids that were unread when the window opened: they keep a "Mới" mark for this visit.
    let fresh: Set<String>
    let accent: Color
    let lang: String

    private func tr(_ vi: String, _ en: String) -> String { lang == "vi" ? vi : en }

    var body: some View {
        Group {
            if center.notices.isEmpty {
                Text(tr("Chưa có thông báo nào.", "No notices yet."))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(center.notices) { n in row(n) }
                    .accessibilityLabel(tr("Danh sách thông báo", "Notices"))
            }
        }
        .frame(minWidth: 420, minHeight: 320)
    }

    @ViewBuilder private func row(_ n: AppNotice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                if fresh.contains(n.id) {
                    Text(tr("Mới", "New"))
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Capsule().fill(Color(red: 0x2B / 255, green: 0x3B / 255, blue: 1)))
                }
                if n.important {
                    Text(tr("Quan trọng", "Important"))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(accent)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .overlay(Capsule().stroke(accent, lineWidth: 1))
                }
                Text(n.displayDate(lang)).font(.caption).foregroundColor(.secondary)
            }
            Text(n.title(lang)).font(.headline)
            if !n.body(lang).isEmpty {
                Text(n.body(lang)).font(.callout).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            if let url = n.link(lang) {
                Button(tr("Xem chi tiết", "Read more")) { NSWorkspace.shared.open(url) }
                    .buttonStyle(.link)
                    .foregroundColor(accent)
                    .accessibilityLabel("\(tr("Mở liên kết", "Open link")): \(n.title(lang))")
                    .help(url.absoluteString)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel([fresh.contains(n.id) ? tr("Mới", "New") : nil,
                             n.important ? tr("Quan trọng", "Important") : nil,
                             n.title(lang), n.displayDate(lang)].compactMap { $0 }.joined(separator: ", "))
    }
}

/// Opens the list and marks everything in it read (the "Mới" marks stay until the window closes).
final class NoticesWindowController: NSWindowController, NSWindowDelegate {
    private let center: NoticeCenter
    private let accent: Color
    private let appName: String

    init(center: NoticeCenter, accent: Color, appName: String) {
        self.center = center
        self.accent = accent
        self.appName = appName
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 460, height: 420),
                              styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
    }
    required init?(coder: NSCoder) { fatalError() }

    func show() {
        let lang = NoticeCenter.language()
        let fresh = Set(center.unreadIDs)
        window?.title = "\(appName) · \(lang == "vi" ? "Thông báo" : "Notices")"
        window?.contentView = NSHostingView(rootView: NoticesView(center: center, fresh: fresh, accent: accent, lang: lang))
        center.markRead(Array(fresh))
        if window?.isVisible != true { window?.center() }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        // Pick up anything new while the window is open (still at most once per 24 h).
        Task { await center.refreshIfDue() }
    }
}

extension NoticeCenter {
    /// Menu title with the unread count, e.g. "Thông báo (2)".
    func menuTitle(_ lang: String = NoticeCenter.language()) -> String {
        let base = lang == "vi" ? "Thông báo" : "Notices"
        return unreadCount > 0 ? "\(base) (\(unreadCount))" : base
    }
    /// VoiceOver label for the same item.
    func accessibilityTitle(_ lang: String = NoticeCenter.language()) -> String {
        let base = lang == "vi" ? "Thông báo" : "Notices"
        guard unreadCount > 0 else { return base }
        return lang == "vi" ? "\(base), \(unreadCount) chưa đọc" : "\(base), \(unreadCount) unread"
    }
}
