//
//  ServiceFormViewModel.swift
//  Exodia
//
//  Created by Xavier De Koninck on 28/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol ServiceFormViewModelType {
  
  // INPUTS
  var id: BehaviorSubject<String> { get }
  var name: BehaviorSubject<String> { get }
  
  // OUTPUTS
  var data: Observable<(String, String)> { get }
  var saveEnabled: Driver<Bool> { get }
  var deleteEnabled: Driver<Bool> { get }
  
  // ACTIONS
  var saveServiceAction: Action<(String, String), Service> { get }
  var newServiceAction: CocoaAction { get }
  var deleteServiceAction: CocoaAction { get }
  
//  // PROPERTIES
//  var reloadData: Observable<Void> { get }
//  var numberOfProperties: Int { get }
//  var properties: [Property] { get }
//  func selectProperty(atIndex: Int)
//  func clearProperty()
  
  init(exodiaInteractor: ExodiaInteractorType)
}

struct ServiceFormViewModel: ServiceFormViewModelType {
  
  var exodiaInteractor: ExodiaInteractorType
  
  let disposeBag = DisposeBag()
  
  var id = BehaviorSubject<String>(value: "")
  var name = BehaviorSubject<String>(value: "")
  
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
  
  let saveServiceAction: Action<(String, String), Service>
  let newServiceAction: CocoaAction
  let deleteServiceAction: CocoaAction
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
    
    saveServiceAction = Action<(String, String), Service> { [exodiaInteractor = exodiaInteractor] data in
      
      let create = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value == nil })
        .flatMapLatest(exodiaInteractor.createService(withID: andName:))
      
      let update = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentModel.value != nil })
        .flatMapLatest(exodiaInteractor.updateService(withID: andName:))
      
      return Observable.from([create, update])
        .merge()
    }
    
    newServiceAction = CocoaAction { [exodiaInteractor = exodiaInteractor] in
      exodiaInteractor.newService()
      return Observable.just()
    }
    
    deleteServiceAction = CocoaAction {
      return exodiaInteractor.deleteService()
    }
    
    exodiaInteractor.currentService
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
      .map({ $0?.id ?? "" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
    
    name.map({ "__SERVICE_" + $0.uppercased() + "__" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
  }
  
//  var reloadData: Observable<Void> {
//    return exodiaInteractor.currentModel.asObservable()
//      .map({ _ in return })
//      .shareReplay(1)
//  }
//  
//  var numberOfProperties: Int {
//    return exodiaInteractor.numberOfProperties
//  }
//  
//  var properties: [Property] {
//    return exodiaInteractor.properties
//  }
//  
//  func selectProperty(atIndex index: Int) {
//    
//    exodiaInteractor.selectProperty(atIndex: index)
//  }
//  
//  func clearProperty() {
//    exodiaInteractor.clearProperty()
//  }
}
