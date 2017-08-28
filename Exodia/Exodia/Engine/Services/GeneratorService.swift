//
//  ConfigFileService.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import PathKit
import Stencil

protocol GeneratorServiceType {
  
  func generate(exodia: Exodia, to url: String)
}

struct GeneratorService: GeneratorServiceType {
  
  func generate(exodia: Exodia, to url: String) {
    
    let path = Path(#file) + "../../.." + "Engine/Templates/Models"
    
    let environment = Environment(loader: FileSystemLoader(paths: [path]))
    
    createDirectory(at: url)
    generateModels(models: exodia.models, forEnvironment: environment, andURL: url)    
  }
  
  private func generateModels(models: [Model], forEnvironment environment: Environment, andURL url: String) {
    
    guard models.count > 0 else { return }
    
    let modelsURL = url + "/Models"
    createDirectory(at: modelsURL)
    
    for model in models {
      
      let context = ["model": model]
      
      var name = (model.isClass) ? ("ClassModel.swift"): ("StructModel.swift")
      
      if model.hasRealm {
        name = "RealmModel.swift"
      }
      
      let rendered = try? environment.renderTemplate(name: name, context: context)
      
      if let rendered = rendered {
        try? rendered.data(using: .utf8)?.write(to: URL(string: modelsURL + "/\(model.name!).swift")!)
      }
    }
  }
}

extension GeneratorService {
  
  func createDirectory(at path: String) {
    
    do {
      try FileManager.default.createDirectory(atPath: path.replacingOccurrences(of: "file://", with: ""), withIntermediateDirectories: false, attributes: nil)
    } catch let error as NSError {
      print(error.localizedDescription);
    }
  }
}
