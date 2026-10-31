//
//  XKeyApp.swift
//  XKey
//
//  Main app entry point
//

import SwiftUI
import Foundation

@main
struct XKeyApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppLanguage.applyLanguage()
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            // 1xKey has no settings window; everything lives in the menu bar popover.
            CommandGroup(replacing: .appSettings) {}
        }
    }
}

