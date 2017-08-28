//
//  Service.swift
//  Exodia
//
//  Created by Xavier De Koninck on 28/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import ObjectMapper

struct Service: Mappable {
  
  var id: String?
  var name: String?
  
  init() {}
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    
    id          <- map["id"]
    name        <- map["name"]
  }
}
