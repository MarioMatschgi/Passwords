//
//  Manager.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import Foundation
import KeychainAccess

// MARK: - MANAGER
/// Instance of the Manager class
var manager: Manager?

/// Manager: Class for managing general things
class Manager {
    /// Debug mode 
    let debugMode = true
    
    /// The Keychain AccessGroup for the app
    let keychainAccessGroup = "at.programario.Passwords"
    /// The key for the data entry for the Keychain
    let key_data = "data"
    /// The app-Keychain
    let appKeychain: Keychain
    
    /// Creates a Manager instance
    init() {
        appKeychain = Keychain(accessGroup: keychainAccessGroup)
        
        manager = self
        
        Setup()
    }
    
    /// Setup for the Manager
    func Setup() {
        print("Setting up Manager...")
        
        print("Finished setting up Manager!")
    }

    /*
    func SetupPasswords() {
//        SaveRegisterData(data: RegisterVaultData()) // USE TO RESET REGISTER DATA
//        registerData = LoadRegisterData()
//        dump(registerData)
        
//        let keychain = Keychain(server: "https://github.com", protocolType: .https, authenticationType: .htmlForm)//.synchronizable(true)
        
//        keychain["testpassword321"] = nil//"123456"
//        keychain["testpassword"] = nil
        
//        dump(keychain.allItems())
    }
 */
    
    /// Loads the vault data from the Keychain
    /// - Returns: RegisterVaultData: Loaded from the Keychain
    func LoadRegisterData() -> VaultData {
        if !appKeychain.allKeys().contains(key_data) || appKeychain[key_data] == nil {
            appKeychain[key_data] = VaultData().ToJSON()
        }
        return VaultData(json: appKeychain[key_data]!)
    }
    /// Saves the vault data to the Keychain
    /// - Parameters:
    ///     - data: RegisterVaultData to save to the Keychain
    func SaveRegisterData(data: VaultData) {
        dump(data)
        appKeychain[key_data] = data.ToJSON()
    }
}
