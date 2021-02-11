//
//  Manager.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import Foundation
import KeychainAccess

/// Instance of the Manager class
var manager: Manager?

// MARK: - MANAGER
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
    
    // MARK: init
    /// Creates a Manager instance
    init() {
        appKeychain = Keychain(accessGroup: keychainAccessGroup)
        
        manager = self
        
        setup()
    }
    
    // MARK: setup
    /// Setup for the Manager
    func setup() {
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
    
    // MARK: loadRegisterData
    /// Loads the vault data from the Keychain
    /// - Returns: RegisterVaultData: Loaded from the Keychain
    func loadRegisterData() -> VaultData {
        if !appKeychain.allKeys().contains(key_data) || appKeychain[key_data] == nil {
            appKeychain[key_data] = VaultData().toJSON()
        }
        return VaultData(json: appKeychain[key_data]!)
    }
    
    // MARK: saveRegisterData
    /// Saves the vault data to the Keychain
    /// - Parameters:
    ///     - data: RegisterVaultData to save to the Keychain
    func saveRegisterData(data: VaultData) {
        dump(data)
        appKeychain[key_data] = data.toJSON()
    }
}
