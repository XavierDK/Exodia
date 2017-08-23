//
//  ModelFormController.swift
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

class ModelFormController: NSViewController {
  
  var viewModel: ModelFormViewModelType!
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var idTextField: NSTextField!
  @IBOutlet weak var nameTextField: NSTextField!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var validateButton: NSButton!
  @IBOutlet weak var newButton: NSButton!
  @IBOutlet weak var deleteButton: NSButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    setup()
    setupTableView()
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let controller = segue.destinationController as? NSViewController {
      MainBuilder.build(controller: controller)
    }
  }
  
  func setup() {
    
    idTextField.rx.text
      .filterNil()
      .bind(to: viewModel.id)
      .addDisposableTo(disposeBag)
    
    viewModel.id
      .distinctUntilChanged()
      .bind(to: idTextField.rx.text)
      .addDisposableTo(disposeBag)
    
    nameTextField.rx.text
      .filterNil()
      .bind(to: viewModel.name)
      .addDisposableTo(disposeBag)
    
    viewModel.name
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
  
  func setupTableView() {
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.target = self
    tableView.doubleAction = #selector(self.propertySelected(_:))
    
    viewModel.reloadData
      .subscribe(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .addDisposableTo(disposeBag)
  }
}

extension ModelFormController: NSTableViewDataSource, NSTableViewDelegate {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.numberOfProperties
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let view = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    let property = viewModel.properties[row]
    
    if tableColumn == tableView.tableColumns[0] {
      view.textField!.stringValue = property.id ?? ""
    }
    else if tableColumn == tableView.tableColumns[1] {
      view.textField!.stringValue = property.name ?? ""
    }
    
    return view
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    
    return viewModel.properties[row]
  }
  
  func propertySelected(_ sender: AnyObject) {
    
    guard tableView.selectedRow >= 0 else {
      return
    }
    
    viewModel.selectProperty(atIndex: tableView.selectedRow)
  }
}
