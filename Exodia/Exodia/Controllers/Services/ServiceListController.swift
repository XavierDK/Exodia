//
//  ServiceListController.swift
//  Exodia
//
//  Created by Xavier De Koninck on 28/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class ServiceListController: NSViewController {
  
  var viewModel: ServiceListViewModelType!
  
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
    tableView.doubleAction = #selector(self.serviceSelected(_:))
    
    viewModel.reloadData
      .subscribe(onNext: { [weak self] _ in
        self?.tableView.reloadData()
      })
      .addDisposableTo(disposeBag)
  }
}

extension ServiceListController: NSTableViewDataSource, NSTableViewDelegate {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.numberOfServices
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let view = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    let service = viewModel.services[row]
    
    if tableColumn == tableView.tableColumns[0] {
      view.textField!.stringValue = service.id ?? ""
    }
    else if tableColumn == tableView.tableColumns[1] {
      view.textField!.stringValue = service.name ?? ""
    }
    
    return view
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    
    return viewModel.services[row]
  }
  
  func serviceSelected(_ sender: AnyObject) {
    
    guard tableView.selectedRow >= 0 else {
      return
    }
    
    viewModel.selectService(atIndex: tableView.selectedRow)
  }
}
