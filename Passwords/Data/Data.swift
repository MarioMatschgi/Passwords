//
//  Data.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import Foundation


//class VaultData: ObservableObject {
//    @Published var vault: [String: KeychainData]
//
//    init() {
//        vault = ["All keychains": KeychainData(name: "All keychains", passwords: [])]
//    }
//
//    func AddPassword(data: PasswordData, keychain: String) {
//        if vault[keychain] == nil {  // If vault does not contain keychain with current pw add new keychain
//            vault[keychain] = KeychainData(name: keychain, passwords: [data])
//        } else {    // Vault contains keychain, add pw to the keychain
//            vault[keychain]!.passwords.append(data)
//        }
//    }
//}
//
//struct KeychainData {
//    var name: String
//    var passwords: [PasswordData]
//}
//
//struct PasswordData {
//    var name: String
//    var url: String
//    var type: String
//    var password: String
//}

/// Model: Model storing all data
class Model: ObservableObject {
    /// VaultData: Data for the Model
    @Published var vaultData: VaultData
    
    /// Creates a Model with no initial data
    init() {
        self.vaultData = VaultData()
    }
    
    /// Creates a Model with the given data
    /// - Parameters:
    ///     - vaultData: VaultData: The initial data for the Model
    init(vaultData: VaultData) {
        self.vaultData = vaultData
    }
    
    /// Adds a password to the keychain
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    /// - Returns: Bool: Wether the adding was successful
    func addPassword(data: PasswordData) -> Bool {
        // Check if password exists
//        if false {    // ToDo:
//            return false
//        }
        
        // Add password to app Keychain
        let res = vaultData.setPassword(data: data)
        if !res { return false }
        
        // Add password to user Keychain
        // ToDo:
        
        return true
    }
}

/// VauldData: Stores all data
struct VaultData: Codable {
    /// Dictionary with name of keychain as key and KeychainData as value
    var keychains: [String: KeychainData]
    
    /// Creates an empty VaultData
    init() {
        keychains = [:]
    }
    
    /// Creates a VaultData from a JSON String
    init(json: String) {
        self.init()
        
        let decoder = JSONDecoder()

        do {
            let vaultData = try decoder.decode(VaultData.self, from: Data(json.utf8))
            self = vaultData
        } catch { print(error.localizedDescription) }
    }
    
    /// Converts the VaultData to a JSON string
    /// - Returns: String: The VaultData as a JSON String
    func ToJSON() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch { print(error) }
        
        return ""
    }
    
    /// Sets a password in the vault, if one with the displayname exists it will get changed, if none with the displayname exists it will get added
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    /// - Returns: Bool: Wether the operation was successful
    mutating func setPassword(data: PasswordData) -> Bool {
        if keychains[data.keychain] == nil {
            keychains[data.keychain] = KeychainData(name: data.keychain, passwords: [data])
        }
        else {
            let idx = keychains[data.keychain]!.passwords.firstIndex(where: { $0.displayname == data.displayname })
            if idx == nil {
                // Add password to vault
                keychains[data.keychain]!.passwords.append(data)
            } else {
                // Password exists, update
                keychains[data.keychain]!.passwords[idx!] = data
            }
        }
//        dump(keychains)
        
        // Save to Keychain
        manager!.SaveRegisterData(data: self)
        
        return true
    }
}

struct KeychainData: Codable {
    var name: String
    var passwords: [PasswordData]
}

struct PasswordData: Codable {
    var displayname: String
    var username: String
    var website: String
    var password: String
    var description: String
    var type: String
    var keychain: String
}

class PasswordType {
    static let web = "web"
    static let normal = "normal"
}
