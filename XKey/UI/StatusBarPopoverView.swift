import SwiftUI

// MARK: - Glass Design Menu Bar Popover (macOS 12+)

struct StatusBarPopoverView: View {
    @ObservedObject var viewModel: StatusBarViewModel
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

            toggleSection
            inputMethodSection
            footerSection
        }
        .padding(.vertical, 6)
        .frame(width: 280)
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
