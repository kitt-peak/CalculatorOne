//
//  TestEngineConverterOperations.swift
//  CalculatorOne
//
//  Created by Andreas on 15.08.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne


class TestEngineConverterOperations: XCTestCase 
{

    var engineDUT: Engine!
    
    let accuracy = 1E-16
    let exact    = 0.0
    
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


    func testThatFECRateConversionM33D32WorksCorrectly()
    {
        let testValues : [(String, String)] = 
        [
            // value       value*33/32
            ("125",         "128.90625"),
            ("156.25",      "161.1328125"),
            ("625",         "644.53125"),
        ]

        for testValue in testValues
        {
            engineDUT.userInputEnter(numericalValue: testValue.0, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: Symbols.multiply66divide64.rawValue)
            
            let expectedResult = Double(testValue.1)
            let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }

            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }
    
    func testThatFECRateConversionM32D33WorksCorrectly()
    {
        let testValues : [(String, String)] = 
            [
                // value       value*32/33
                ("128.90625",           "125"),
                ("161.1328125",         "156.25"),
                ("644.53125",           "625"),
            ]
        
        for testValue in testValues
        {
            engineDUT.userInputEnter(numericalValue: testValue.0, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: Symbols.multiply64divide66.rawValue)
            
            let expectedResult = Double(testValue.1)
            let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
}
