import AppKit
import SwiftUI

// "Giới thiệu & Thông báo": one window, two tabs. The notices tab reuses NoticesView as is
// (NoticesWindow.swift is shared with 1xSnap and stays untouched).

/// Where the intro sends people. Plain https links; each one is a page we own or the source repo.
enum KeyLinks {
    struct Item: Identifiable {
        let id: String
        let icon: String
        let vi: String
        let en: String
        let url: URL
        var host: String { (url.host ?? "") + (url.path == "/" ? "" : url.path) }
    }

    static let product = URL(string: "https://1xag.com/key")!

    static let items: [Item] = [
        Item(id: "product", icon: "arrow.down.circle", vi: "Trang sản phẩm và bản mới nhất", en: "Product page and latest version",
             url: product),
        Item(id: "changelog", icon: "list.bullet.rectangle", vi: "Nhật ký thay đổi", en: "Changelog",
             url: URL(string: "https://1xag.com/key/changelog")!),
        Item(id: "family", icon: "square.grid.2x2", vi: "Các sản phẩm khác của 1xAg", en: "More from 1xAg",
             url: URL(string: "https://1xag.com")!),
        Item(id: "privacy", icon: "lock.shield", vi: "Quyền riêng tư", en: "Privacy",
             url: URL(string: "https://1xag.com/privacy")!),
        Item(id: "author", icon: "person.crop.circle", vi: "Tác giả Phạm Xuân Hiếu", en: "About the author",
             url: URL(string: "https://xuanhieu.org/gioi-thieu")!),
        Item(id: "source", icon: "chevron.left.forwardslash.chevron.right", vi: "Mã nguồn (GPL-3.0)", en: "Source code (GPL-3.0)",
             url: URL(string: "https://github.com/xuanhieu/1xkey-src")!),
        Item(id: "issues", icon: "exclamationmark.bubble", vi: "Góp ý và báo lỗi", en: "Feedback and bug reports",
             url: URL(string: "https://github.com/xuanhieu/1xkey/issues")!),
    ]
}

struct KeyInfoView: View {
    enum Tab: Hashable { case intro, notices }

    @ObservedObject var center: NoticeCenter
    /// Ids that were unread when the window opened; they keep their "Mới" mark for this visit.
    let fresh: Set<String>
    let accent: Color
    let lang: String
    @State private var tab: Tab
    @State private var copied = false

    init(center: NoticeCenter, fresh: Set<String>, accent: Color, lang: String, startTab: Tab) {
        self.center = center
        self.fresh = fresh
        self.accent = accent
        self.lang = lang
        _tab = State(initialValue: startTab)
    }

    private func tr(_ vi: String, _ en: String) -> String { lang == "vi" ? vi : en }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $tab) {
                Text(tr("Giới thiệu", "About")).tag(Tab.intro)
                Text(center.menuTitle(lang)).tag(Tab.notices)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            switch tab {
            case .intro:
                ScrollView { intro.padding(20) }
            case .notices:
                NoticesView(center: center, fresh: fresh, accent: accent, lang: lang)
                    .onAppear { center.markRead(Array(fresh)) }
            }
        }
        .frame(minWidth: 460, minHeight: 440)
    }

    // MARK: - Intro

    private var intro: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("1xKey").font(.title2.weight(.bold))
                    Text(tr("Bộ gõ đơn giản, tối giản, thuận tiện cho người Việt chỉ muốn gõ tiếng Việt chuẩn.",
                            "A simple, minimal Vietnamese input method for people who just want to type Vietnamese correctly."))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(tr("Phiên bản", "Version")) \(AppVersion.current) · /by_xuanhieu.org")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            section(tr("1xKey làm gì", "What it does")) {
                point(tr("Gõ thẳng, không gạch chân", "Types straight in, no underline"),
                      tr("Chữ hiện ra ngay khi gõ, không có vùng soạn thảo gạch chân như bộ gõ có sẵn của macOS.",
                         "Text appears as you type, without the underlined composition area of the built-in input method."))
                point(tr("Không mất dấu", "No lost diacritics"),
                      tr("Có luật riêng cho ô địa chỉ trình duyệt, Google Docs, ô chat Claude, ChatGPT, Gemini, Slack, Discord, Zalo, Teams, Messenger và Terminal.",
                         "Built-in rules for browser address bars, Google Docs, Claude, ChatGPT and Gemini chats, Slack, Discord, Zalo, Teams, Messenger and Terminal."))
                point(tr("Tối giản", "Minimal"),
                      tr("Không có cửa sổ cài đặt và không chiếm phím tắt nào. Menu chỉ có bật/tắt, Telex hoặc VNI, Mở cùng macOS. Bảng mã luôn là Unicode.",
                         "No settings window and no global shortcuts. The menu only has on/off, Telex or VNI, and Open at login. Output is always Unicode."))
                point(tr("Riêng tư", "Private"),
                      tr("Không ghi, không lưu, không gửi chữ bạn gõ. Ô mật khẩu được bỏ qua. Ứng dụng chỉ nạp danh sách thông báo từ 1xag.com, tối đa mỗi ngày một lần, không gửi dữ liệu nào.",
                         "It never records, stores or sends what you type. Password fields are skipped. The only network call fetches the notice list from 1xag.com at most once a day and sends no data."))
            }

            section(tr("Nếu không gõ được", "If typing stops working")) {
                point(tr("Dùng bàn phím ABC", "Use the ABC keyboard"),
                      tr("Chọn Input Source là ABC và tắt bộ gõ tiếng Việt có sẵn của Apple, kẻo dấu bị thêm hai lần.",
                         "Pick ABC as the input source and turn off Apple's Vietnamese input, or diacritics get added twice."))
                point(tr("Secure Input", "Secure Input"),
                      tr("Khi một ứng dụng (ô mật khẩu, hoặc Chrome giữ nhầm) bật Secure Input, macOS giấu phím khỏi mọi bộ gõ. Mở menu 1xKey: thẻ màu cam cho biết ứng dụng nào và có nút xử lý.",
                         "When an app (a password field, or Chrome holding it by mistake) turns on Secure Input, macOS hides keystrokes from every input method. Open the 1xKey menu: the orange card names the app and offers a fix."))
            }

            section(tr("Liên kết", "Links")) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(KeyLinks.items) { item in
                        Link(destination: item.url) {
                            HStack(spacing: 8) {
                                Image(systemName: item.icon).frame(width: 18).foregroundColor(accent)
                                Text(tr(item.vi, item.en))
                                Spacer(minLength: 8)
                                Text(item.host).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .help(item.url.absoluteString)
                    }
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(KeyLinks.product.absoluteString, forType: .string)
                        copied = true
                    } label: {
                        Label(copied ? tr("Đã sao chép link, gửi cho bạn bè nhé", "Link copied, send it to a friend")
                                     : tr("Sao chép link để chia sẻ 1xKey", "Copy the link to share 1xKey"),
                              systemImage: copied ? "checkmark.circle.fill" : "square.and.arrow.up")
                    }
                    .padding(.top, 4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tr("Phát triển bởi Phạm Xuân Hiếu · miễn phí, mã nguồn mở GPL-3.0.",
                        "Built by Phạm Xuân Hiếu · free, open source under GPL-3.0."))
                Text(tr("Dựa trên XKey (xmannv, MIT) và OpenKey (Mai Vũ Tuyên, GPL-3.0).",
                        "Based on XKey (xmannv, MIT) and OpenKey (Mai Vũ Tuyên, GPL-3.0)."))
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }

    private func point(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.callout.weight(.semibold))
            Text(detail)
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

final class KeyInfoWindowController: NSWindowController, NSWindowDelegate {
    private let center: NoticeCenter
    private let accent: Color
    private let appName: String

    init(center: NoticeCenter, accent: Color, appName: String) {
        self.center = center
        self.accent = accent
        self.appName = appName
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 540, height: 640),
                              styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
    }
    required init?(coder: NSCoder) { fatalError() }

    /// Opens on the notices tab when something is unread, otherwise on the intro.
    func show() {
        let lang = NoticeCenter.language()
        let fresh = Set(center.unreadIDs)
        window?.title = "\(appName) · \(lang == "vi" ? "Giới thiệu và Thông báo" : "About and Notices")"
        window?.contentView = NSHostingView(rootView: KeyInfoView(center: center, fresh: fresh, accent: accent,
                                                                  lang: lang, startTab: fresh.isEmpty ? .intro : .notices))
        if window?.isVisible != true { window?.center() }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        // Pick up anything new while the window is open (still at most once per 24 h).
        Task { await center.refreshIfDue() }
    }
}

extension NoticeCenter {
    /// Menu title with the unread count, e.g. "Giới thiệu & Thông báo (2)".
    func infoMenuTitle(_ lang: String = NoticeCenter.language()) -> String {
        let base = lang == "vi" ? "Giới thiệu & Thông báo" : "About & Notices"
        return unreadCount > 0 ? "\(base) (\(unreadCount))" : base
    }
}
