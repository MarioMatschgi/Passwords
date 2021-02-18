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

    // MARK: init
    /// Creates a PasswordApp instance
    init() {
        manager = Manager()
    }
    
    // MARK: body
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button(action: {  }, label: {
                    Text("New item")
                }).keyboardShortcut("n", modifiers: .command)
            }
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

