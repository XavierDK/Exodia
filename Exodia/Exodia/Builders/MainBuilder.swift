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

let container = Container()

enum MainBuilder {
  
  case modelList
  case modelForm
  case propertyForm
  
  static func build(controller: NSViewController) {
    type(forController: controller)?.build(controller: controller)
  }
  
  static func exodia() -> ExodiaInteractorType {
    
    DispatchQueue.once(token: "__ASSEMBLY__") {
      assembly()
    }
    return container.resolve(ExodiaInteractorType.self)!
  }
  
  private func build(controller: NSViewController) {
    
    DispatchQueue.once(token: "__ASSEMBLY__") {
      MainBuilder.assembly()
    }
    
    switch self {
    case .modelList:
      buildModelList(controller)
    case .modelForm:
      buildModelForm(controller)
    case .propertyForm:
      buildPropertyForm(controller)
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
  
  private static func assembly() {
    
    container.autoregister(ModelListViewModelType.self, initializer: ModelListViewModel.init)
    container.autoregister(ModelFormViewModelType.self, initializer: ModelFormViewModel.init)
    container.autoregister(PropertyFormViewModelType.self, initializer: PropertyFormViewModel.init)
    
    container.autoregister(ConfigFileServiceType.self, initializer: ConfigFileService.init)
    
    container.autoregister(ExodiaInteractorType.self, initializer: ExodiaInteractor.init).inObjectScope(.container)
  }
}

public extension DispatchQueue {
  private static var _onceTracker = [String]()
  
  public class func once(file: String = #file, function: String = #function, line: Int = #line, block:(Void)->Void) {
    let token = file + ":" + function + ":" + String(line)
    once(token: token, block: block)
  }
  
  /**
   Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
   only execute the code once even in the presence of multithreaded calls.
   
   - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
   - parameter block: Block to execute once
   */
  public class func once(token: String, block:(Void)->Void) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    
    
    if _onceTracker.contains(token) {
      return
    }
    
    _onceTracker.append(token)
    block()
  }
}
