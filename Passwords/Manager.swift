//
//  Manager.swift
//  Passwords
//
//  Created by Mario Elsnig on 04.02.21.
//

import Foundation
import KeychainAccess
//import KeychainSwift

var manager: Manager?
class Manager {
    let debug = true
    
    let keychainAccessGroup = "at.programario.Passwords"
    let key_data = "data"
    let key_normalPW = "normal-passwords"
    let appKeychain: Keychain
    
    var registerData: RegisterVaultData = RegisterVaultData()
    
    init() {
        appKeychain = Keychain(accessGroup: keychainAccessGroup)
        
        Setup()
    }
    
    func Setup() {
        print("Setting up Manager...")
        
        if !IsInPreview() {
            SetupPasswords()
        }
        
        print("Finished setting up Manager!")
    }
    
    func SetupPasswords() {
        
//        SaveRegisterData(data: RegisterVaultData()) // USE TO RESET REGISTER DATA
        registerData = LoadRegisterData()
        dump(registerData)
        
//        let keychain = Keychain(server: "https://github.com", protocolType: .https, authenticationType: .htmlForm)//.synchronizable(true)
        
//        keychain["testpassword321"] = nil//"123456"
//        keychain["testpassword"] = nil
        
//        dump(keychain.allItems())
    }
    
    func LoadRegisterData() -> RegisterVaultData {
//        let keychain = Keychain(accessGroup: keychainAccessGroup)
        if !appKeychain.allKeys().contains(key_data) || appKeychain[key_data] == nil {
            appKeychain[key_data] = RegisterVaultData(passwords: []).ToJSON()
        }
        print("A: \(appKeychain[key_data]!)")
        return RegisterVaultData(json: appKeychain[key_data]!)
    }
    func SaveRegisterData(data: RegisterVaultData) {
//        let keychain = Keychain(accessGroup: keychainAccessGroup)
        appKeychain[key_data] = data.ToJSON()
    }
    func GetVault() -> [String: KeychainData] {
        var vault: [String: KeychainData] = [:]
        
        for pwData in registerData.passwords {
            if vault[pwData.keychain] == nil {  // If vault does not contain keychain with current pw add new keychain
                vault[pwData.keychain] = KeychainData(name: pwData.keychain, passwords: [GetPassword(pwData: pwData)])
            } else {    // Vault contains keychain, add pw to the keychain
                vault[pwData.keychain]!.passwords.append(GetPassword(pwData: pwData))
            }
        }
        
        print("VAULT:")
        dump(vault)
        
        return vault
    }
    func GetPassword(pwData: RegisterPasswordData) -> PasswordData {
        GetPassword(name: pwData.name, type: pwData.type, url: pwData.url)
    }
    func GetPassword(name: String, type: String, url: String) -> PasswordData {
        var pw = ""
        if type == PasswordType.web {   // PW is webpassword
            let tmp = Keychain(server: url, protocolType: .https)[name]
            if tmp != nil {
                pw = tmp!
            }
        } else if type == PasswordType.normal { // PW is normal
            let tmp = appKeychain["\(key_normalPW).\(url)"]
            if tmp != nil {
                pw = tmp!
            }
        }
        
        return PasswordData(name: name, url: url, type: type, password: pw)
    }
    
    func AddPassword(data: PasswordData, keychain: String) {
        // Add to register
        registerData.passwords.append(RegisterPasswordData(name: data.name, url: data.url, type: data.type, keychain: keychain))
        SaveRegisterData(data: registerData)
        
        // Add to Keychain
        if data.type == PasswordType.web {   // PW is webpassword
            Keychain(server: data.url, protocolType: .https)[data.name] = data.password
        } else if data.type == PasswordType.normal { // PW is normal
            appKeychain["\(key_normalPW).\(data.url)"] = data.password
        }
        
        // Add to vault
        mainView!.vaultData.AddPassword(data: data, keychain: keychain)
    }
    
//    func ChangePassword() {
//        let keyChain = GetKeyChain()
//    }
//    func AddPassword(server: URL, ) {
//        let keyChain = Keychain(server: url, protocolType: .https).synchronizable(true)
//        keyChain
//    }
//    func AddPassword(name: String) {
//        let keyChain = GetKeyChain()
//    }
//    func RemovePassword() {
//        let keyChain = GetKeyChain()
//    }
//    func GetKeyChain() -> Keychain {
//        return Keychain(server: "https://github.com", protocolType: .https).synchronizable(true)
//    }
}
