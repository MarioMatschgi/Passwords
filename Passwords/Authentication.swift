//
//  Authentification.swift
//  Passwords
//
//  Created by Mario Elsnig on 27.01.21.
//

import SwiftUI
import Foundation
import LocalAuthentication

class AuthentificationModel: ObservableObject {
    @Published var loggedIn: Bool = false
    @Published var hasChanges: Bool = false
    @Published var localizedReason: String
    
    private var domainState: Data?
    
    init(localizedReason: String) {
        self.localizedReason = localizedReason
    }
    
    func auth() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) {
            [weak self] (res, err) in
            DispatchQueue.main.async {
                self?.loggedIn = res
            }
        }
    }
    
    func check() {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        checkDomainState(context.evaluatedPolicyDomainState)
    }
    
    private func checkDomainState(_ domainState: Data?) {
        if let `domainState` = domainState {
            if domainState != self.domainState {
                hasChanges = true
            } else {
                hasChanges = false
            }
        }
        self.domainState = domainState
        hasChanges = true
    }
    
}

struct AuthentificationView: View {
    var touchIDOnAppear: Bool = true
    
    @EnvironmentObject var viewModel: AuthentificationModel
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Text("Login to proceed").font(.title)
            HStack {
                SecureField("Password", text: $password, onCommit: { LoginWithPassword(pw: password) }).textContentType(.password).textFieldStyle(RoundedBorderTextFieldStyle()).frame(minWidth: 150)
                Spacer().frame(width: 10)
                Button(action: { LoginWithPassword(pw: password) }, label: {
                    Text("Login")
                })
            }
            Spacer().frame(height: 10)
            Button(action: { LoginWithBiometric() }) {
                Text("Login with TouchID")
            }
        }.onAppear() {
            if touchIDOnAppear && !IsInPreview() {
                LoginWithBiometric()
            }
        }.fixedSize()
    }
    
    func LoginWithPassword(pw: String) {
        print("LOGIN with PW: \(pw)")
    }
    func LoginWithBiometric() {
        self.viewModel.auth()
    }
}

struct AuthentificationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthentificationView().environmentObject(AuthentificationModel(localizedReason: "Reason"))
    }
}
