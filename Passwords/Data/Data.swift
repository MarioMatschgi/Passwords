//
//  Data.swift
//  Passwords
//
//  Created by Mario Elsnig on 05.02.21.
//

import Foundation

// MARK: - MODEL
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
    
    /// Sets a password in the Keychain, if one with the displayname exists it will get changed, if none with the displayname exists it will get added
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    /// - Returns: Bool: Wether the adding was successful
    func setPassword(data: PasswordData) -> Bool {
        // Add password to app Keychain
        let res = vaultData.setPassword(data: data)
        if !res { return false }
        
        // Add password to user Keychain
        // ToDo:
        
        return true
    }
}

// MARK: - VAULT-DATA
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
        
        // Save to Keychain
        manager!.SaveRegisterData(data: self)
        
        return true
    }
}

// MARK: - KEYCHAIN-DATA
/// KeychainData: Stores data for a keychain
struct KeychainData: Codable {
    /// The name of the keychain
    var name: String
    /// Array containing PasswordData for all passwords in this keychain
    var passwords: [PasswordData]
}

// MARK: - PASSWORD-DATA
/// PasswordData: Stores data for a password
struct PasswordData: Codable {
    /// The display name for the password
    var displayname: String
    
    /// The username of the password
    var username: String
    
    /// The email of the password
    var email: String
    
    /// The website for the password
    var website: String
    
    /// The actual password for the password
    var password: String
    
    /// The description of the password
    var description: String
    
    /// The type describing what to autofill
    var autofill: AutofillType
    
    /// The username of the password
    var keychain: String
}

// MARK: - AUTOFILL-TYPE
/// AutofillType: Type describing what to autofill
enum AutofillType: String, Codable {
    case none = ""
    case username
    case email
}
