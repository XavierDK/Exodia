//
//  ModelFormViewModel.swift
//  Exodia
//
//  Created by Xavier De Koninck on 23/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol ModelFormViewModelType {
  
  // INPUTS
  var id: BehaviorSubject<String> { get }
  var name: BehaviorSubject<String> { get }
  var hasRealm: BehaviorSubject<Bool> { get }
  var isClass: BehaviorSubject<Bool> { get }
  
  // OUTPUTS
  var data: Observable<(String, String, Bool, Bool)> { get }
  var saveEnabled: Driver<Bool> { get }
  var deleteEnabled: Driver<Bool> { get }
  
  // ACTIONS
  var saveModelAction: Action<(String, String, Bool, Bool), Model> { get }
  var newModelAction: CocoaAction { get }
  var deleteModelAction: CocoaAction { get }
  
  // PROPERTIES
  var reloadData: Observable<Void> { get }
  var numberOfProperties: Int { get }
  var properties: [Property] { get }
  func selectProperty(atIndex: Int)
  func clearProperty()
  
  init(exodiaInteractor: ExodiaInteractorType)
}

struct ModelFormViewModel: ModelFormViewModelType {
  
  var exodiaInteractor: ExodiaInteractorType
  
  let disposeBag = DisposeBag()
  
  var id = BehaviorSubject<String>(value: "")
  var name = BehaviorSubject<String>(value: "")
  var hasRealm = BehaviorSubject<Bool>(value: false)
  var isClass = BehaviorSubject<Bool>(value: false)
  
  var data: Observable<(String, String, Bool, Bool)> {
    return Observable.combineLatest(id, name, isClass, hasRealm)
  }
  
  var saveEnabled: Driver<Bool> {
    return Observable.combineLatest(id.asObservable(), name.asObservable())
      .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" && $1.trimmingCharacters(in: .whitespacesAndNewlines) != "" })
      .startWith(false)
      .asDriver(onErrorJustReturn: false)
  }
  
  var deleteEnabled: Driver<Bool> {
    return exodiaInteractor.currentModel.asObservable()
      .map({ $0 != nil })
      .startWith(false)
      .asDriver(onErrorJustReturn: false)
  }
  
  let saveModelAction: Action<(String, String, Bool, Bool), Model>
  let newModelAction: CocoaAction
  let deleteModelAction: CocoaAction
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
    
    saveModelAction = Action<(String, String, Bool, Bool), Model> { [exodiaInteractor = exodiaInteractor] data in
      
      let create = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value == nil })
        .flatMapLatest(exodiaInteractor.createModel(withID: andName: isClass: hasRealm:))
      
      let update = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value != nil })
        .flatMapLatest(exodiaInteractor.updateModel(withID: andName: isClass: hasRealm:))
      
      return Observable.from([create, update])
        .merge()
    }
    
    newModelAction = CocoaAction { [exodiaInteractor = exodiaInteractor] in
      exodiaInteractor.newModel()
      return Observable.just()
    }
    
    deleteModelAction = CocoaAction {
      return exodiaInteractor.deleteModel()
    }
    
    exodiaInteractor.currentModel
      .asObservable()
      .map({ $0?.id ?? "" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentModel
      .asObservable()
      .map({ $0?.name ?? "" })
      .bind(to: name)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentModel
      .asObservable()
      .map({ $0?.hasRealm ?? false })
      .bind(to: hasRealm)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentModel
      .asObservable()
      .map({ $0?.isClass ?? false })
      .bind(to: isClass)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentModel
      .asObservable()
      .map({ $0?.id ?? "" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
    
    name.map({ "__MODEL_" + $0.uppercased() + "__" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
  }
  
  var reloadData: Observable<Void> {
    return exodiaInteractor.currentModel.asObservable()
      .map({ _ in return })
      .shareReplay(1)
  }
  
  var numberOfProperties: Int {
    return exodiaInteractor.numberOfProperties
  }
  
  var properties: [Property] {
    return exodiaInteractor.properties
  }
  
  func selectProperty(atIndex index: Int) {
    
    exodiaInteractor.selectProperty(atIndex: index)
  }
  
  func clearProperty() {
    exodiaInteractor.clearProperty()
  }
}
