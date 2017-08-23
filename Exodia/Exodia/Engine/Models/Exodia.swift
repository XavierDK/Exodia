//
//  Exodia.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import ObjectMapper

class Exodia: Mappable {
  
  var models: [Model] = []
  
  init() {
    
  }

  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    
    models <- map["models"]
  }
}
