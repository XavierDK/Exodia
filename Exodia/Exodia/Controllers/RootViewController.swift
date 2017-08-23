//
//  RootViewController.swift
//  Exodia
//
//  Created by Xavier De Koninck on 22/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa
import RxSwift

class RootViewController: NSTabViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let controller = segue.destinationController as? NSViewController {
      
      MainBuilder.build(controller: controller)
    }
  }
  
  @IBAction func saveDocument(_ sender: NSMenuItem) {
    
    let panel = NSSavePanel()
    
    panel.nameFieldStringValue = "Exodia"
    panel.begin { res in
      
      if let url = panel.url {
        
        let strURL = url.absoluteString + ".json"
        print(strURL)
        
        if let json = MainBuilder.exodia().generateJSON() {
          try? json.data(using: .utf8)?.write(to: URL(string: strURL)!)
        }
      }
    }
  }
}

