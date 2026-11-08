import SwiftUI
import Combine

// MARK: - Glass Design Menu Bar Popover (macOS 12+)

struct StatusBarPopoverView: View {
    @ObservedObject var viewModel: StatusBarViewModel
    @ObservedObject var notices: NoticeCenter = KeyNotices.center
    var onCheckForUpdates: (() -> Void)?
    var onDismiss: (() -> Void)?

    @State private var isInputMethodExpanded = true

    var body: some View {
        VStack(spacing: 4) {
            Text(AppCredits.slogan)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)

            if let advice = viewModel.secureInputAdvice {
                secureInputCard(advice)
            }
            toggleSection
            inputMethodSection
            launchAtLoginSection
            footerSection
        }
        .padding(.vertical, 6)
        .frame(width: 280)
        .onAppear {
            viewModel.refreshLaunchAtLogin()
            viewModel.refreshSecureInputAdvice()
        }
        // Which app is in front, and whether its focused field is a password field, change
        // without any Secure Input event; the settings pane can also flip the login item.
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            viewModel.refreshSecureInputAdvice()
            viewModel.refreshLaunchAtLogin()
        }
    }

    // MARK: - Secure Input
    private func secureInputCard(_ advice: SecureInputAdvice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 3) {
                    Text(advice.headline)
                        .font(.system(size: 12, weight: .semibold))
                    Text(advice.detail)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if let title = advice.actionTitle {
                Button(title) {
                    onDismiss?()
                    viewModel.performSecureInputRemedy(advice)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.12))
        )
        .padding(.horizontal, 8)
    }

    // MARK: - Launch at login
    private var launchAtLoginSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Mở cùng macOS")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.launchAtLogin },
                    set: { viewModel.setLaunchAtLogin($0) }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
            }
            if viewModel.launchAtLoginNeedsApproval {
                Text("macOS cần bạn bật 1xKey trong Cài đặt hệ thống → Mục đăng nhập.")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .menuCardStyle()
    }

    /// 1xKey offers only the two layouts Vietnamese typists actually use.
    private let minimalInputMethods: [InputMethod] = [.telex, .vni]

    // MARK: - Toggle Section
    private var toggleSection: some View {
        HStack {
            Text("Gõ Tiếng Việt")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.isVietnameseEnabled },
                set: { _ in viewModel.toggleVietnamese() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .menuCardStyle()
    }

    // MARK: - Input Method Section
    private var inputMethodSection: some View {
        VStack(spacing: 0) {
            // Section header - clickable to expand/collapse
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isInputMethodExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Kiểu gõ")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                    Text(viewModel.currentInputMethod.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Image(systemName: isInputMethodExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)

            if isInputMethodExpanded {
                VStack(spacing: 1) {
                    ForEach(minimalInputMethods, id: \.self) { method in
                        MenuRow(
                            title: LocalizedStringKey(method.displayName),
                            isSelected: method == viewModel.currentInputMethod
                        ) {
                            viewModel.selectInputMethod(method)
                        }
                    }
                }
                .menuCardStyle()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 1) {
            ActionRow(title: LocalizedStringKey(notices.infoMenuTitle()),
                      icon: notices.unreadCount > 0 ? "bell.badge" : "info.circle") {
                onDismiss?()
                KeyNotices.infoWindow.show()
            }
            .accessibilityLabel(notices.unreadCount > 0
                                ? "\(notices.infoMenuTitle()), \(notices.accessibilityTitle())"
                                : notices.infoMenuTitle())

            ActionRow(title: "Thoát 1xKey", icon: "power", shortcut: "⌘Q") {
                viewModel.quit()
            }

            Text(AppCredits.line)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .menuCardStyle()
    }

    // MARK: - Section Divider
    private var sectionDivider: some View {
        Color.clear.frame(height: 0)
    }
}

// MARK: - macOS Card Style Modifier

private struct MenuCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary.opacity(0.05))
            )
            .padding(.horizontal, 8)
    }
}

private extension View {
    func menuCardStyle() -> some View {
        self.modifier(MenuCardModifier())
    }
}

// MARK: - Menu Row (selectable with checkmark, macOS style)

private struct MenuRow: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark" : "")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.accentColor)
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.accentColor.opacity(0.12) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Action Row (clickable row with icon, macOS style)

private struct ActionRow: View {
    let title: LocalizedStringKey
    let icon: String
    var shortcut: String? = nil
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isHovered ? .white.opacity(0.9) : .secondary)
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isHovered ? .white : .primary)
                Spacer()
                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 11))
                        .foregroundColor(isHovered ? .white.opacity(0.7) : .secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - NSVisualEffectView Hosting (Glass Background)

/// NSViewRepresentable wrapping NSVisualEffectView for glass/vibrancy effect
struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - 1xAg notices (feed https://1xag.com/notices.json, product key "key")

enum KeyNotices {
    static let center = NoticeCenter(product: "key")
    /// Cobalt #2B3BFF on light, #8C97FF on dark (1xAg tokens).
    static let accent = Color(nsColor: NSColor(name: "1xAgAccent") { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(srgbRed: 0x8C / 255.0, green: 0x97 / 255.0, blue: 1, alpha: 1)
            : NSColor(srgbRed: 0x2B / 255.0, green: 0x3B / 255.0, blue: 1, alpha: 1)
    })
    static let infoWindow = KeyInfoWindowController(center: center, accent: accent, appName: "1xKey")
    private static var timer: Timer?

    /// At launch when due, then an hourly look; the feed itself is fetched at most once per 24 h. Silent offline.
    static func start() {
        Task { await center.refreshIfDue() }
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task { await center.refreshIfDue() }
        }
    }
}
