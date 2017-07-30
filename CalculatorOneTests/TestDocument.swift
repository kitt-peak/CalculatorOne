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
    
    func testThatStartUpObjectsAreCreated()
    {
        
    }
    
    func testThatACreatedDocumentLoadsADefaultConfigurationIntoItsSaveDataSet()
    {
        XCTAssertEqual(dut.currentSaveDataSet.isEmpty, false)
        
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.stackValues.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue])
        //        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.radix.rawValue])
        XCTAssertNotNil(dut.currentSaveDataSet[Document.ConfigurationKey.extraOperationsViewYPosition.rawValue])        
    }
    

    

}
