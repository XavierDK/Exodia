//
//  AppDelegate.swift
//  Exodia
//
//  Created by Xavier De Koninck on 21/08/2017.
//  Copyright © 2017 XavierDeKoninck. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

extension AppDelegate {
  
  @IBAction func saveDocument(_ sender: NSMenuItem) {
    
    let panel = NSSavePanel()
    
    panel.nameFieldStringValue = "Exodia"
    panel.begin { res in
      
      if let url = panel.url {
        
        let strURL = url.absoluteString + ".json"        
        MainBuilder.exodia().saveJSON(to: strURL)
      }
    }
  }
  
  @IBAction func generate(_ sender: AnyObject) {
    
    let panel = NSSavePanel()
  
    panel.begin { res in
      
      if let url = panel.url {
        MainBuilder.exodia().generateFiles(to: url.absoluteString)
      }
    }
  }
}

