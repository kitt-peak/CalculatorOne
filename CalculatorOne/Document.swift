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
    
    
    /// Called when the document instance is fully intialized. If the document is opened from a file, didOpen() is called after
    /// data is read from file. The method sets the document configuration (from file or a default configuration and calls didOpen()
    /// on all the objects displayController, keypadController and engine to initialize themselves with document file data 
    internal func didOpen() 
    {
        dependedObjects = [displayController, keypadController, engine]
        
        if currentSaveDataSet.isEmpty == true
        {
            currentSaveDataSet = defaultConfiguration

        }
        
        for controller in dependedObjects
        {
            controller.documentDidOpen()
        }
        
    }
    

    // MARK: - Read/Write file data
    enum ConfigurationKey: String
    {
        case operandType = "kOperandType"
        case radix = "kRadix"
        case stackValues = "kStackValues", memoryAValues = "kMemoryAValues", memoryBValues = "kMemoryBValues"
        case extraOperationsViewYPosition = "kExtraOperationsViewYPosition"
    }

    // this configuration is used on a new file
    private let defaultConfiguration: [String : Any] = [
        ConfigurationKey.operandType.rawValue : 1,              /* .float */
        ConfigurationKey.radix.rawValue       : 2,              /* .decimal */
        ConfigurationKey.extraOperationsViewYPosition.rawValue : 0.0,  
        ConfigurationKey.stackValues.rawValue   : [],             /* emtpy array of [OperandType] */
        ConfigurationKey.memoryAValues.rawValue : [],             /* emtpy array of [OperandType] */
        ConfigurationKey.memoryBValues.rawValue : []              /* emtpy array of [OperandType] */
    ]

    // holds the entire set of configuration data as dictionary. Any change will make the document dirty
    var currentSaveDataSet: [String : Any] = [:]
    { didSet { updateChangeCount(.changeDone) }  }
        
    
    /// Called by the document to save data to file. Saves configuration data (operand type, radix) and the stack to the file.
    ///
    /// - Parameter typeName: name of the file type. Configured in Info.plist, under document types
    /// - Returns: the data container with the configuration data and the stack values.
    /// - Throws: ?
    override func data(ofType typeName: String) throws -> Data 
    {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
    
        return NSKeyedArchiver.archivedData(withRootObject: currentSaveDataSet)
        
        
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        /*throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)*/
    }

    /// Called by the document to load the documents data from a file. Used to restore configuration parameters (OperandType, Radix) and the stack
    ///
    /// - Parameters:
    ///   - data: the data container with the configuration parameters (OperandType, Radix) and the stack. If valid, "data" is restored into the document.
    ///   - typeName: Parameter typeName: name of the file type. Configured in Info.plist, under document types.
    /// - Throws: ?
    override func read(from data: Data, ofType typeName: String) throws 
    {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        
        if let loadedDataSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any]
        {
            //configurationFromFile = readDictionary 
            //didLoadConfigDataFromFile = true
            currentSaveDataSet = loadedDataSet
        }
        
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        /*throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)*/
    }
    


}

