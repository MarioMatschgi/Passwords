//
//  MainView.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import SwiftUI

var mainView: MainView?
struct MainView: View {
    @ObservedObject var vaultData: VaultData = VaultData()
    
    init() {
        mainView = self
    }
    
    @State var isAddSheet = true//false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Keychains: (\(vaultData.vault.count))")) {
                    ForEach(vaultData.vault.keys.sorted(), id: \.self) { key in
                        let element: KeychainData = vaultData.vault[key]!
                        NavigationLink(destination: KeychainView(vaultData: vaultData, keychain: key)) {
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
            AddView(vaultData: vaultData, isOpen: $isAddSheet)
        }
        
        .onAppear() {
            vaultData.vault = manager!.GetVault()
        }
    }
}

struct KeychainView: View {
    @ObservedObject var vaultData: VaultData
    @State var keychain: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Passwords: (\(vaultData.vault[keychain]!.passwords.count))")) {
                    ForEach(0..<vaultData.vault[keychain]!.passwords.count, id: \.self) { idx in
                        let element: PasswordData = vaultData.vault[keychain]!.passwords[idx]
                        NavigationLink(destination: Text("ASD")) {
                            HStack {
                                Text("\(element.name)")
                            }
                        }
                    }
                }.collapsible(false)
            }.listStyle(InsetListStyle())

            Text("No password selected")
        }.navigationViewStyle(DefaultNavigationViewStyle())//.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}


struct AddView: View {
    @ObservedObject var vaultData: VaultData
    @Binding var isOpen: Bool
    
    @State var pw_type = PasswordType.web
    @State var pw_username = ""
    @State var pw_email = ""
    @State var pw_description = ""
    @State var pw_url = ""
    @State var pw_pw = ""
    @State var pw_autofill = ""
    @State var pw_keychain = ""
    
    @State var isFieldMissing = false
    
    let formMargin = CGFloat(75)
    
    var body: some View {
        VStack {
            Picker("", selection: $pw_type) {
                Text("Normal").tag(PasswordType.normal)
                Text("Website").tag(PasswordType.web)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden()
            Spacer().frame(height: 25)
            Form {
                HStack(alignment: VerticalAlignment.top) {
//                    FormText(GetTxt(), formMargin)
                    Text("\(GetTxt())*").frame(width: formMargin, alignment: .leading)
                    TextField(GetTxt(), text: $pw_url).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("Username\(pw_autofill == "username" ? "*" : "")").frame(width: formMargin, alignment: .leading)
                    TextField("Username", text: $pw_username).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    Text("E-mail\(pw_autofill == "email" ? "*" : "")").frame(width: formMargin, alignment: .leading)
                    TextField("e-mail", text: $pw_email).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Password*", formMargin)
                    SecureField("Password", text: $pw_pw).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Description", formMargin)
                    TextField("Description", text: $pw_description).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Keychain*", formMargin)
                    Picker(selection: $pw_keychain, label: EmptyView()) {
                        Text("select keychain").tag("")
                        ForEach(vaultData.vault.keys.sorted(), id: \.self) { keychain in
                            Text(keychain).tag(keychain)
                        }
                    }.labelsHidden()
                }
                HStack(alignment: VerticalAlignment.top) {
                    FormText("Autofill*", formMargin)
                    Picker(selection: $pw_autofill, label: EmptyView()) {
                        Text("Username").tag("username")
                        Text("E-mail").tag("email")
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
                        pw_url = "programario.at"
                        pw_username = "Mario"
                        pw_email = "mario@programario.at"
                        pw_pw = "1234"
                        pw_description = "Programario is the best"
                        pw_keychain = "Keychain1"
                        pw_autofill = "username"
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
        if pw_url == "" || (pw_autofill == "username" && pw_username == "") || (pw_autofill == "email" && pw_email == "") || pw_pw == "" || pw_keychain == "" || pw_autofill == "" {
            return false
        }
        
        // Add new PW
        manager?.AddPassword(data: PasswordData(name: pw_username, url: pw_url, type: pw_type, password: pw_pw), keychain: pw_keychain)
        
        return true
    }
    
    func GetTxt() -> String {
        return pw_type == PasswordType.web ? "Website" : pw_type == PasswordType.normal ? "Name" : "INVALID"
    }
}

//struct EditView: View {
//    var body: some View {
//        VStack {
//            Picker("", selection: $pw_type) {
//                Text("Normal").tag(PasswordType.normal)
//                Text("Website").tag(PasswordType.web)
//            }.pickerStyle(SegmentedPickerStyle()).labelsHidden()
//            Spacer().frame(height: 25)
//            Form {
//                HStack(alignment: VerticalAlignment.top) {
////                    FormText(GetTxt(), formMargin)
//                    Text("\(GetTxt())*").frame(width: formMargin, alignment: .leading)
//                    TextField(GetTxt(), text: $pw_url).textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("Username*", formMargin)
//                    TextField("Username", text: $pw_username).textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("E-mail*", formMargin)
//                    TextField("e-mail", text: $pw_email).textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("Password*", formMargin)
//                    SecureField("Password", text: $pw_pw).textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("Description", formMargin)
//                    TextField("Description", text: $pw_description).textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("Keychain*", formMargin)
//                    Picker(selection: $pw_keychain, label: EmptyView()) {
//                        Text("select keychain").tag("")
//                        ForEach(vaultData.vault.keys.sorted(), id: \.self) { keychain in
//                            Text(keychain).tag(keychain)
//                        }
//                    }.labelsHidden()
//                }
//                HStack(alignment: VerticalAlignment.top) {
//                    FormText("Autofill*", formMargin)
//                    Picker(selection: $pw_autofill, label: EmptyView()) {
//                        Text("Username").tag("username")
//                        Text("E-mail").tag("email")
//                    }.pickerStyle(RadioGroupPickerStyle()).horizontalRadioGroupLayout().labelsHidden()
//                }
//            }
//
//            Spacer().frame(minHeight: 25)
//            HStack {
//                Button(action: { isOpen = false }) {
//                    Text("Cancel")
//                }.keyboardShortcut(.cancelAction)
//                if manager!.debug {
//                    Spacer()
//                    Button(action: {
//                        pw_url = "programario.at"
//                        pw_username = "Mario"
//                        pw_email = "mario@programario.at"
//                        pw_pw = "1234"
//                        pw_description = "Programario is the best"
//                        pw_keychain = "Keychain1"
//                        pw_autofill = "username"
//                    }) {
//                        Text("FILL")
//                    }
//                }
//                Spacer()
//                Button(action: {
//                    let res = TryAdd()
//                    if res {
//                        isFieldMissing = false
//                        isOpen = false
//                    } else {
//                        isFieldMissing = true
//                    }
//                }) {
//                    Text("Add")
//                }.keyboardShortcut(.defaultAction)
//            }
//        }
//    }
//}

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


struct BlaView: View {
    @State private var selection = 0
    var body: some View {
        Button(action: { manager?.AddPassword(data: PasswordData(name: "Name", url: "Url", type: PasswordType.web, password: "1234"), keychain: "Keychain1") }) {
            Text("ADD NEW PW")
        }
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
