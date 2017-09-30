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
        
    }
    
    override func tearDown() 
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testThatTheMethodUserWillEnterInputCorrectlyAcceptsLargeHexaDecimalIntegerArguments()
    {
        // values are regular hexadecimal numbers
        let testArguments: [String] = 
                            [ "FFFF", "FFFFFFFF", 
                              "+7FFFFFFFFFFFFFFF", /* largest acceptable positive hexadecimal number */
                              "-8000000000000000", /* largest acceptable negative hexadecimal number */]
        
        for testArgument in testArguments
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testArgument, radix: Radix.hex.value), true)
        }
    }

    func testThatTheMethodUserWillEnterInputCorrectlyRejectsHexaDecimalIntegerArgumentsThatAreTooLarge()
    {
        // values are regular hexadecimal numbers, but too long for the calculator to accept (these are longer than 64 bit)
        let testArguments: [String] = 
            [ "FFFFFFFFFFFFFFFF", /* too large positive hexadecimal number, >64 bit */
              "-FFFFFFFFFFFFFFFF", /* too large negative hexadecimal number, >64 bit */]
        
        for testArgument in testArguments
        {
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testArgument, radix: Radix.hex.value), false)
        }
    }

    func testThatALargeHexaDecimalNumberIsInternallyRepresentedAsIntegerAndAsFloatingPoint()
    {
        let testArguments: [(String, Bool, Bool)] = 
        [   
             // argument           isInteger    isFloatingPoint
//             ("7FFFFFFFFFFFFFFF",  true,        false),  /* largest integer, has no exact representation as floating point */
//             ("-8000000000000000", true,        true),   /* smallest integer, has a exact representation as floating point */
             ("0",                 true,        true),
             ("-10000",            true,        true),
             ("123456789",         true,        true),
             ("-123456789",        true,        true),
             (String(Int32.max),   true,        true),
             (String(Int32.min),   true,        true),
             (String(Int64.max),   true,        false),
             (String(Int64.min),   true,        true),
        ]
        
        let radix: Int = Radix.decimal.value
        
        for testArgument in testArguments 
        {
            // argument must be acceptable by engine
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testArgument.0, radix: radix), true)
            
            // write argument into engine
            engineDUT.userInputEnter(numericalValue: testArgument.0, radix: radix)
            
            // read back from engine
            let engineRegisterContent: String = engineDUT.registerValue(inRegisterNumber: 0, radix: radix)
            
            // compare. If the engine stores the test argument as floating point, the read back value would not match the test argument
            XCTAssertEqual(testArgument.0, engineRegisterContent)
                        
            engineDUT.userInputOperation(symbol: Symbols.dropAll.rawValue)
        }
    }

    
    func testThatFractionalNumberIsInternallyRepresentedAsFloatingPointAndNotAsInteger()
    {
        // some numbers, for instanceINT.max, does not have an integer representation, which is tested here
        // other numbers, for instance 3.45 have fractional therefore are no 
        let testArguments: [(String, Bool, Bool)] = 
            [   
                // argument           isInteger    isFloatingPoint
                ("0.1",               false,        true),  
                ("-3.45",             false,        true),  
                ("-1e-07",            false,        true),
        ]
        
        for testArgument in testArguments 
        {
            // argument must be acceptable by engine
            XCTAssertEqual(engineDUT.userWillInputEnter(numericalValue: testArgument.0, radix: Radix.decimal.value), true)
            
            // write argument into engine
            engineDUT.userInputEnter(numericalValue: testArgument.0, radix: Radix.decimal.value)
            
            // read back from engine
            let engineRegisterContent: String = engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value)
            
            // compare. If the engine stores the test argument as floating point, the read back value would not match the test argument
            XCTAssertEqual(testArgument.0, engineRegisterContent)
                        
            engineDUT.userInputOperation(symbol: Symbols.dropAll.rawValue)
        }
    }

    
    
    func testThatTheMethodUserWillInputEnterCorrectlyValidatesDecimalIntegerArguments()
    {
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues: [String] = 
        [   "0", "-1", "1", "2",
            "-22", "333", "444", "-12345678",
            "1E0", "-1E0", "1E1", "-1E1", "-1E-1", "1E-1"
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
                //"1.1",          // is a float
                //"-0.1",         // is a float
                //".1",           // is a float
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
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues: [String] = 
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
        
        // test that string values describing integers can be correctly converted to integer values
        var testValues: [String] = 
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
        
        // test that string values describing floats can be correctly converted to float values
        let testValues: [String] = 
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
        
    }
    
    func testThatTheMethodUserWillInputEnterCorrectlyRejectsInvalidDecimalIntegerArguments()
    {
        // test that string values are not accepted as valid decimal integer values
        let testValues = 
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


    func testThatTheMethodUserInputEnterDoesNotAcceptIllegalArguments()
    {
        // list of illegal input arguments for the engine
        let illegalArguments: [String] =
        [
            "", " ", "?",
            "3E", "E3", "1E-23333",
            "-", "+",
            "EXP", "-EXP", "E", "+E", "-E",
            ".", ","
        ]
        
        for illegalArgument in illegalArguments
        {
            engineDUT.userInputEnter(numericalValue: illegalArgument, radix: Radix.decimal.value)
            XCTAssertEqual(engineDUT.hasValueForRegister(registerNumber: 0), false)
        }
        
        
    }
    
}


