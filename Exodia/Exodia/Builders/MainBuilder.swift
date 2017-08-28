//
//  MainBuilder.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa
import Swinject
import SwinjectAutoregistration
import RxSwift

var container: Container = {
  
  let container = Container()
  container.autoregister(ModelListViewModelType.self, initializer: ModelListViewModel.init)
  container.autoregister(ModelFormViewModelType.self, initializer: ModelFormViewModel.init)
  container.autoregister(PropertyFormViewModelType.self, initializer: PropertyFormViewModel.init)
  
  container.autoregister(ServiceListViewModelType.self, initializer: ServiceListViewModel.init)
  container.autoregister(ServiceFormViewModelType.self, initializer: ServiceFormViewModel.init)
  
  container.autoregister(GeneratorServiceType.self, initializer: GeneratorService.init)
  
  container.autoregister(ExodiaInteractorType.self, initializer: ExodiaInteractor.init).inObjectScope(.container)
  
  return container
}()

enum MainBuilder {
  
  case modelList
  case modelForm
  case propertyForm
  case serviceList
  case serviceForm
  
  static func build(controller: NSViewController) {
    type(forController: controller)?.build(controller: controller)
  }
  
  static func exodia() -> ExodiaInteractorType {
    
    return container.resolve(ExodiaInteractorType.self)!
  }
  
  private func build(controller: NSViewController) {
    
    switch self {
    case .modelList:
      buildModelList(controller)
    case .modelForm:
      buildModelForm(controller)
    case .propertyForm:
      buildPropertyForm(controller)
    case .serviceList:
      buildServiceList(controller)
    case .serviceForm:
      buildServiceForm(controller)
    }
  }
  
  private static func type(forController controller: NSViewController) -> MainBuilder? {
    
    switch controller {
    case is ModelListController:
      return .modelList
    case is ModelFormController:
      return .modelForm
    case is PropertyFormController:
      return .propertyForm
    case is ServiceListController:
      return .serviceList
    case is ServiceFormController:
      return .serviceForm
    default:
      return nil
    }
  }
  
  private func buildModelList(_ controller: NSViewController) {
    
    (controller as! ModelListController).viewModel = container.resolve(ModelListViewModelType.self)!
  }
  
  private func buildModelForm(_ controller: NSViewController) {
    
    (controller as! ModelFormController).viewModel = container.resolve(ModelFormViewModelType.self)!
  }
  
  private func buildPropertyForm(_ controller: NSViewController) {
    
    (controller as! PropertyFormController).viewModel = container.resolve(PropertyFormViewModelType.self)!
  }
  
  private func buildServiceList(_ controller: NSViewController) {
    
    (controller as! ServiceListController).viewModel = container.resolve(ServiceListViewModelType.self)!
  }
  
  private func buildServiceForm(_ controller: NSViewController) {
    
    (controller as! ServiceFormController).viewModel = container.resolve(ServiceFormViewModelType.self)!
  }
}
