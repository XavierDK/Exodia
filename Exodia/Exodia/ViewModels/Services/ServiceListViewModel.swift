//
//  ServiceListViewModel.swift
//  Exodia
//
//  Created by Xavier De Koninck on 28/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Foundation
import RxSwift

protocol ServiceListViewModelType {
  
  var reloadData: Observable<Void> { get }
  
  var numberOfServices: Int { get }
  var services: [Service] { get }
  
  init(exodiaInteractor: ExodiaInteractorType)
  
  func selectService(atIndex: Int)
}

struct ServiceListViewModel: ServiceListViewModelType {
  
  let exodiaInteractor: ExodiaInteractorType
  
  init(exodiaInteractor: ExodiaInteractorType) {
    
    self.exodiaInteractor = exodiaInteractor
  }
  
  var reloadData: Observable<Void> {
    return exodiaInteractor.exodia.asObservable()
      .map({ _ in return })
      .shareReplay(1)
  }
  
  var numberOfServices: Int {
    return exodiaInteractor.numberOfServices
  }
  
  var services: [Service] {
    return exodiaInteractor.services
  }
  
  func selectService(atIndex index: Int) {
    
    exodiaInteractor.selectService(atIndex: index)
  }
}
