//
//  EncryptionEngine+ProtectData.swift
//  SecureTraining
//
//  Created by Anastasiia on 11/15/18.
//  Copyright © 2018 Cossack Labs. All rights reserved.
//

import Foundation
import themis

// MARK: - Encrypt/Decrypt Data
extension EncryptionEngine {
  
  func encryptMessage(message: String, secretKey: Key) throws -> EncryptedData {
    
    // 1. create encryptor SecureCell with own secret key
    guard let cellSeal = TSCellSeal(key: secretKey.data) else {
      print("Failed to encrypt message: error occurred while initializing object cellSeal")
      throw EncryptionError.cantCreateEncryptor
    }
    
    // 2. encrypt data
    let encryptedMessage: Data
    do {
      encryptedMessage = try cellSeal.wrap(message.data(using: .utf8)!,
                                           context: nil)
      
    } catch let error as NSError {
      print("Failed to encrypt post: error occurred while encrypting message \(error)")
      throw EncryptionError.cantEncryptMessage
    }
    return EncryptedData(data: encryptedMessage)
  }
  
  func decryptMessage(encryptedMessage: EncryptedData, secretKey: Key) throws -> String {
    
    // 1. create decryptor with own secret key
    guard let cellSeal = TSCellSeal(key: secretKey.data) else {
      print("Failed to decrypt message: error occurred while initializing object cellSeal")
      throw EncryptionError.cantCreateEncryptor
    }
    
    // 2. decrypt encryptedMessage
    var decryptedMessage: Data = Data()
    do {
      decryptedMessage = try cellSeal.unwrapData(encryptedMessage.data,
                                                 context: nil)
    } catch let error as NSError {
      print("Failed to decrypt message: error occurred while decrypting: \(error)")
      throw EncryptionError.cantDecryptMessage
    }
    
    // 3. encode decrypted message from Data to String
    guard let decryptedBody = String(data: decryptedMessage, encoding: .utf8) else {
      print("Failed to decrypt message: error occurred while encoding decrypted post body")
      throw EncryptionError.cantEncodeMessage
    }
    return decryptedBody
  }
}
