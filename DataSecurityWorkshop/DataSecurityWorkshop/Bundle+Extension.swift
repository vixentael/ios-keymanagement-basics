//
//  Bundle+Extension.swift
//  DataSecurityWorkshop
//
//  Created by Anastasiia on 3/17/19.
//  Copyright © 2019 vixentael, Cossack Labs. All rights reserved.
//

import Foundation

extension Bundle {
  
  func getString(inPlist name: String, for key: String) -> String {
    guard let plistPath = Bundle.main.url(forResource: name, withExtension: "plist"),
      let data = try? Data(contentsOf: plistPath) else { fatalError() }
    guard let plistDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else  { fatalError() }
    guard let stringFromDictionary = plistDictionary?[key] as? String else { fatalError() }
    return stringFromDictionary
  }
}
