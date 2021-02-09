//
//  Extentions.swift
//  Passwords
//
//  Created by Mario Elsnig on 03.02.21.
//

import SwiftUI
import Foundation
import KeychainAccess

// MARK: - IS-IN-PREVIEW
/// Checks wether the app is running in the canvas (preview mode)
/// - Returns: Whether the app is running in preview mode
func IsInPreview() -> Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

// MARK: - KEYCHAIN
extension Keychain {
    /// Removes a key from the keychain without throwing the error
    func removeKey(_ key: String) {
        do {
            try remove(key)
        } catch { print(error.localizedDescription) }
    }
}

// MARK: - VIEW
extension View {
    /// Aligns the view to the top
    func alignTop() -> some View {
        self.frame(maxHeight: .infinity, alignment: .top)
    }
    /// Aligns the view to the bottom
    func alignBottom() -> some View {
        self.frame(maxHeight: .infinity, alignment: .bottom)
    }
    /// Aligns the view to the left
    func alignLeft() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
    /// Aligns the view to the right
    func alignRight() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
}
