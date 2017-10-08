//
//  TestDocument.swift
//  CalculatorOne
//
//  Created by Andreas on 13.05.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestDocument: XCTestCase 
{

    var dut: Document!
    var windowController: NSWindowController!
    var window: NSWindow!
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dut = Document()
        dut.makeWindowControllers()
        windowController = dut.windowControllers.first!

        XCTAssertNotNil(windowController)

        window = windowController.window
        
        XCTAssertNotNil(window)

    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatDocumentCanBeCreated()
    {
        XCTAssertNotNil(dut)
    }
    
    
    func testThatADocumentWindowCanBeLoaded()
    {
        XCTAssertNotNil(window)
    }
    
    
    func testThatInternalObjectsConnectionsAreAccessible()
    {
        XCTAssertNotNil(dut.displayController)
        XCTAssertNotNil(dut.keypadController)
        XCTAssertNotNil(dut.engine)
    }
    
    func testThatACreatedDocumentLoadsADefaultConfigurationIntoItsSaveDataSet()
    {
        XCTAssertEqual(dut.currentSaveDataSet.isEmpty, false)
        
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.stackValues.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.radix.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.extraOperationsViewYPosition.rawValue])        
    }
    

    func testThatActionCopyToStackCopiesRegisterNumber0ToThePasteboard()
    {
        XCTAssertNotNil(dut.engine)
        
        let valuePastedOnPasteboard: String = "42"
        
        // enter a number to the stack top
        dut.engine.userInputEnter(numericalValue: valuePastedOnPasteboard, radix: 10)
        
        // mock up a menu command
        let menuItem: NSMenuItem = makeMenuItemWithTitle(CopyCommand.copyTopStackElement)
        
        // copy the stack to to the pasteboard
        dut.copyStack(sender: menuItem)
        
        let pasteboard: NSPasteboard = NSPasteboard.general
        let items = pasteboard.pasteboardItems
        
        guard items != nil else 
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 
        
        // expect pasteboard content as String
        guard true == pasteboard.canReadItem(withDataConformingToTypes: [NSPasteboard.PasteboardType.string.rawValue]) else
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 

        var foundValueOnPasteboard: Bool = false
        
        for item in items!
        {
            let pbData = item.data(forType: NSPasteboard.PasteboardType.string)
            if let pbString: String = String(data: pbData!, encoding: String.Encoding.utf8)
            {
                XCTAssertEqual(pbString, valuePastedOnPasteboard)
                foundValueOnPasteboard = true
            }
        }
        
        // did any pasteboard items contain the pastedValue?
        guard true == foundValueOnPasteboard else
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 
    }

    
    func testThatActionCopyAllToStackCopiesAllRegistersToThePasteboard()
    {
        XCTAssertNotNil(dut.engine)
        
        let valuesPastedOnPasteboard: [String] = ["-42", "-100", "101", "-0.998"]
        let expectedValueFromPasteBoard: String = valuesPastedOnPasteboard.joined(separator: "\n")
        
        // enter all numbers to the stack
        for value in valuesPastedOnPasteboard
        {
            dut.engine.userInputEnter(numericalValue: value, radix: 10)
        }
        
        // mock up a menu command
        let menuItem: NSMenuItem = makeMenuItemWithTitle(CopyCommand.copyStack)
        
        // copy the stack to to the pasteboard
        dut.copyStack(sender: menuItem)
        
        let pasteboard: NSPasteboard = NSPasteboard.general
        let items = pasteboard.pasteboardItems
        
        guard items != nil else 
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 
        
        // expect pasteboard content as String
        guard true == pasteboard.canReadItem(withDataConformingToTypes: [NSPasteboard.PasteboardType.string.rawValue]) else
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 
        
        var foundValueOnPasteboard: Bool = false
        
        for item in items!
        {
            let pbData = item.data(forType: NSPasteboard.PasteboardType.string)
            if let pbString: String = String(data: pbData!, encoding: String.Encoding.utf8)
            {
                XCTAssertEqual(pbString, expectedValueFromPasteBoard)
                foundValueOnPasteboard = true
            }
        }
        
        // did any pasteboard items contain the pastedValue?
        guard true == foundValueOnPasteboard else
        { 
            XCTFail("Test failure: Engine did not copy top of stack value to pasteboard")
            return
        } 
    }

    
    
    func makeMenuItemWithTitle(_ title: String) -> NSMenuItem
    {
        let item: NSMenuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        return item
    }
    
}
