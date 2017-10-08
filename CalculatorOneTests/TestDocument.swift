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
        
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.stackValues])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryAValues])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryBValues])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.radix])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.extraOperationsViewYPosition])
    }
    

    func testThatActionCopyToStackCopiesRegisterNumber0ToThePasteboard()
    {
        XCTAssertNotNil(dut.engine)
        
        let valuePastedOnPasteboard: String = "42"
        
        // enter a number to the stack top
        dut.engine.userInputEnter(numericalValue: valuePastedOnPasteboard, radix: 10)
        
        // mock up a menu command
        let menuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.topStackElement)
        
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
        let menuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.entireStack)
        
        // copy the stack to the pasteboard
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


    func testThatActionPasteDoesPutANumericalStringValueOnTheStack()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let testValues: [String] = ["42", "0", "-42", "1.23456", "-1.23456", "1.23456e+18", "-1.23456e-13", "1.23456e+18", "1.23456e-13"]

        for testValue in testValues
        {
            pasteNumericalValue(numericalValue: testValue)

            // mock up a menu command
            let menuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardPasteCommand.paste)

            // paste the pasteboard content to the stack
            dut.pasteToStack(sender: menuItem)

            // retrieveValueFromStack
            let valueOnStack: String = dut.engine.registerValue(inRegisterNumber: 0, radix: 10)

            XCTAssertEqual(valueOnStack, testValue)

            dut.engine.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    func testThatActionPasteDoesPutSpaceSeparetedNumericalStringValuesOnTheStack()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general

                                            // input values             // expected result
        let testValues: [(String, String)] = [("42",                   "42"),
                                              ("32 42",                "32 42")
                                             ]

        for testValue in testValues
        {
            pasteboard.clearContents()

            pasteNumericalValue(numericalValue: testValue.0)

            // mock up a menu command
            let menuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardPasteCommand.paste)

            // paste the pasteboard content to the stack
            dut.pasteToStack(sender: menuItem)

            // retrieveValuesFromStack
            let valuesOnStack: String = stackValuesAsSpaceSeparatedString()

            XCTAssertEqual(valuesOnStack, testValue.1)

            dut.engine.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    func testThatActionPasteDoesPutNewLineSeparetedNumericalStringValuesOnTheStack()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general

                                              // input values             // expected result
        let testValues: [(String, String)] = [("42",                   "42"),
                                              ("-32 -42",              "-32 -42"),
                                              ("3.2 -4.2\n5.2",        "3.2 -4.2 5.2")
        ]

        for testValue in testValues
        {
            pasteboard.clearContents()

            pasteNumericalValue(numericalValue: testValue.0)

            // mock up a menu command
            let menuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardPasteCommand.paste)

            // paste the pasteboard content to the stack
            dut.pasteToStack(sender: menuItem)

            // retrieveValuesFromStack
            let valuesOnStack: String = stackValuesAsSpaceSeparatedString()

            XCTAssertEqual(valuesOnStack, testValue.1)

            dut.engine.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    func testThatCopyMenuItemIsValidatedCorrectlyFalseWhenStackIsEmpty()
    {
        let copyMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.topStackElement)

        // engine has no stack elements, expecting copy menu to validate false
        XCTAssertEqual(false, dut.validateUserInterfaceItem(copyMenuItem))
    }

    func testThatCopyStackMenuItemIsValidatedCorrectlyFalseWhenStackIsEmpty()
    {
        let copyMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.entireStack)

        // engine has no stack elements, expecting copy menu to validate false
        XCTAssertEqual(false, dut.validateUserInterfaceItem(copyMenuItem))
    }


    func testThatCopyMenuItemIsValidatedCorrectlyTrueWhenStackIsNotEmpty()
    {
        let copyMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.topStackElement)
        let copyStackMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardCopyCommand.entireStack)

        XCTAssertNotNil(dut.engine)

        dut.engine.userInputEnter(numericalValue: "42", radix: 10)

        // engine has one stack element, expecting copy menu to validate true
        XCTAssertEqual(true, dut.validateUserInterfaceItem(copyMenuItem))
        XCTAssertEqual(true, dut.validateUserInterfaceItem(copyStackMenuItem))
    }

    func testThatPasteMenuItemValidatesCorrectlyTrueIfAValidNumericalStringIsOnThePasteboard()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general

        //                                   input values              expected result
        let testValues: [String] = ["42",
                                    "-32 -42",
                                    "? 4",   // "4" is a valid numberical string, the other characters are ignored
                                    "0.1234 -0.1234 1.0E1 -1E-1"
        ]

        for testValue in testValues
        {
            pasteboard.clearContents()

            pasteNumericalValue(numericalValue: testValue)

            // mock up a menu command
            let pasteMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardPasteCommand.paste)

            XCTAssertEqual(true, dut.validateUserInterfaceItem(pasteMenuItem))
        }
    }

    func testThatPasteMenuItemValidatesCorrectlyFalseIfAInvalidNumericalStringIsOnThePasteboard()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general

        //                                   input values              expected result
        let testValues: [String] = ["-",
                                    "One",
                                    "A B C",
                                    "XX0.1234-0.12341.0E1-1E-1"
        ]

        for testValue in testValues
        {
            pasteboard.clearContents()

            pasteNumericalValue(numericalValue: testValue)

            // mock up a menu command
            let pasteMenuItem: NSMenuItem = makeMenuItemWithTitle(GlobalConstants.PasteboardPasteCommand.paste)

            XCTAssertEqual(false, dut.validateUserInterfaceItem(pasteMenuItem))
        }
    }


    func testThatAnInValidMenuItemCorrectlyValidatesFalse()
    {
        XCTAssertNotNil(dut.engine)
        let pasteboard: NSPasteboard = NSPasteboard.general

        pasteboard.clearContents()

        pasteNumericalValue(numericalValue: "42")

        // mock up a menu command
        let invalidPasteMenuItem: NSMenuItem = makeMenuItemWithTitle("Invalid")

        XCTAssertEqual(false, dut.validateUserInterfaceItem(invalidPasteMenuItem))
    }


    func pasteNumericalValue(numericalValue: String)
    {
        let pasteObject: NSPasteboardWriting = numericalValue as NSPasteboardWriting
        NSPasteboard.general.writeObjects([pasteObject])
    }

    func stackValuesAsSpaceSeparatedString() -> String
    {
        var stackValues: [String] = [String]()

        for reg: Int in (0 ..< dut.engine.numberOfRegistersWithContent()).reversed()
        {
            let s: String = dut.engine.registerValue(inRegisterNumber: reg, radix: 10)
            stackValues.append(s)
        }

        dut.engine.userInputOperation(symbol: OperationCode.dropAll.rawValue)

        return stackValues.joined(separator: " ")
    }

    
    func makeMenuItemWithTitle(_ title: String) -> NSMenuItem
    {
        let item: NSMenuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        return item
    }
    
}
