//
//  SecureInputOverlay.swift
//  XKey
//
//  Shared Secure Input warning presenter for XKey.app and standalone XKeyIM.
//

import Foundation
import SwiftUI

final class SecureInputOverlay: SecureInputPresenting {
    static let shared = SecureInputOverlay()

    /// Independent from other overlays.
    private let overlay = FloatingOverlay()

    private init() {}

    func show(appName: String) {
        overlay.show(
            content: AnyView(OverlayWarningView(
                title: String(localized: "Secure Input đang bật"),
                subtitle: String(localized: "\(appName) đang chặn 1xKey. Bấm biểu tượng 1xKey để xử lý")
            )),
            position: .bottomCenter,
            autoHideAfter: 5
        )
    }

    func hide() {
        overlay.hide()
    }
}
