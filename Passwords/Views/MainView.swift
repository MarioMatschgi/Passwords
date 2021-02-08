//
//  MainView.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import SwiftUI

var mainView: MainView?
struct MainView: View {
    @ObservedObject var model: Model = Model()
    
    init() {
        mainView = self
    }
    
    @State var isAddSheet = true//false
    
    @State var update = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Keychains: (\(model.vaultData.keychains.count))")) {
                    ForEach(model.vaultData.keychains.keys.sorted(), id: \.self) { key in
                        let element: KeychainData = model.vaultData.keychains[key]!
                        NavigationLink(destination: KeychainView(model: model, keychain: key)) {
                            HStack {
                                Text("\(element.name) (\(element.passwords.count))")
                            }
                        }
                    }
                }.collapsible(false)
            }.listStyle(SidebarListStyle())

            Text("No keychain selected")
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
        
        .navigationTitle("Passwords")
        .modifier(ToolbarModifier(isAddSheet: $isAddSheet))
        
        .sheet(isPresented: $isAddSheet) {
            AddView(model: model, isOpen: $isAddSheet)
        }
        
        .onAppear() {
            model.vaultData = manager!.LoadRegisterData()
        }
    }
}

struct KeychainView: View {
    @ObservedObject var model: Model
    @State var keychain: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Passwords: (\(model.vaultData.keychains[keychain]!.passwords.count))")) {
                    ForEach(0..<model.vaultData.keychains[keychain]!.passwords.count, id: \.self) { idx in
                        let element: PasswordData = model.vaultData.keychains[keychain]!.passwords[idx]
                        NavigationLink(destination: Text("ASD")) {
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


struct AddView: View {
    @ObservedObject var model: Model
    @Binding var isOpen: Bool
    
    @State var pw_displayname = ""
    @State var pw_username = ""
    @State var pw_email = ""
    @State var pw_website = ""
    @State var pw_password = ""
    @State var pw_description = ""
    @State var pw_autofill: AutofillType = .none
    @State var pw_keychain = ""
    
    
    @State var isFieldMissing = false
    
    let formMargin = CGFloat(100)
    
    var body: some View {
        VStack {
            Form {
                HStack(alignment: VerticalAlignment.top) {
                    Text("Displayname*").frame(width: formMargin, alignment: .leading)
                    TextField("Displayname", text: $pw_displayname).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Username\(pw_autofill == .username ? "*" : "")").frame(width: formMargin, alignment: .leading)
                    TextField("Username", text: $pw_username).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("E-mail\(pw_autofill == .email ? "*" : "")").frame(width: formMargin, alignment: .leading)
                    TextField("e-mail", text: $pw_email).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Password*", formMargin)
                    SecureField("Password", text: $pw_password).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Description", formMargin)
                    TextField("Description", text: $pw_description).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Keychain*", formMargin)
                    Picker(selection: $pw_keychain, label: EmptyView()) {
                        Text("select keychain").tag("")
                        ForEach(model.vaultData.keychains.keys.sorted(), id: \.self) { keychain in
                            Text(keychain).tag(keychain)
                        }
                    }.labelsHidden()
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Autofill*", formMargin)
                    Picker(selection: $pw_autofill, label: EmptyView()) {
                        Text("Username").tag(AutofillType.username)
                        Text("E-mail").tag(AutofillType.email)
                    }.pickerStyle(RadioGroupPickerStyle()).horizontalRadioGroupLayout().labelsHidden()
                }
            }
            
            if isFieldMissing {
                Spacer().frame(minHeight: 10)
                Text("Please fill in all required (*) fields").foregroundColor(Color.red)
            }
            
            Spacer().frame(minHeight: 25)
            HStack {
                Button(action: { isOpen = false }) {
                    Text("Cancel")
                }.keyboardShortcut(.cancelAction)
                if manager!.debug {
                    Spacer()
                    Button(action: {
                        pw_displayname = "Displayname"
                        pw_username = "Mario"
                        pw_email = "mario@programario.at"
                        pw_website = "programario.at"
                        pw_password = "1234"
                        pw_description = "Programario is the best"
                        pw_autofill = .email
                        pw_keychain = "Keychain1"
                    }) {
                        Text("FILL")
                    }
                }
                Spacer()
                Button(action: {
                    let res = TryAdd()
                    if res {
                        isFieldMissing = false
                        isOpen = false
                    } else {
                        isFieldMissing = true
                    }
                }) {
                    Text("Add")
                }.keyboardShortcut(.defaultAction)
            }
        }.frame(idealWidth: 400, idealHeight: 250).padding()
    }
    
    func TryAdd() -> Bool {
        if pw_website == "" || (pw_autofill == .username && pw_username == "") || (pw_autofill == .email && pw_email == "") || pw_password == "" || pw_keychain == "" || pw_autofill == .none {
            return false
        }
        
        // Add new PW
        return model.setPassword(data: PasswordData(displayname: pw_displayname, username: pw_username, email: pw_email, website: pw_website, password: pw_password, description: pw_description, autofill: pw_autofill, keychain: pw_keychain))
    }
}

struct FormText: View {
    @State var text: String
    @State var formMargin: CGFloat
    
    init(_ text: String, _ formMargin: CGFloat) {
        self._text = State(initialValue: text)
        self._formMargin = State(initialValue: formMargin)
    }
    
    var body: some View {
        Text(text).frame(width: formMargin, alignment: .leading)
    }
}

struct ToolbarModifier: ViewModifier {
    @Binding var isAddSheet: Bool
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAddSheet = true }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
    
    func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
