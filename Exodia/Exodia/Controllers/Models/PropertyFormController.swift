//
//  PropertyFormController.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import RxOptional
import Action

class PropertyFormController: NSViewController {
  
  var viewModel: PropertyFormViewModelType!
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var idTextField: NSTextField!
  @IBOutlet weak var nameTextField: NSTextField!
  @IBOutlet weak var validateButton: NSButton!
  @IBOutlet weak var newButton: NSButton!
  @IBOutlet weak var deleteButton: NSButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    setup()
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let controller = segue.destinationController as? NSViewController {
      MainBuilder.build(controller: controller)
    }    
  }
  
  func setup() {
    
    idTextField.rx.text
      .skip(1)
      .filterNil()
      .bind(to: viewModel.id)
      .addDisposableTo(disposeBag)
    
    viewModel.id
      .debug()
      .distinctUntilChanged()
      .bind(to: idTextField.rx.text)
      .addDisposableTo(disposeBag)
    
    nameTextField.rx.text
      .skip(1)
      .filterNil()
      .bind(to: viewModel.name)
      .addDisposableTo(disposeBag)
    
    viewModel.name
      .debug()
      .distinctUntilChanged()
      .bind(to: nameTextField.rx.text)
      .addDisposableTo(disposeBag)
    
    viewModel.saveEnabled
      .drive(validateButton.rx.isEnabled)
      .addDisposableTo(disposeBag)
    
    viewModel.deleteEnabled
      .drive(deleteButton.rx.isEnabled)
      .addDisposableTo(disposeBag)
    
    validateButton.rx.tap
      .withLatestFrom(viewModel.data)
      .bind(to: viewModel.saveModelAction.inputs)
      .addDisposableTo(disposeBag)
    
    newButton.rx.tap
      .bind(to: viewModel.newModelAction.inputs)
      .addDisposableTo(disposeBag)
    
    deleteButton.rx.tap
      .bind(to: viewModel.deleteModelAction.inputs)
      .addDisposableTo(disposeBag)
  }
}
