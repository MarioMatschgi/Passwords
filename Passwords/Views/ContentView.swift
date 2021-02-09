//
//  ContentView.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import SwiftUI

// MARK: - CONTENT-VIEW
/// SettingsView: SwiftUI view for the main window
struct ContentView: View {
    /// The model for authentication
    @ObservedObject var authModel: AuthentificationModel = AuthentificationModel(localizedReason: "Reason")
    
    var body: some View {
        VStack {
            if manager!.debugMode || authModel.loggedIn {
                MainView()
            }
            else {
                AuthentificationView().environmentObject(authModel)
            }
        }
    }
}

// MARK: - PREVIEW-PROVIDER
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
