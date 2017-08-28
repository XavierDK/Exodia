//
//  PropertyFormViewModel.swift
//  Exodia
//
//  Created by Xavier De Koninck on 23/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol PropertyFormViewModelType {
  
  // INPUTS
  
  var id: BehaviorSubject<String> { get }
  var name: BehaviorSubject<String> { get }
  var type: BehaviorSubject<String> { get }
  var key: BehaviorSubject<String> { get }
  var defaultValue: BehaviorSubject<String?> { get }
  
  // OUTPUTS
  
  var data: Observable<(String, String, String, String, String?)> { get }
  var saveEnabled: Driver<Bool> { get }
  var deleteEnabled: Driver<Bool> { get }
  
  // ACTIONS
  var saveModelAction: Action<(String, String, String, String, String?), Property> { get }
  var newModelAction: CocoaAction { get }
  var deleteModelAction: CocoaAction { get }
  
  init(exodiaInteractor: ExodiaInteractorType)
}

struct PropertyFormViewModel: PropertyFormViewModelType {
  
  var exodiaInteractor: ExodiaInteractorType
  
  let disposeBag = DisposeBag()
  
  var id = BehaviorSubject<String>(value: "")
  var name = BehaviorSubject<String>(value: "")
  var type = BehaviorSubject<String>(value: "")
  var key = BehaviorSubject<String>(value: "")
  var defaultValue = BehaviorSubject<String?>(value: nil)
  
  var data: Observable<(String, String, String, String, String?)> {
    return Observable.combineLatest(id, name, type, key, defaultValue)
  }
  
  var saveEnabled: Driver<Bool> {
    return Observable.combineLatest(id.asObservable(), name.asObservable(), type.asObservable(), key.asObservable())
      .map({
        $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
          && $1.trimmingCharacters(in: .whitespacesAndNewlines) != ""
          && $2.trimmingCharacters(in: .whitespacesAndNewlines) != ""
          && $3.trimmingCharacters(in: .whitespacesAndNewlines) != ""
      })
      .startWith(false)
      .asDriver(onErrorJustReturn: false)
  }
  
  var deleteEnabled: Driver<Bool> {
    return exodiaInteractor.currentProperty.asObservable()
      .map({ $0 != nil })
      .startWith(false)
      .asDriver(onErrorJustReturn: false)
  }
  
  let saveModelAction: Action<(String, String, String, String, String?), Property>
  let newModelAction: CocoaAction
  let deleteModelAction: CocoaAction
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
    
    saveModelAction = Action<(String, String, String, String, String?), Property> { [exodiaInteractor = exodiaInteractor] data in
      
      let create = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentProperty.value == nil })
        .flatMapLatest(exodiaInteractor.createProperty(withID: andName: andType: andKey: andDefaultValue:))
      
      let update = Observable.just(data)
        .filter({ [exodiaInteractor = exodiaInteractor] _ in exodiaInteractor.currentProperty.value != nil })
        .flatMapLatest(exodiaInteractor.updateProperty(withID: andName: andType: andKey: andDefaultValue:))
      
      return Observable.from([create, update])
        .merge()
    }
    
    newModelAction = CocoaAction { [exodiaInteractor = exodiaInteractor] in
      exodiaInteractor.newProperty()
      return Observable.just()
    }
    
    deleteModelAction = CocoaAction {
      return exodiaInteractor.deleteProperty()
    }
    
    exodiaInteractor.currentProperty
      .asObservable()
      .map({ $0?.id ?? "" })
      .bind(to: id)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentProperty
      .asObservable()
      .map({ $0?.name ?? "" })
      .bind(to: name)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentProperty
      .asObservable()
      .map({ $0?.type ?? "" })
      .bind(to: type)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentProperty
      .asObservable()
      .map({ $0?.key ?? "" })
      .bind(to: key)
      .addDisposableTo(disposeBag)
    
    exodiaInteractor.currentProperty
      .asObservable()
      .map({ $0?.defaultValue ?? "" })
      .bind(to: defaultValue)
      .addDisposableTo(disposeBag)
    
    name.map({ [exodiaInteractor = exodiaInteractor] in
      "__MODEL_\((exodiaInteractor.currentModel.value?.name ?? "").uppercased())_PROPERTY_\($0.uppercased())__"
    })
      .bind(to: id)
      .addDisposableTo(disposeBag)
  }
}
