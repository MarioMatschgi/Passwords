//
//  SubViews.swift
//  Passwords
//
//  Created by Mario Elsnig on 09.02.21.
//

import Foundation
import SwiftUI

// MARK: - KEYCHAIN-VIEW
/// KeychainView: View displaying a Keychain
struct KeychainView: View {
    /// The model for all displayed data
    @ObservedObject var model: Model
    /// The name of the Keychain displayed
    @State var keychain: String
    
    // MARK: body
    /// The content of the view
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Passwords: (\(model.vaultData.getPasswords(for: keychain).count))")) {
                    ForEach(0..<model.vaultData.getPasswords(for: keychain).count, id: \.self) { idx in
                        let element: PasswordData = model.vaultData.getPasswords(for: keychain)[idx]
                        NavigationLink(destination: PasswordInfoView(model: model, pwData: element)) {
                            HStack {
                                Text("\(element.displayname)")
                            }
                        }
                    }
                }.collapsible(false)
            }.listStyle(InsetListStyle())

            Text("No password selected")
        }.navigationViewStyle(DefaultNavigationViewStyle())
    }
}

// MARK: - PASSWORD-ADD-VIEW
/// AddView: View displaying everything needed for adding a password
struct AddView: View {
    /// The model for all displayed data
    @ObservedObject var model: Model
    /// Bool: Whether the sheet should be displayed
    @Binding var isOpen: Bool
    
    /// PasswordData: Stores information for password
    @State var pwData = PasswordData(displayname: "", username: "", email: "", website: "", password: "", description: "", autofill: .none, keychain: "")
    
    /// Bool: Whether a required field is not filled in
    @State var isFieldMissing = false
    
    // MARK: body
    /// The content of the view
    var body: some View {
        VStack {
            PasswordBaseView(model: model, pwData: $pwData, isFieldMissing: $isFieldMissing)
            
            Spacer().frame(minHeight: 25)
            HStack {
                Button(action: { isOpen = false }) {
                    Text("Cancel")
                }.keyboardShortcut(.cancelAction)
                if manager!.debugMode {
                    Spacer()
                    Button(action: { fillForm() }) {
                        Text("FILL")
                    }
                }
                Spacer()
                Button(action: { tryAdd() }) {
                    Text("Add")
                }.keyboardShortcut(.defaultAction)
            }
        }.padding()
    }
    
    // MARK: tryAdd
    /// Try to add the current password to the keychain
    func tryAdd() {
        if pwData.isValid() {
            isFieldMissing = false
            
            // Add new PW
            _ = model.setPassword(data: pwData)
            
            isOpen = false
        } else {
            isFieldMissing = true
        }
    }
    
    // MARK: fillForm
    /// Fill the form with default values
    func fillForm() {
        print("D \(pwData.displayname)")
        pwData.displayname = "Displayname"
        pwData.username = "Mario"
        pwData.email = "mario@programario.at"
        pwData.website = "programario.at"
        pwData.password = "1234"
        pwData.description = "Programario is the best"
        pwData.autofill = .email
        pwData.keychain = "Keychain1"
        
        print("D \(pwData.displayname)")
    }
}

// MARK: - PASSWORD-INFO-VIEW
struct PasswordInfoView: View {
    /// The model for all displayed data
    @ObservedObject var model: Model
    
    /// PasswordData: Stores information for password
    @State var pwData: PasswordData
    
    /// Bool: Whether a required field is not filled in
    @State var isFieldMissing = false
    
    // MARK: body
    /// The content of the view
    var body: some View {
        VStack {
            PasswordBaseView(model: model, pwData: $pwData, isFieldMissing: $isFieldMissing).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
            Spacer().frame(height: 25)
            HStack {
                Button(action: { model.removePassword(data: pwData) }) {
                    Text("Delete")
                }.keyboardShortcut(.delete).keyboardShortcut(.deleteForward)
                Spacer()
                Button(action: { _ = model.setPassword(data: pwData) }) {
                    Text("Save")
                }.keyboardShortcut(.defaultAction)
            }
        }.padding()
    }
}

// MARK: - PASSWORD-BASE-VIEW
struct PasswordBaseView: View {
    /// The model for all displayed data
    @ObservedObject var model: Model
    
    /// PasswordData: Stores information for password
    @Binding var pwData: PasswordData
    
    /// Bool: Whether a required field is not filled in
    @Binding var isFieldMissing: Bool
    
    /// Bool: Used to force an update on the view `update.toggle()`
    @State var update = false
    
    /// CGFloat: Amount of margin for the form
    let formMargin = CGFloat(100)
    
    // MARK: body
    /// The content of the view
    var body: some View {
        VStack {
            Form {
                HStack(alignment: VerticalAlignment.top) {
                    Text("Displayname*").formText(formMargin)
                    TextField("Displayname", text: $pwData.displayname).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Username\(pwData.autofill == .username ? "*" : "")").formText(formMargin)
                    TextField("Username", text: $pwData.username).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("E-mail\(pwData.autofill == .email ? "*" : "")").formText(formMargin)
                    TextField("e-mail", text: $pwData.email).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Website").formText(formMargin)
                    TextField("website", text: $pwData.website).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Password*").formText(formMargin)
                    SecureField("Password", text: $pwData.password).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Description").formText(formMargin)
                    TextField("Description", text: $pwData.description).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Keychain").formText(formMargin)
                    Picker(selection: $pwData.keychain, label: EmptyView()) {
                        Text("none").tag("")
                        ForEach(model.vaultData.getKeychains().keys.sorted(), id: \.self) { keychain in
                            Text(keychain).tag(keychain)
                        }
                    }.labelsHidden()
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Autofill*").formText(formMargin)
                    Picker(selection: $pwData.autofill, label: EmptyView()) {
                        Text("Username").tag(AutofillType.username)
                        Text("E-mail").tag(AutofillType.email)
                    }.pickerStyle(RadioGroupPickerStyle()).horizontalRadioGroupLayout().labelsHidden()
                }
                if manager!.debugMode {
                    Spacer().frame(height: 10)
                    Section(header: Text("DEBUG:")) {
                        Text("UUID: \(pwData.id)")
                    }
                }
            }
            
            if isFieldMissing {
                Spacer().frame(minHeight: 10)
                Text("Please fill in all required (*) fields").foregroundColor(Color.red)
            }
        }.frame(idealWidth: 400, idealHeight: 250)
    }
}
