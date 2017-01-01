//
//  Document.swift
//  CalculatorOne
//
//  Created by Andreas on 28/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa


///Defines life cycle methods for a document
protocol DocumentLifeCycle
{
    func applicationDidLaunch()
    func didOpen()
    func applicationWillTerminate()
}


/// Defines lifecycle methods for a controller
protocol DependendObjectLifeCycle
{
    func documentDidOpen()
    func documentWillClose()
}


class Document: NSDocument, DocumentLifeCycle 
{
    
    @IBOutlet weak var displayController: DisplayController!
    @IBOutlet weak var keypadController: KeypadController!
    @IBOutlet weak var engine: Engine!
    
    private var dependedObjects: [DependendObjectLifeCycle]!
        
    override init() 
    {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool
    {
        return true
    }

    override var windowNibName: String? 
    {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }
    
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) 
    {
        super.windowControllerDidLoadNib(windowController)
        
        didOpen()
    }


    override func shouldCloseWindowController(_ windowController: NSWindowController, delegate: Any?, shouldClose shouldCloseSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) 
    {
        // clean up (documentWillClose)
        for controller in dependedObjects
        {
            controller.documentWillClose()
        }   
        
        super.shouldCloseWindowController(windowController, delegate: delegate, shouldClose: shouldCloseSelector, contextInfo: contextInfo)
    }

    
    
    internal func applicationDidLaunch() 
    {
        
    }

    
    internal func applicationWillTerminate() 
    {
        
    }
    
    internal func didOpen() 
    {
        dependedObjects = [displayController, keypadController, engine]
        
        for controller in dependedObjects
        {
            controller.documentDidOpen()
        }
        
    }
    

    

    override func data(ofType typeName: String) throws -> Data 
    {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        return "First Data Written As String".data(using: String.Encoding.utf8)!
        
        
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        /*throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)*/
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        
        if let s = String(data: data, encoding: String.Encoding.utf8) 
        {
            Swift.print(s)
        }
        
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        /*throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)*/
    }
    


}

