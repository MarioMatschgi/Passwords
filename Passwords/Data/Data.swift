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
    
    // MARK: init
    /// Creates a Model with no initial data
    init() {
        self.vaultData = VaultData()
    }
    
    // MARK: init
    /// Creates a Model with the given data
    /// - Parameters:
    ///     - vaultData: VaultData: The initial data for the Model
    init(vaultData: VaultData) {
        self.vaultData = vaultData
    }
    
    
    // MARK: setKeychain
    /// Sets a keychain in the vault, if one with the name exists it will get changed, if none with the name exists it will get added
    /// - Parameters:
    ///     - keychain: KeychainData: Data for the keychain
    func setKeychain(keychain: KeychainData) {
        vaultData.setKeychain(keychain: keychain)
    }
    
    // MARK: setPassword
    /// Sets a password in the Keychain, if one with the displayname exists it will get changed, if none with the displayname exists it will get added
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    /// - Returns: Bool: Wether the adding was successful
    func setPassword(data: PasswordData) -> Bool {
        let oldData = vaultData.getPassword(forID: data.id)
        
        // Add password to app Keychain
        let res = vaultData.setPassword(data: data)
        if !res { return false }
        
        // Add password to user Keychain
        // ToDo:
        manager!.setPasswordInKeychain(oldData: oldData, newData: data)
        
        return true
    }
    
    // MARK: removePassword
    /// Removes a password from the Keychain
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    func removePassword(data: PasswordData) {
        // Remove password from app Keychain
        vaultData.removePassword(data: data)
        
        // Remove password from user Keychain
        // ToDo:
        manager!.removePasswordFromKeychain(data: data)
    }
}

// MARK: - VAULT-DATA
/// VauldData: Stores all data
struct VaultData: Codable {
    /// Dictionary with the name of keychain as key and KeychainData as value
    private var keychains: [String: KeychainData]
    /// Array containing all passwords in the keychain
    private var passwords: [PasswordData]
    
    // MARK: init
    /// Creates an empty VaultData
    init() {
        keychains = [:]
        passwords = []
    }
    
    // MARK: init
    /// Creates a VaultData from a JSON String
    init(json: String) {
        self.init()
        
        // Decode JSON
        let decoder = JSONDecoder()
        do {
            let vaultData = try decoder.decode([String: KeychainData].self, from: Data(json.utf8))
            self.keychains = vaultData
        } catch { print(error.localizedDescription) }
        
        // Fill all passwords array
        generateAllPasswords()
    }
    
    // MARK: toJSON
    /// Converts the VaultData to a JSON string
    /// - Returns: String: The VaultData as a JSON String
    func toJSON() -> String {
        do {
            let jsonData = try JSONEncoder().encode(keychains)
            return String(data: jsonData, encoding: .utf8)!
        } catch { print(error) }
        
        return ""
    }
    
    // MARK: generateAllPasswords
    /// Generates all passwords in the vault and fills them into the all passwords array
    private mutating func generateAllPasswords() {
        passwords = []
        for k_element in keychains {
            for p_element in k_element.value.passwords {
                passwords.append(p_element)
            }
        }
    }
    
    // MARK: getKeychains
    /// Gets the keychains Dictionary
    /// - Returns: Dictionary: Keychains Dictionary
    func getKeychains() -> [String: KeychainData] {
        return keychains
    }
    
    // MARK: getPasswords
    /// Gets the passwords for the given keychain. If the keychain is empty it will get all passwords
    /// - Parameters:
    ///     - keychain: The keychain for which the passwords should be returned
    /// - Returns: Array: An Array with all of the passwords for the given keychain
    func getPasswords(for keychain: String) -> [PasswordData] {
        if keychain == "" {
            return passwords
        }
        
        return keychains[keychain] == nil ? [] : keychains[keychain]!.passwords
    }
    
    func getPassword(forID uuid: UUID) -> PasswordData? {
        if let idx = passwords.firstIndex(where: { $0.id == uuid }) {
            // Password exists
            return passwords[idx]
        }
        
        return nil
    }
    
    // MARK: getAllPasswords
    /// Gets all passwords of the vault
    /// - Returns: Array: An Array with all of the passwords of the vault
    func getAllPasswords() -> [PasswordData] {
        return getPasswords(for: "")
    }
    
    // MARK: setKeychain
    /// Sets a keychain, if one with the name exists it will get changed, if none with the name exists it will get added
    /// - Parameters:
    ///     - keychain: KeychainData: Data for the keychain
    mutating func setKeychain(keychain: KeychainData) {
        if keychains[keychain.name] == nil {
            keychains[keychain.name] = keychain
        }
        
        // Save to Keychain
        manager!.saveRegisterData(data: self)
    }
    
    // MARK: removeKeychain
    /// Removes a keychain from the vault
    /// - Parameters:
    ///     - data: KeychainData: Data for the keychain
    mutating func removeKeychain(keychain: KeychainData) {
        keychains[keychain.name] = nil
    }
    
    // MARK: setPassword
    /// Sets a password in the vault, if one with the displayname exists it will get changed, if none with the displayname exists it will get added
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    /// - Returns: Bool: Wether the operation was successful
    mutating func setPassword(data: PasswordData) -> Bool {
        // Add/set to/in passwords
        if let idx = passwords.firstIndex(where: { $0.equalsID(equals: data) }) {
            // Check if keychain changed, if so, remove old from keychains arr
            if passwords[idx].keychain != data.keychain {
                removePassword(data: passwords[idx])
                passwords.append(data)  // Password not there, add
            } else {
                passwords[idx] = data   // Password in there, replace
            }
        } else {
            passwords.append(data)  // Password not there, add
        }
        
        // Add/set to/in keychains
        if keychains[data.keychain] == nil {
            // Keychain does not exist, add new keychain with password
            keychains[data.keychain] = KeychainData(name: data.keychain, passwords: [data])
        }
        else {
            // Keychain exists, add to the keychain
            if let idx = keychains[data.keychain]!.passwords.firstIndex(where: { $0.equalsID(equals: data) }) {
                // Password exists, update
                keychains[data.keychain]!.passwords[idx] = data
            } else {
                // Add password to vault
                keychains[data.keychain]!.passwords.append(data)
            }
        }
        
        // Save to Keychain
        manager!.saveRegisterData(data: self)
        
        return true
    }
    
    // MARK: removePassword
    /// Removes a password from the vault
    /// - Parameters:
    ///     - data: PasswordData: Data for the password
    mutating func removePassword(data: PasswordData) {
        // Remove from passwords
        if let idx = passwords.firstIndex(where: { $0.equalsID(equals: data) }) {
            passwords.remove(at: idx)
        }
        
        // Remove from keychains
        if keychains[data.keychain] != nil, let idx = keychains[data.keychain]!.passwords.firstIndex(where: { $0.equalsID(equals: data) }) {
            keychains[data.keychain]!.passwords.remove(at: idx)
            /* DONT
            if keychains[data.keychain]!.passwords.count <= 0 { // Remove keychain if empty
                keychains[data.keychain] = nil
            }
             */
        }
        
        // Update Keychain
        manager!.saveRegisterData(data: self)
    }
}

// MARK: - KEYCHAIN-DATA
/// KeychainData: Stores data for a keychain
struct KeychainData: Codable {
    /// The name of the keychain
    var name: String
    /// Array containing PasswordData for all passwords in this keychain
    var passwords: [PasswordData]
    
    func isValid() -> Bool {
        return name.trimmingCharacters(in: .whitespacesAndNewlines) != ""
    }
}

// MARK: - PASSWORD-DATA
/// PasswordData: Stores data for a password
struct PasswordData: Codable, Identifiable {
    /// The unique identifier of the password
    var id: UUID = UUID()
    
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
    
    /// The password for the confirmation field
    var passwordConfirm: String = ""
    
    /// The description of the password
    var description: String
    
    /// The type describing what to autofill
    var autofill: AutofillType
    
    /// The username of the password
    var keychain: String
    
    // MARK: isValid
    /// Validates the password, checks if all fields are set
    /// - Returns: Bool: Whether the all fields are set
    func isValid() -> Bool {
        return password == passwordConfirm && displayname != "" && username != "" && (autofill == .email ? email != "" : (autofill == .username ? username != "" : false) ) && password != "" && autofill != .none
    }
    
    // MARK: equalsID
    /// Are the PasswordDatas UUIDs equal?
    /// - Returns: Bool: Whether the PasswordDatas UUIDs are equal
    func equalsID(equals data: PasswordData) -> Bool {
        return id == data.id
    }
    
    // MARK: getAutofill
    /// Gets the property that will get autofilled
    /// - Returns: String: The field that should be autofilled
    func getAutofill() -> String {
        if autofill == .email {
            return email
        } else if autofill == .username {
            return username
        }
        
        return ""
    }
    
    // MARK: CodingKeys
    /// List of values that should be encoded in JSON
    enum CodingKeys: String, CodingKey {
        case displayname, username, email, website, password, description, autofill, keychain
    }
}

// MARK: - AUTOFILL-TYPE
/// AutofillType: Type describing what to autofill
enum AutofillType: String, Codable {
    case none = ""
    case username
    case email
}
