//
//  PasswordsApp.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import SwiftUI

@main
// MARK: - PASSWORD-APP
/// PasswordApp: The app
struct PasswordsApp: App {
    // @AppStorage("appTheme") var appTheme: String = "system"

    /// Creates a PasswordApp instance
    init() {
        manager = Manager()
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
//            CommandGroup(after: .windowArrangement) {
//                Button(action: {
//                    NSApp.appearance = NSAppearance(named: .darkAqua)
//                    appTheme = "dark"
//                }) {
//                    Text("Dark mode").fontWeight(.medium)
//                }.modifier(MenuButtonStyling())
//
//                Button(action: {
//                    NSApp.appearance = NSAppearance(named: .aqua)
//                    appTheme = "light"
//                }) {
//                    Text("Light mode").fontWeight(.medium)
//                }.modifier(MenuButtonStyling())
//
//                Button(action: {
//                    NSApp.appearance = nil
//                    appTheme = "system"
//                }) {
//                    Text("System mode").fontWeight(.medium)
//                }.modifier(MenuButtonStyling())
//            }

//            CommandMenu("Utilities") {
//                Button(action: {
//                    NotificationCenter.default.post(name: .flipImage, object: nil)
//                }) {
//                    Text("Flip Image").fontWeight(.medium)
//                }.modifier(MenuButtonStyling())
//                .keyboardShortcut("i")
//
//                Button(action: {
//                    NotificationCenter.default.post(name: .showSamples, object: nil)
//                }) {
//                    Text("Toggle UI Samples Window").fontWeight(.medium)
//                }.modifier(MenuButtonStyling())
//                .keyboardShortcut("u")
//            }
        }

        Settings {
            SettingsView()
        }
    }
}

//struct MenuButtonStyling: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .foregroundColor(.primary)
//            .padding(.bottom, 2)
//            .padding(.top, 1)
//    }
//}

