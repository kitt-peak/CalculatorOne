//
//  TestEngineOperandChange.swift
//  CalculatorOne
//
//  Created by Andreas on 05/03/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineOperandChange: XCTestCase {

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


    func testThatStackOperandTypeFloatChangesCorrectlyToInteger_ForOneNumber()
    {
        let testSet = [
            // .float       .integer
            ("1.1",         "1"),
            ("-1.1",        "-1"),
            ("0",           "0"),
            ("-0.0",        "0"),
            ("0.9",         "0"),
            ("-0.9",        "0"),
            ("-1.9",        "-1"),
            ("987.654321",  "987"),
        ]

        
        for test in testSet
        {
            // start the test with calculator in .float mode
            engineDUT.userInputOperandType(OperandType.float.rawValue)        

            // enter a .float number
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)

            // convert the stack to .integer
            engineDUT.userInputOperandType(OperandType.float.rawValue)        

            // test for correct conversion
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: 10), test.1)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
    func testThatStackOperandTypeFloatChangesCorrectlyToInteger_ForTheEntireStack()
    {
        let testSet = [
            // .float                                   .integer
            (["1.1", "1.1"],                            ["1", "1"]),
            (["-1.1","-2.1"],                           ["-1", "-2"]),
            (["-1.1","2.1","3.55"],                     ["-1", "2", "3"]),
            (["-9","3.145","0.000431","-9","3.145"],    ["-9", "3", "0", "-9", "3"]),
            ]
        
        
        for test in testSet
        {
            // start the test with calculator in .float mode
            engineDUT.userInputOperandType(OperandType.float.rawValue)        
            
            // enter several .float numbers
            for floatValue in test.0
            {
                engineDUT.userInputEnter(numericalValue: floatValue, radix: 10)
            }
            
            // convert the stack to .integer
            engineDUT.userInputOperandType(OperandType.float.rawValue)        
            
            // test for correct conversion
            for (index, integerValue) in test.1.enumerated()
            {
                XCTAssertEqual(engineDUT.registerValue(registerNumber: test.1.count - index - 1, radix: 10), integerValue)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.dropAll.rawValue)
        }
    }
    
    
    func testThatStackOperandTypeIntegerChangesCorrectlyToFloat_ForOneNumber()
    {
        let testSet = [
            // .integer     .float
            ("1",           "1.0"),
            ("-1",          "-1.0"),
            ("0",           "0.0"),
            ("-0",          "0.0"),
            ("-9",          "-9.0"),
            ("23423423",    "23423423.0"),
            ("987",         "987.0"),
            ]
        
        
        for test in testSet
        {
            // start the test with calculator in .integer mode
            engineDUT.userInputOperandType(OperandType.integer.rawValue)        
            
            // enter a .integer number
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            
            // convert the stack to .float
            engineDUT.userInputOperandType(OperandType.float.rawValue)        
            
            // test for correct conversion
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: 10), test.1)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }


}
