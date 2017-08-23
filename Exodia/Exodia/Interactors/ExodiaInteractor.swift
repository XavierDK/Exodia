//
//  ExodiaInteractor.swift
//  Exodia
//
//  Created by Xavier De Koninck on 23/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift

protocol ExodiaInteractorType {
  
  var exodia: Variable<Exodia> { get }
  
  init(configFileService: ConfigFileServiceType)
  
  func generateJSON() -> String?
  
  var currentModel: Variable<Model?> { get }
  var numberOfModels: Int { get }
  var models: [Model] { get }
  func newModel()
  func deleteModel() -> Observable<Void>
  func createModel(withID ID: String, andName name: String) -> Observable<Model>
  func updateModel(withID ID: String, andName name: String) -> Observable<Model>
  func selectModel(atIndex index: Int)
  
  var currentProperty: Variable<Property?> { get }
  var numberOfProperties: Int { get }
  var properties: [Property] { get }
  func newProperty()
  func deleteProperty() -> Observable<Void>
  func createProperty(withID ID: String, andName name: String) -> Observable<Property>
  func updateProperty(withID ID: String, andName name: String) -> Observable<Property>
  func selectProperty(atIndex index: Int)
  func clearProperty()
}

struct ExodiaInteractor: ExodiaInteractorType {
  
  let configFileService: ConfigFileServiceType
  
  let exodia = Variable<Exodia>(Exodia())
  
  let currentModel = Variable<Model?>(nil)
  let currentProperty = Variable<Property?>(nil)
  
  init(configFileService: ConfigFileServiceType) {
    
    self.configFileService = configFileService
  }
  
  func generateJSON() -> String? {
    return exodia.value.toJSONString()
  }
}

extension ExodiaInteractor {
  
  var numberOfModels: Int {
    return exodia.value.models.count
  }
  
  var models: [Model] {
    return exodia.value.models
  }
  
  func createModel(withID ID: String, andName name: String) -> Observable<Model> {
    
    return Observable.create({ observer in
      
      var model = Model()
      model.id = ID
      model.name = name
      model.properties = self.currentModel.value?.properties ?? []
      
      let exodia = self.exodia.value
      
      exodia.models.append(model)
      self.exodia.value = exodia
      self.currentModel.value = model
      
      observer.onNext(model)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func updateModel(withID ID: String, andName name: String) -> Observable<Model> {
    
    return Observable.create({ observer in
      
      var model = Model()
      model.id = ID
      model.name = name
      model.properties = self.currentModel.value?.properties ?? []
      
      let exodia = self.exodia.value
      
      let index = exodia.models.index { $0.id == self.currentModel.value?.id }
      
      if let index = index {
        exodia.models.remove(at: index)
        exodia.models.insert(model, at: index)
      }
      
      self.exodia.value = exodia
      self.currentModel.value = model
      
      observer.onNext(model)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func selectModel(atIndex index: Int) {
    
    currentModel.value = exodia.value.models[index]
  }
  
  func newModel() {
    
    currentModel.value = nil
  }
  
  func deleteModel() -> Observable<Void> {
   
    return Observable.create({ observer in
      
      let exodia = self.exodia.value
      
      let index = exodia.models.index { $0.id == self.currentModel.value?.id }
      
      if let index = index {
        exodia.models.remove(at: index)
      }
      
      self.exodia.value = exodia
      self.currentModel.value = nil
      
      observer.onNext(())
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
}

extension ExodiaInteractor {
  
  var numberOfProperties: Int {
    return currentModel.value?.properties.count ?? 0
  }
  
  var properties: [Property] {
    return currentModel.value?.properties ?? []
  }
  
  func createProperty(withID ID: String, andName name: String) -> Observable<Property> {
    
    return Observable.create({ observer in
      
      var model = self.currentModel.value
      var property = Property()
      property.id = ID
      property.name = name
      model?.properties.append(property)
      self.currentModel.value = model
      self.currentProperty.value = property
      
      observer.onNext(property)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func updateProperty(withID ID: String, andName name: String) -> Observable<Property> {
    
    return Observable.create({ observer in
      
      var property = Property()
      property.id = ID
      property.name = name
      
      let index = self.currentModel.value?.properties.index { $0.id == self.currentProperty.value?.id }
      
      if let index = index {
        self.currentModel.value?.properties.remove(at: index)
        self.currentModel.value?.properties.insert(property, at: index)
      }
      
      self.currentProperty.value = property
      
      observer.onNext(property)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func selectProperty(atIndex index: Int) {
    
    currentProperty.value = currentModel.value?.properties[index]
  }
  
  func newProperty() {
    
    currentProperty.value = nil
  }
  
  func deleteProperty() -> Observable<Void> {
    
    return Observable.create({ observer in
      
      var model = self.currentModel.value
      let index = model?.properties.index { $0.id == self.currentProperty.value?.id }
      
      if let index = index {
        model?.properties.remove(at: index)
      }
      
      self.currentProperty.value = nil
      self.currentModel.value = model
      
      observer.onNext(())
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func clearProperty() {
    self.currentProperty.value = nil
  }
}
