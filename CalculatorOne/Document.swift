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
    // load/save operation uses the dictionary[String : Any] as the container for load/save data
    // ConfigurationKey holds the available keys for this dictionary
    enum ConfigurationKey: String
    {
        //case operandType = "kOperandType"  // eliminated 23.7.2017
        case radix = "kRadix"
        case stackValues = "kStackValues", memoryAValues = "kMemoryAValues", memoryBValues = "kMemoryBValues"
        case extraOperationsViewYPosition = "kExtraOperationsViewYPosition"
    }

    // this configuration is used on a new file
    private let defaultConfiguration: [String : Any] = 
        [
        // Eliminated operand type on 23.7.2017
        // ConfigurationKey.operandType.rawValue : 1,              /* .float */
        ConfigurationKey.radix.rawValue       : 2,              /* .decimal */
        ConfigurationKey.extraOperationsViewYPosition.rawValue : 0.0,  
        ConfigurationKey.stackValues.rawValue   : [],             /* emtpy array of [OperandType] */
        ConfigurationKey.memoryAValues.rawValue : [],             /* emtpy array of [OperandType] */
        ConfigurationKey.memoryBValues.rawValue : []              /* emtpy array of [OperandType] */
    ]

    // holds the entire set of configuration data as dictionary. Any change will make the document dirty
    // other classes directly read from/write to the currentSaveDataSet container
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
    
    
    // MARK: - copy/paste
    
    @IBAction func copyStack(sender: AnyObject)
    {
        if sender is NSMenuItem
        {
            let menuItem = sender as! NSMenuItem
            
            if menuItem.title == "Copy Top Stack"
            {
                let valueToCopy = engine.registerValue(inRegisterNumber: 0, radix: 10)
                let pasteBoard = NSPasteboard.general()
                pasteBoard.clearContents()
                pasteBoard.writeObjects([valueToCopy as NSPasteboardWriting])
            }
            else if menuItem.title == "Copy Stack"
            {
                let countStackItems: Int = Int(engine.numberOfRegistersWithContent())
                var valuesToCopy: [String] = [String]()
                for reg in (0..<countStackItems).reversed()
                {
                    let valueStr: String = engine.registerValue(inRegisterNumber: reg, radix: 10)
                    valuesToCopy.append(valueStr)
                }

                let flatValues: String = valuesToCopy.joined(separator: "\n")
                
                let pasteBoard = NSPasteboard.general()
                pasteBoard.clearContents()
                
                pasteBoard.writeObjects([flatValues as NSPasteboardWriting])
                
            }
        }
    }
    
    @IBAction func pasteToStack(sender: AnyObject)
    {
        if sender is NSMenuItem
        {
            for valueString in currentPasteBoardItems()
            {
                if engine.userWillInputEnter(numericalValue: valueString, radix: 10) == true
                {
                    engine.userInputEnter(numericalValue: valueString, radix: 10)
                }
                else
                {
                    Swift.print("! \(#function) does not accept <\(valueString)> to paste to the stack")
                }                            
            }
        }
    }
    
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool 
    {
        if item is NSMenuItem
        {
            let menuItem = item as! NSMenuItem
            
            if menuItem.title == "Copy Top Stack" || menuItem.title == "Copy Stack"
            {
                return engine.hasValueForRegister(registerNumber: 0)
            }
            else if menuItem.title == "Paste"
            {
                for valueString in currentPasteBoardItems()
                {
                    if engine.userWillInputEnter(numericalValue: valueString, radix: 10) == true
                    {
                        // at least one item on the pasteboard can be converted to a numerical value
                        return true
                    }
                }
                    
                return false                
            }
        }
        
        return super.validateUserInterfaceItem(item)
    }
    
    private func currentPasteBoardItems() -> [String]
    {
        let pasteBoard = NSPasteboard.general()
        var stringItems: [String] = [String]()
        
        if let items = pasteBoard.pasteboardItems
        {
            for item in items
            {
                if let stringItem = item.string(forType: "public.utf8-plain-text")
                {
                    stringItems.append(contentsOf: stringItem.components(separatedBy: CharacterSet.whitespacesAndNewlines))                    
                }
            }
        }
        
        return stringItems
    }
    
}

