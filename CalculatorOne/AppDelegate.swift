//
//  AppDelegate.swift
//  CalculatorOne
//
//  Created by Andreas on 28/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate 
{

    var documents: [Document] { return NSDocumentController.shared().documents as! [Document] }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) 
    {
        // Insert code here to initialize your application
        // print(#function)
        
        for document in documents
        {
            document.applicationDidLaunch()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) 
    {
        // Insert code here to tear down your application
        // print(#function)
        
        for document in documents
        {
            document.applicationWillTerminate()
        }
    }
    

}

