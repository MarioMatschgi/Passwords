//
//  Data.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import Foundation


class VaultData: ObservableObject {
    @Published var vault: [String: KeychainData]
    
    init() {
        vault = ["All keychains": KeychainData(name: "All keychains", passwords: [])]
    }
    
    func AddPassword(data: PasswordData, keychain: String) {
        if vault[keychain] == nil {  // If vault does not contain keychain with current pw add new keychain
            vault[keychain] = KeychainData(name: keychain, passwords: [data])
        } else {    // Vault contains keychain, add pw to the keychain
            vault[keychain]!.passwords.append(data)
        }
    }
}

struct KeychainData {
    var name: String
    var passwords: [PasswordData]
}

struct PasswordData {
    var name: String
    var url: String
    var type: String
    var password: String
}

struct RegisterVaultData: Codable {
    var passwords: [RegisterPasswordData]
    
    init() {
        passwords = []
    }
    
    init(passwords: [RegisterPasswordData]) {
        self.passwords = passwords
    }
    
    init(json: String) {
        passwords = []
        
        let decoder = JSONDecoder()

        do {
            let vaultData = try decoder.decode(RegisterVaultData.self, from: Data(json.utf8))
            self = vaultData
        } catch { print(error.localizedDescription) }
    }
    func ToJSON() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch { print(error) }
        
        return ""
    }
}
struct RegisterPasswordData: Codable {
    var name: String
    var url: String
    var type: String
    var keychain: String
}
class PasswordType {
    static let web = "web"
    static let normal = "normal"
}
