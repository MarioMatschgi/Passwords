//
//  Extentions.swift
//  Passwords
//
//  Created by Mario Elsnig on 03.02.21.
//

import SwiftUI
import Foundation
import KeychainAccess

func IsInPreview() -> Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension Keychain {
    func removeKey(_ key: String) {
        do {
            try remove(key)
        } catch { print(error.localizedDescription) }
    }
}

extension View {
    func alignTop() -> some View {
        self.frame(maxHeight: .infinity, alignment: .top)
    }
    func alignBottom() -> some View {
        self.frame(maxHeight: .infinity, alignment: .bottom)
    }
    func alignLeft() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
    func alignRight() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
}
