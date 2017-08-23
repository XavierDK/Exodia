//
//  ModelListController.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class ModelListController: NSViewController {
  
  var viewModel: ModelListViewModelType!
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var tableView: NSTableView!
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    setupTableView()
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let controller = segue.destinationController as? NSViewController {
      
      MainBuilder.build(controller: controller)
    }
  }
  
  func setupTableView() {
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.target = self
    tableView.doubleAction = #selector(self.modelSelected(_:))
    
    viewModel.reloadData
      .subscribe(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .addDisposableTo(disposeBag)
  }
}

extension ModelListController: NSTableViewDataSource, NSTableViewDelegate {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.numberOfModels
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let view = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    let model = viewModel.models[row]
    
    if tableColumn == tableView.tableColumns[0] {
      view.textField!.stringValue = model.id ?? ""
    }
    else if tableColumn == tableView.tableColumns[1] {
      view.textField!.stringValue = model.name ?? ""
    }
    
    return view
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    
    return viewModel.models[row]
  }
  
  func modelSelected(_ sender: AnyObject) {
    
    guard tableView.selectedRow >= 0 else {
      return
    }
    
    viewModel.selectModel(atIndex: tableView.selectedRow)
  }
}
