//
//  MainView.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import SwiftUI

var mainView: MainView?

// MARK: - MAIN-VIEW
/// Main-View: The main view where everything happens
struct MainView: View {
    /// The model for all displayed data
    @ObservedObject var model: Model = Model()
    
    /// Creates an instance of MainView
    init() {
        mainView = self
    }
    
    /// Bool: Describes wether the add-sheet should be displayed
    @State var isAddSheet = true//false
    
    /// Bool: Used to force an update on the view `update.toggle()`
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

// MARK: - FORM-TEXT
extension View {
    func formText(_ formMargin: CGFloat) -> some View {
        self.frame(width: formMargin, alignment: .leading)
    }
}

// MARK: - TOOLBAR-MODIFIER
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

// MARK: - PREVIEW-PROVIDER
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
