//
//  EncryptionEngine+APIkeys.swift
//  DataSecurityWorkshop
//
//  Created by Anastasiia on 3/17/19.
//  Copyright © 2019 vixentael, Cossack Labs. All rights reserved.
//

import Foundation
import themis


// MARK: - API keys
extension EncryptionEngine {
  
  static let InfoPlistName = "Info"
  static let plaintextAPITokenKey = "SECRET_API_TOKEN"
  static let encryptedAPITokenKey = "ENCRYPTED_API_TOKEN"
  static let obfuscatedAPITokenKey = "OBFUSCATED_API_TOKEN"
  
  // -------------- plist ---------------
  
  func readPlaintextKeyFromPlist() -> Key? {
    let plaintextString = Bundle().getString(inPlist: EncryptionEngine.InfoPlistName, for: EncryptionEngine.plaintextAPITokenKey)
    return Key(string: plaintextString)
  }
  
  func readEncryptedKeyFromPlist() -> Key? {
    // read base64
    let base64FromPlist = Bundle().getString(inPlist: EncryptionEngine.InfoPlistName, for: EncryptionEngine.encryptedAPITokenKey)
    
    // transform base64 string into Data
    guard let dataFromPlist = EncryptedData.init(base64String: base64FromPlist) else {
      return nil
    }
    
    // generate decryption key
    let decryptionKey = generateTempKey()
    do {
      // decrypt key from plist
      let decryptedStringFromPlist = try decryptMessage(encryptedMessage: dataFromPlist, secretKey: decryptionKey)
      return Key(string: decryptedStringFromPlist)
    } catch {}
    
    return nil
  }
  
  func readObfuscatedKeyFromPlist() -> Key? {
    let obfuscatedFromPlist = Bundle().getString(inPlist: EncryptionEngine.InfoPlistName, for: EncryptionEngine.obfuscatedAPITokenKey)
    
    // decode from base64 to EncryptedData
    guard let dataFromPlist = EncryptedData.init(base64String: obfuscatedFromPlist) else {
      return nil
    }
    // EncryptedData -> [UInt8]
    let byteArray = [UInt8](dataFromPlist.data)
    
    // deobfuscate
    let obfuscator = Obfuscator()
    let deobfuscatedString = obfuscator.reveal(key: byteArray)
    
    return Key(string: deobfuscatedString)
  }
  
  // ----------- Helpers ---------------
  
  // return base64
  func encryptAPIKey(fromString: String) -> String? {
    // generate encryption key
    let encryptionKey = generateTempKey()
    do {
      // encrypt string into EncryptedData
      let encryptedKey = try encryptMessage(message: fromString, secretKey: encryptionKey)
      return encryptedKey.base64String
    } catch {}
    
    return nil
  }
  
  func obfuscateAPIKey(fromString: String) -> String? {
    let obfuscator = Obfuscator()
    let obfuscatedArray: [UInt8] = obfuscator.bytesByObfuscatingString(string: fromString)
    let obfuscatedData = Data(bytes: obfuscatedArray, count: obfuscatedArray.count)
    let key = Key(data: obfuscatedData).base64String
    return key
  }
  
  private func generateTempKey() -> Key {
    var key = "some "
    key += String(115)
    key += String(101)
    key += String(99)
    key += String(114)
    key += String(101)
    key += String(116)
    return Key(string: key)!
  }
}
