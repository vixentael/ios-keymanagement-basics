//
//  EncryptionEngine.swift
//  SecureTraining
//
//  Created by Anastasiia on 11/15/18.
//  Copyright © 2018 Cossack Labs. All rights reserved.
//

import Foundation

struct EncryptedData {
  let data: Data
  
  init(data: Data) {
    self.data = data
  }
  
  init?(base64String string: String) {
    guard let stringWithoutPercent = string.removingPercentEncoding else { return nil }
    
    guard let data = Data(base64Encoded: stringWithoutPercent,
                          options: .ignoreUnknownCharacters) else { return nil }
    
    self.data = data
  }
  
  var base64String: String {
    return data
      .base64EncodedString(options: .endLineWithLineFeed)
      .addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
  }
}


struct Key {
  let data: Data
  
  init(data: Data) {
    self.data = data
  }
  
  init?(string: String) {
    guard let data = string.data(using: .utf8) else { return nil }
    self.data = data
  }
  
  init?(base64String string: String) {
    guard let stringWithoutPercent = string.removingPercentEncoding else { return nil }
    
    guard let data = Data(base64Encoded: stringWithoutPercent,
                          options: .ignoreUnknownCharacters) else { return nil }
    
    self.data = data
  }
  
  var base64String: String {
    return data
      .base64EncodedString(options: .endLineWithLineFeed)
      .addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
  }
  
  var utf8String: String? {
    return String(data: data, encoding: .utf8)
  }
}

enum EncryptionError: Error {
  case cantCreateEncryptor
  
  case cantEncryptMessage
  case cantDecryptMessage
  case cantEncodeMessage
}

class EncryptionEngine {
  
  static let sharedInstance = EncryptionEngine()
  private init() {} //This prevents others from using the default '()' initializer for this class.
}
