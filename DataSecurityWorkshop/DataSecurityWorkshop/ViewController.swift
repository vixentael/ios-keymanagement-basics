//
//  ViewController.swift
//  DataSecurityWorkshop
//
//  Created by Anastasiia on 3/17/19.
//  Copyright © 2019 vixentael, Cossack Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let staticAPIToken = "iAmStaticAPIToken" // YouCanEasilyFindMe ;)

  var userEncryptionKey: String = ""

  let encryptionEngine = EncryptionEngine.sharedInstance

  @IBOutlet weak var askPasswordButton: UIButton?
  @IBOutlet weak var readPasswordButton: UIButton?
  @IBOutlet weak var readAPITokensButton: UIButton?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // if you want to see how encryption works
//    decryptTestMessage()
//    dataEncryptionExample()
  }

  @IBAction func askAndRememberUserPassword(sender: UIButton) {
    let alertController = UIAlertController(title: "Write your password, it's secure ;)", message: "", preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Password"
      textField.isSecureTextEntry = true
    }
    let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
      guard let alertController = alertController,
        let textField = alertController.textFields?.first,
        let pwd = textField.text else { return }
      
      self.encryptionEngine.saveEncryptionKeyToUserDefaults(key: Key(string: pwd)!)
      
      self.encryptionEngine.saveEncryptionKeyToKeychain(key: Key(string: pwd)!)
    }
    
    alertController.addAction(confirmAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func readUserPassword(sender: UIButton) {
    if let key = self.encryptionEngine.readEncryptionKeyFromUserDefaults(),
      let userPassword = key.utf8String {
      print("User password from User Defaults: " + userPassword)
    } else {
      print("Can't read user password from User Defaults :'(")
    }
    
    if let keyFromKeychain = self.encryptionEngine.readEncryptionKeyFromKeychain(),
      let userPasswordFromKeychain = keyFromKeychain.utf8String {
      print("User password from Keychain: " + userPasswordFromKeychain)
    } else {
      print("Can't read user password from Keychain :'(")
    }
  }
  
  // read API tokens from Info.plist
  @IBAction func readAPITokens(sender: UIButton) {
    let plaintextToken = self.encryptionEngine.readPlaintextKeyFromPlist()!
    print("Plaintext API token: " + plaintextToken.utf8String!)
    
    let obfuscatedToken = self.encryptionEngine.readObfuscatedKeyFromPlist()!
    print("Obfuscated API token: " + obfuscatedToken.utf8String!)
    
    let encryptedToken = self.encryptionEngine.readEncryptedKeyFromPlist()!
    print("Encrypted API token: " + encryptedToken.utf8String!)
  }

  // Try to decrypt some message
  func decryptTestMessage() {
    let key = Key(string:"rabbit")!
    
    let encryptedMessage = EncryptedData(base64String: "AAEBQAwAAAAQAAAADwAAAKoRAdjU2zv8qo6MSx1KMnM3VHy3whPthTE3rYuAn4%2FKCViHiMhx9DmNyJg%3D")
    var decryptedMessage = ""
    do {
      decryptedMessage = try self.encryptionEngine.decryptMessage(encryptedMessage: encryptedMessage!, secretKey: key)
    } catch {}
    
    print("You have decrypted message: " + decryptedMessage)
  }
  
  // ---------------- helpers ------------

  // if you want to update tokens in plist file, run and then copy to plist file
  private func generateAPITokens() {
    let tokenToObfuscate = "iAmObfuscatedToken"
    let obf = encryptionEngine.obfuscateAPIKey(fromString: tokenToObfuscate)!
    print("obfuscated: " + obf)

    let tokenToEncrypt = "iAmEncryptedToken"
    let encr = encryptionEngine.encryptAPIKey(fromString: tokenToEncrypt)!
    print("encrypted: " + encr)
  }


  func dataEncryptionExample() {
    let message = "Secret Message"
    let key = Key(string: "Secret key")!
    
    var encryptedMessage: EncryptedData? = nil
    do {
      encryptedMessage = try self.encryptionEngine.encryptMessage(message: message, secretKey: key)
    } catch {}
    print("Encrypted message (base64):\n" + encryptedMessage!.base64String)
    
    var decryptedMessage = ""
    do {
      decryptedMessage = try self.encryptionEngine.decryptMessage(encryptedMessage: encryptedMessage!, secretKey: key)
    } catch {}
    print("Decrypted message: " + decryptedMessage)
  }

}

