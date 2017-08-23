//
//  SplitController.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa

class SplitController: NSSplitViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for item in splitViewItems {
      MainBuilder.build(controller: item.viewController)
    }
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
