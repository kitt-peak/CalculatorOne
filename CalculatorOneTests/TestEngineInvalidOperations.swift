//
//  TestEngineInvalidOperations.swift
//  CalculatorOneTests
//
//  Created by Andreas on 01.10.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineInvalidOperations: XCTestCase 
{
    var engineDUT: Engine!
    
    override func setUp() 
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        engineDUT = Engine()
        XCTAssertNotNil(engineDUT)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatInvalidEngineOperationsCauseNoError()
    {
        XCTAssertNoThrow(engineDUT.userInputOperation(symbol: "notAnOperation"))
    }

    func testThatInvalidEngineOperationsLeavesTheEngineStateUnchanged()
    {
        let testSets: [String] =
        [
            "notAnOperation", "", "0", "1", "-1",
            "XOR", "-", "A", "a", "0", "0.0", ".", ".0"
        ]
        
        for testSet in testSets 
        {
            engineDUT.userInputOperation(symbol: testSet)
            
            XCTAssertEqual( engineDUT.numberOfRegistersWithContent() == 0, true )
            XCTAssertEqual( engineDUT.canUndo(), false )
            XCTAssertEqual( engineDUT.canRedo(), false )
            XCTAssertEqual( engineDUT.isMemoryAEmpty(), true )
            XCTAssertEqual( engineDUT.isMemoryBEmpty(), true )            
        }
        
    }

}
