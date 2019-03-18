//
//  EncryptionEngine+UserKeys.swift
//  DataSecurityWorkshop
//
//  Created by Anastasiia on 3/17/19.
//  Copyright © 2019 vixentael, Cossack Labs. All rights reserved.
//

import Foundation
import Valet

// MARK: - Save keys
extension EncryptionEngine {
  
  // --------------- valet ------------
  
  static let valetID = "datasecurityworkshop"
  static let valetKeyID = "encryptionkey"
  
  func saveEncryptionKeyToKeychain(key: Key) {
    let myValet = Valet.valet(with: Identifier(nonEmpty: EncryptionEngine.valetID)!, accessibility: .whenUnlocked)
    myValet.set(object: key.data, forKey: EncryptionEngine.valetKeyID)
    
    // TODO: remember in UserDefaults that application has set key in Keychain
    
    // remember in User Defaults
    rememberAppHasRun()
  }
  
  func readEncryptionKeyFromKeychain() -> Key? {
    let myValet = Valet.valet(with: Identifier(nonEmpty: EncryptionEngine.valetID)!, accessibility: .whenUnlocked)
    if let readObject = myValet.object(forKey: EncryptionEngine.valetKeyID) {
      
      // TODO: check that application is running first time, then key is can be left from previous installation, ignore it
      
      // if first run, then key is left from previous installation, should remove
      if (isAppFirstRun()) {
        print("The Keychain is stored from previous app launch, do not read key")
        return nil
      }
      
      return Key(data: readObject)
    }
    return nil
  }
  
  // --------------- user defaults ------------
  
  static let userDefaultsAppHasRunKey = "appHasRunBefore"
  static let userDefaultsEncryptionKeyKey = "encryptionKey"
  
  private func rememberAppHasRun() {
    UserDefaults.standard.set(true, forKey: EncryptionEngine.userDefaultsAppHasRunKey)
  }
  
  private func isAppFirstRun() -> Bool {
    let hasRunBefore = UserDefaults.standard.bool(forKey: EncryptionEngine.userDefaultsAppHasRunKey)
    return !hasRunBefore
  }
  
  func saveEncryptionKeyToUserDefaults(key: Key) {
    UserDefaults.standard.set(key.data, forKey: EncryptionEngine.userDefaultsEncryptionKeyKey)
  }
  
  func readEncryptionKeyFromUserDefaults() -> Key? {
    if let value = UserDefaults.standard.data(forKey: EncryptionEngine.userDefaultsEncryptionKeyKey) {
      return Key(data: value)
    }
    return nil
  }
  
  // -------------- memory --------------

  // In this example we use Themis, which has built-in KDF function, so we can use simple keys
  // However, without Themis you should generate strong cryptographic keys
  // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave
  // If you use RNCryptor or CryptoSwift – it's up to you to handle KDF, IV, salt
  //  https://swifting.io/blog/2017/01/16/33-security-implement-your-own-encryption-schema/
  // If you are not a cryptographer – use "boring" libraries, like Themis, or libsodium
  //  https://github.com/cossacklabs/themis
  //  https://github.com/jedisct1/swift-sodium
  private func generateUserEncryptionKey() -> Key {
    let res = 23.0 / 8.5 // 2.705882353
    let divisionRes = String(format: "%.5f", res)
    let key = "k" + divisionRes + "Be73"
    return Key(string: key)!
  }
}
