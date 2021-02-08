//
//  ContentView.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import SwiftUI

struct ContentView: View {
    var debug = true
    
    @ObservedObject var authModel: AuthentificationModel = AuthentificationModel(localizedReason: "Reason")
    
    var body: some View {
        VStack {
            if debug || authModel.loggedIn {
                MainView()
            }
            else {
                AuthentificationView().environmentObject(authModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
