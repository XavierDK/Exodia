//
//  Model.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import ObjectMapper

struct Model: Mappable {
  
  var id: String?
  var name: String?
  var properties: [Property] = []
  var isClass: Bool = false
  var hasRealm: Bool = false
  
  init() {}
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    
    id          <- map["id"]
    name        <- map["name"]
    properties  <- map["properties"]
    isClass     <- map["isClass"]
    hasRealm    <- map["hasRealm"]
  }
}
