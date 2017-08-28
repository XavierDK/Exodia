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
  
  init(generatorService: GeneratorServiceType)
  
  func newProject()
  func saveJSON(to url: String)
  func openJSON(to url: String)
  func generateFiles(to url: String)
  
  var currentModel: Variable<Model?> { get }
  var numberOfModels: Int { get }
  var models: [Model] { get }
  func newModel()
  func deleteModel() -> Observable<Void>
  func createModel(withID ID: String, andName name: String, isClass: Bool, hasRealm: Bool) -> Observable<Model>
  func updateModel(withID ID: String, andName name: String, isClass: Bool, hasRealm: Bool) -> Observable<Model>
  func selectModel(atIndex index: Int)
  
  var currentProperty: Variable<Property?> { get }
  var numberOfProperties: Int { get }
  var properties: [Property] { get }
  func newProperty()
  func deleteProperty() -> Observable<Void>
  func createProperty(withID ID: String, andName name: String, andType type: String, andKey key: String, andDefaultValue defaultValue: String?) -> Observable<Property>
  func updateProperty(withID ID: String, andName name: String, andType type: String, andKey key: String, andDefaultValue defaultValue: String?) -> Observable<Property>
  func selectProperty(atIndex index: Int)
  func clearProperty()
  
  var currentService: Variable<Service?> { get }
  var numberOfServices: Int { get }
  var services: [Service] { get }
  func newService()
  func deleteService() -> Observable<Void>
  func createService(withID ID: String, andName name: String) -> Observable<Service>
  func updateService(withID ID: String, andName name: String) -> Observable<Service>
  func selectService(atIndex index: Int)
}

struct ExodiaInteractor: ExodiaInteractorType {
  
  let generatorService: GeneratorServiceType
  
  let exodia = Variable<Exodia>(Exodia())
  
  let currentModel = Variable<Model?>(nil)
  let currentProperty = Variable<Property?>(nil)
  let currentService = Variable<Service?>(nil)
  
  init(generatorService: GeneratorServiceType) {
    
    self.generatorService = generatorService
  }
  
  func newProject() {
    
    currentModel.value = nil
    currentProperty.value = nil
    currentService.value = nil
    exodia.value = Exodia()
  }
  
  func openJSON(to url: String) {
    
    let file = try? Data(contentsOf: URL(string: url)!)
    
    if let file = file,
      let contents = String(data: file, encoding: .utf8),
      let exodia = Exodia(JSONString: contents){
      
      self.exodia.value = exodia
    }
  }
  
  func saveJSON(to url: String) {
    
    if let json = exodia.value.toJSONString() {
      try? json.data(using: .utf8)?.write(to: URL(string: url)!)
    }
  }
  
  func generateFiles(to url: String) {
    
    generatorService.generate(exodia: exodia.value, to: url)
  }
}

extension ExodiaInteractor {
  
  var numberOfModels: Int {
    return exodia.value.models.count
  }
  
  var models: [Model] {
    return exodia.value.models
  }
  
  func createModel(withID ID: String, andName name: String, isClass: Bool, hasRealm: Bool) -> Observable<Model> {
    
    return Observable.create({ observer in
      
      var model = Model()
      model.id = ID
      model.name = name
      model.isClass = isClass
      model.hasRealm = hasRealm
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
  
  func updateModel(withID ID: String, andName name: String, isClass: Bool, hasRealm: Bool) -> Observable<Model> {
    
    return Observable.create({ observer in
      
      var model = Model()
      model.id = ID
      model.name = name
      model.isClass = isClass
      model.hasRealm = hasRealm
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
  
  func createProperty(withID ID: String, andName name: String, andType type: String, andKey key: String, andDefaultValue defaultValue: String?) -> Observable<Property> {
    
    return Observable.create({ observer in
      
      var model = self.currentModel.value
      var property = Property()
      property.id = ID
      property.name = name
      property.type = type
      property.key = key
      property.defaultValue = defaultValue
      model?.properties.append(property)
      self.currentModel.value = model
      self.currentProperty.value = property
      
      observer.onNext(property)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func updateProperty(withID ID: String, andName name: String, andType type: String, andKey key: String, andDefaultValue defaultValue: String?) -> Observable<Property> {
    
    return Observable.create({ observer in
      
      var property = Property()
      property.id = ID
      property.name = name
      property.type = type
      property.key = key
      property.defaultValue = defaultValue
      
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

extension ExodiaInteractor {
  
  var numberOfServices: Int {
    return exodia.value.services.count
  }
  
  var services: [Service] {
    return exodia.value.services
  }
  
  func createService(withID ID: String, andName name: String) -> Observable<Service> {
    
    return Observable.create({ observer in
      
      var service = Service()
      service.id = ID
      service.name = name
      
      let exodia = self.exodia.value
      
      exodia.services.append(service)
      self.exodia.value = exodia
      self.currentService.value = service
      
      observer.onNext(service)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func updateService(withID ID: String, andName name: String) -> Observable<Service> {
    
    return Observable.create({ observer in
      
      var service = Service()
      service.id = ID
      service.name = name
      
      let exodia = self.exodia.value
      
      let index = exodia.services.index { $0.id == self.currentService.value?.id }
      
      if let index = index {
        exodia.services.remove(at: index)
        exodia.services.insert(service, at: index)
      }
      
      self.exodia.value = exodia
      self.currentService.value = service
      
      observer.onNext(service)
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
  
  func selectService(atIndex index: Int) {
    
    currentService.value = exodia.value.services[index]
  }
  
  func newService() {
    
    currentService.value = nil
  }
  
  func deleteService() -> Observable<Void> {
    
    return Observable.create({ observer in
      
      let exodia = self.exodia.value
      
      let index = exodia.services.index { $0.id == self.currentService.value?.id }
      
      if let index = index {
        exodia.services.remove(at: index)
      }
      
      self.exodia.value = exodia
      self.currentService.value = nil
      
      observer.onNext(())
      observer.onCompleted()
      
      return Disposables.create()
    })
  }
}

