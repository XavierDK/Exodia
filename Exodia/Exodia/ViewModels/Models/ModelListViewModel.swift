//
//  ModelListViewModel.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift

protocol ModelListViewModelType {
  
  var reloadData: Observable<Void> { get }
  
  var numberOfModels: Int { get }
  var models: [Model] { get }
  
  init(exodiaInteractor: ExodiaInteractorType)
  
  func selectModel(atIndex: Int)
}

struct ModelListViewModel: ModelListViewModelType {
  
  let exodiaInteractor: ExodiaInteractorType
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
  }
  
  var reloadData: Observable<Void> {
    return exodiaInteractor.exodia.asObservable()
      .map({ _ in return })
      .shareReplay(1)
  }
  
  var numberOfModels: Int {
    return exodiaInteractor.numberOfModels
  }
  
  var models: [Model] {
    return exodiaInteractor.models
  }
  
  func selectModel(atIndex index: Int) {
    
    exodiaInteractor.selectModel(atIndex: index)
  }
}
