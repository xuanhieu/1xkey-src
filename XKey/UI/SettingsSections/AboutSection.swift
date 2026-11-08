//
//  AboutSection.swift
//  XKey
//
//  Shared About Settings Section
//

import SwiftUI

struct AboutSection: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // App Logo
                if let logo = NSImage(named: "XKeyLogo") {
                    Image(nsImage: logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.top, 20)
                } else {
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)
                }
                
                // App Name & Version
                VStack(spacing: 4) {
                    Text("1xKey")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Vietnamese Input Method for macOS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(AppVersion.fullVersion)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                Divider()
                    .padding(.horizontal, 80)
                
                // Author
                VStack(spacing: 4) {
                    Text(AppCredits.signature)
                        .font(.system(size: 12, weight: .medium))
                    Button(AppCredits.builtBy) {
                        if let url = URL(string: AppCredits.authorPage) { NSWorkspace.shared.open(url) }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    Text("Gõ thẳng, không gạch chân, không gửi dữ liệu ra ngoài.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .padding(.horizontal, 80)

                // GitHub Links
                HStack(spacing: 20) {
                    Button(action: {
                        if let url = URL(string: "https://1xag.com/key") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .frame(width: 14, height: 14)
                            Text("Trang chủ")
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(action: {
                        if let url = URL(string: "https://1xag.com/key#gop-y") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image("BugIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                            Text("Góp ý")
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.vertical, 8)
                
                Divider()
                    .padding(.horizontal, 80)

                // Update Check Section - Using Sparkle
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        Text("Kiểm tra phiên bản mới")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button("Kiểm tra cập nhật") {
                        // Temporarily lower the Settings window level so Sparkle dialog appears on top
                        if let settingsWindow = NSApp.keyWindow {
                            settingsWindow.level = .normal
                        }
                        
                        // Use AppDelegate.shared for reliable access
                        if let appDelegate = AppDelegate.shared {
                            appDelegate.checkForUpdatesFromUI()
                        } else if let delegate = NSApplication.shared.delegate as? AppDelegate {
                            delegate.checkForUpdatesFromUI()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Copyright
                Text("© 2026 \(AppCredits.author). \(AppCredits.upstream). Phát hành theo GPL-3.0.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
