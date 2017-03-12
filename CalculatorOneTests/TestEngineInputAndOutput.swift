//
//  TestEngineInputAndOutput.swift
//  CalculatorOne
//
//  Created by Andreas on 11/03/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineInputAndOutput: XCTestCase 
{
    var engineDUT: Engine!

    override func setUp() 
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        engineDUT = Engine()
        XCTAssertNotNil(engineDUT)
        
        engineDUT.userInputOperandType(OperandType.float.rawValue)        
    }
    
    override func tearDown() 
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    
    func testThatTheMethodUserWillInputEnterCorrectlyValidatesDecimalIntegerArguments()
    {
        engineDUT.userInputOperandType(OperandType.integer.rawValue)
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues = 
        [   "0", "-1", "1", "2",
            "-22", "333", "444", "-12345678"
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.decimal.value), true)
        }
        
        // test that string values are not accepted as valid decimal integer values
        testValues = 
            [   "-",            // not a number
                ".",            // not a number
                "-.",           // not a number
                "1.1",          // is a float
                "-0.1",         // is a float
                ".1",           // is a float
                "A",            // is a hexadecimal value
                "122121E"       // is a hexadecimal value
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.decimal.value), false)
        }

        
    }

    
    func testThatTheMethodUserWillInputEnterCorrectlyValidatesHexadecimalIntegerArguments()
    {
        engineDUT.userInputOperandType(OperandType.integer.rawValue)
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues = 
            [   "0", "-1", "1", "2",
                "-22", "333", "444", "-12345678",
                "-2A", "3EE33", "4B4", "-A12345678",                
                "F", "EE", "DDD", "CCC", "BBBB", "AAAAA", "000009AC"                
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.hex.value), true)
        }
        
        // test that string values are not accepted as valid decimal integer values
        testValues = 
            [   "-",            // not a number
                ".",            // not a number
                "-.",           // not a number
                "1.1",          // is a float
                "-0.1",         // is a float
                ".1",           // is a float
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.hex.value), false)
        }

    }

    func testThatTheMethodUserWillInputEnterCorrectlyValidatesBinaryIntegerArguments()
    {
        engineDUT.userInputOperandType(OperandType.integer.rawValue)
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues = 
            [   "0", "-1", "1", "-0", "+0", "000000", "11111111111",
            ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.binary.value), true)
        }
        
        // test that string values are not accepted as valid decimal integer values
        testValues = 
            [   "-",            // not a number
                ".",            // not a number
                "-.",           // not a number
                "1.1",          // is a float
                "-0.1",         // is a float
                ".1",           // is a float
                "-22", "333", "444", "-12345678",       // not binary
                "-2A", "3EE33", "4B4", "-A12345678",                
                "F", "EE", "DDD", "CCC", "BBBB", "AAAAA", "000009AC"                

                
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.binary.value), false)
        }
        
    }
    
    func testThatTheMethodUserWillInputEnterCorrectlyValidatesFloatArguments()
    {
        engineDUT.userInputOperandType(OperandType.float.rawValue)
        
        // test that string values describing floats can be correctly converted to float values
        var testValues = 
            [   "0", "-1", "1", "2",
                "-22", "333", "444", "-12345678", 
                "22.", "-22.1", "2.2", "-2.2", "-.22", 
                "-22.", "22.1", "-2.2", "2.2", ".22", 
                "+22.", "+22.1", "+2.2", "+.22", 
                "1E0", "1.1E1", ".1E3", "+4.444E33", 
                "-1E0", "-1.1E1", "-.1E3", "-4.444E33",                 
                "-1E-0", "-1.1E-1", "-.1E-3", "-4.444E-33",                 
                "-1e-0", "-1.1e-1", "-.1e-3", "-4.444e-33"
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.decimal.value), true)
        }
        
        // test that string values are not accepted as valid decimal integer values
        testValues = 
            [   "-",            // not a number
                ".",            // not a number
                "-.",           // not a number
                "-2A", "3EE33", "4B4", "-A12345678",                
                "E", "F", "EE", "DDD", "CCC", "BBBB", "AAAAA", "000009AC"                
            ]
        
        for testValue in testValues
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testValue, radix: Radix.decimal.value), false)
        }
        
        
    }


}


