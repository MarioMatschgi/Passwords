//
//  SubViews.swift
//  Passwords
//
//  Created by Mario Elsnig on 09.02.21.
//

import Foundation
import SwiftUI

// MARK: - MARGINS
/// Class: Defines margins
class Margins {
    /// CGFloat: Amount of margin for the form
    static let addSheetFormMargin = CGFloat(120)
}


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
    
    /// PasswordData: Stores information for new password
    @State var pwData = PasswordData(displayname: "", username: "", email: "", website: "", password: "", description: "", autofill: .none, keychain: "")
    
    @State var pbv: PasswordBaseView? = nil
    
    /// KeychainData: Stores information for new keychain
    @State var newKeychain = KeychainData(name: "", passwords: [])
    
    /// Bool: Whether a required field is not filled in
    @State var isFieldMissing = false
    
    @State var addType = AddType.password
    
    // MARK: body
    /// The content of the view
    var body: some View {
        VStack {
            Picker(selection: $addType, label: EmptyView()) {
                ForEach(AddType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }.pickerStyle(SegmentedPickerStyle())
            Spacer().frame(height: 10)
            
            ScrollView {
                VStack {
                    if addType == .password {
                        PasswordBaseView(model: model, pwData: $pwData)
                    } else if addType == .keychain {
                        HStack(alignment: VerticalAlignment.top) {
                            Text("Displayname*").formText(Margins.addSheetFormMargin)
                            TextField("Displayname", text: $newKeychain.name).textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    if isFieldMissing {
                        Spacer().frame(height: 10)
                        FieldMissingText()
                    }
                }.padding(.trailing)
            }
            
            Spacer().frame(height: 25)
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
        }.frame(width: 500, height: 400).padding()  // ToDo: EV IN BASE VIEW VERSCHIEBEN
    }
    
    // MARK: tryAdd
    /// Try to add the current password to the keychain
    func tryAdd() {
        if addType == .password {
            pwData.displayname      = pwData.displayname    .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.username         = pwData.username       .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.email            = pwData.email          .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.website          = pwData.website        .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.password         = pwData.password       .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.passwordConfirm  = pwData.passwordConfirm.trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.description      = pwData.description    .trimmingCharacters(in: .whitespacesAndNewlines)
            pwData.keychain         = pwData.keychain       .trimmingCharacters(in: .whitespacesAndNewlines)
            if pwData.isValid() {
                isFieldMissing = false
                
                // Add new PW
                _ = model.setPassword(data: pwData)
                
                isOpen = false
            } else {
                isFieldMissing = true
            }
        } else if addType == .keychain {
            newKeychain.name = newKeychain.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if newKeychain.isValid() {
                isFieldMissing = false
                
                // Add new Keychain
                model.setKeychain(keychain: newKeychain)
                
                isOpen = false
            } else {
                isFieldMissing = true
            }
        }
    }
    
    // MARK: fillForm
    /// Fill the form with default values
    func fillForm() {
        if addType == .password {
            pwData.displayname      = "Displayname"
            pwData.username         = "Mario"
            pwData.email            = "mario@programario.at"
            pwData.website          = "programario.at"
            pwData.password         = "1234"
            pwData.passwordConfirm  = "1234"
            pwData.description      = "Programario is the best"
            pwData.autofill         = .email
            pwData.keychain         = "Keychain1"
        } else if addType == .keychain {
            newKeychain.name        = "Keychain1"
        }
    }
    
    // MARK: AddType
    /// Enum: Types of things to add in the add-sheet
    enum AddType: String, CaseIterable {
        case password = "Password"
        case keychain = "Keychain"
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
            PasswordBaseView(model: model, pwData: $pwData).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if isFieldMissing {
                Spacer().frame(height: 10)
                FieldMissingText()
            }
        
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
    
    /// Bool: Used to force an update on the view `update.toggle()`
    @State var update = false
    
    // MARK: body
    /// The content of the view
    var body: some View {
        VStack {
            Form {
                HStack(alignment: VerticalAlignment.top) {
                    Text("Displayname*").formText(Margins.addSheetFormMargin)
                    TextField("Displayname", text: $pwData.displayname).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Username\(pwData.autofill == .username ? "*" : "")").formText(Margins.addSheetFormMargin)
                    TextField("Username", text: $pwData.username).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("E-mail\(pwData.autofill == .email ? "*" : "")").formText(Margins.addSheetFormMargin)
                    TextField("e-mail", text: $pwData.email).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Website").formText(Margins.addSheetFormMargin)
                    TextField("website", text: $pwData.website).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Password*").formText(Margins.addSheetFormMargin)
                    SecureField("Password", text: $pwData.password).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Confirm password*").formText(Margins.addSheetFormMargin)
                    SecureField("Confirm password", text: $pwData.passwordConfirm).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Description").formText(Margins.addSheetFormMargin)
                    TextField("Description", text: $pwData.description).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Keychain").formText(Margins.addSheetFormMargin)
                    Picker(selection: $pwData.keychain, label: EmptyView()) {
                        Text("none").tag("")
                        ForEach(model.vaultData.getKeychains().keys.sorted(), id: \.self) { keychain in
                            if keychain != "" {
                                Text(keychain).tag(keychain)
                            }
                        }
                    }.labelsHidden()
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Autofill*").formText(Margins.addSheetFormMargin)
                    Picker(selection: $pwData.autofill, label: EmptyView()) {
                        Text("Username").tag(AutofillType.username)
                        Text("E-mail").tag(AutofillType.email)
                    }.pickerStyle(RadioGroupPickerStyle()).horizontalRadioGroupLayout().labelsHidden()
                }
                if manager!.debugMode {
                    Spacer().frame(height: 10)
                    Section(header: Text("DEBUG:")) {
                        HStack(alignment: VerticalAlignment.top) {
                            Text("UUID:").formText(Margins.addSheetFormMargin)
                            Text("\(pwData.id)")
                        }
                    }
                    
                }
            }
        }.frame(idealWidth: 500)
    }
}

// MARK: FieldMissingText
/// View: Displays a "Please fill in all required fields" text
struct FieldMissingText: View {
    var body: some View {
        Text("Please fill in all required (*) fields").foregroundColor(Color.red)
    }
}
