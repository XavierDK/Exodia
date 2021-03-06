//
//  Property.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import ObjectMapper

struct Property: Mappable {
  
  var id: String?
  var name: String?
  var type: String?
  var key: String?
  var defaultValue: String?
  
  init() {
  
  }
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    
    id            <- map["id"]
    name          <- map["name"]
    type          <- map["type"]
    key           <- map["key"]
    defaultValue  <- map["defaultValue"]    
  }
}
