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
  @IBOutlet weak var realmButton: NSButton!
  @IBOutlet weak var structButton: NSButton!
  @IBOutlet weak var classButton: NSButton!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var validateButton: NSButton!
  @IBOutlet weak var newButton: NSButton!
  @IBOutlet weak var deleteButton: NSButton!
  
  let segueNewPropertyForm = "SegueNewPropertyForm"
  let segueUpdatePropertyForm = "SegueUpdatePropertyForm"
  
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
    
    if segue.identifier == segueNewPropertyForm {
      viewModel.clearProperty()
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
    
    realmButton.rx.state
      .map({ $0 == 1 })
      .bind(to: viewModel.hasRealm)
      .addDisposableTo(disposeBag)
    
    viewModel.hasRealm
      .distinctUntilChanged()
      .map({ ($0) ? (1) : (0) })
      .bind(to: realmButton.rx.state)
      .addDisposableTo(disposeBag)
    
    viewModel.isClass
      .distinctUntilChanged()
      .map({ ($0) ? (1) : (0) })
      .bind(to: classButton.rx.state)
      .addDisposableTo(disposeBag)
    
    viewModel.isClass
      .distinctUntilChanged()
      .map({ ($0) ? (0) : (1) })
      .bind(to: structButton.rx.state)
      .addDisposableTo(disposeBag)
    
    viewModel.hasRealm
      .map(!)
      .bind(to: structButton.rx.isEnabled)
      .addDisposableTo(disposeBag)
    
    viewModel.hasRealm
      .map(!)
      .bind(to: classButton.rx.isEnabled)
      .addDisposableTo(disposeBag)
    
    viewModel.hasRealm
      .filter({ $0 })
      .bind(to: viewModel.isClass)
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
  
  @IBAction func modelType(_ sender: NSButton) {
    
    if sender.tag == 0 {
      print("Struct")
      viewModel.isClass.onNext(false)
    }
    else {
      print("Class")
      viewModel.isClass.onNext(true)
    }
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
    else if tableColumn == tableView.tableColumns[2] {
      view.textField!.stringValue = property.type ?? ""
    }
    else if tableColumn == tableView.tableColumns[3] {
      view.textField!.stringValue = property.key ?? ""
    }
    else if tableColumn == tableView.tableColumns[4] {
      view.textField!.stringValue = property.defaultValue ?? ""
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
    self.performSegue(withIdentifier: segueUpdatePropertyForm, sender: nil)
  }
}
