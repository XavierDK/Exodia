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
  
  var id: PublishSubject<String> { get }
  var name: PublishSubject<String> { get }
  
  // OUTPUTS
  
  var data: Observable<(String, String)> { get }
  var saveEnabled: Driver<Bool> { get }
  var deleteEnabled: Driver<Bool> { get }
  
  // ACTIONS
  var saveModelAction: Action<(String, String), Model> { get }
  var newModelAction: CocoaAction { get }
  var deleteModelAction: CocoaAction { get }
  
  // PROPERTIES
  var reloadData: Observable<Void> { get }
  var numberOfProperties: Int { get }
  var properties: [Property] { get }
  func selectProperty(atIndex: Int)
  
  init(exodiaInteractor: ExodiaInteractorType)
}

struct ModelFormViewModel: ModelFormViewModelType {
  
  var exodiaInteractor: ExodiaInteractorType
  
  let disposeBag = DisposeBag()
  
  var id = PublishSubject<String>()
  var name = PublishSubject<String>()
  
  var data: Observable<(String, String)> {
    return Observable.combineLatest(id, name)
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
  
  let saveModelAction: Action<(String, String), Model>
  let newModelAction: CocoaAction
  let deleteModelAction: CocoaAction
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
    
    saveModelAction = Action<(String, String), Model> { [exodiaInteractor = exodiaInteractor] data in
      
      let create = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value == nil })
        .flatMapLatest(exodiaInteractor.createModel(withID: andName:))
      
      let update = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value != nil })
        .flatMapLatest(exodiaInteractor.updateModel(withID: andName:))

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
}
