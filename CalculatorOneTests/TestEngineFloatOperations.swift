//
//  TestEngineFloatOperations.swift
//  CalculatorOne
//
//  Created by Andreas on 11/03/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineFloatOperations: XCTestCase 
{
    var engineDUT: Engine!
    let accuracy = 5.0E-11   
    let exact    = 0.0
    
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
    
    func testThatOperation_π_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.π.rawValue)
        XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value), "3.14159265358979")
    }
    
    func testThatOperation_e_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.e.rawValue)
        
        let engineResult = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("2.718281828459045235360287471352662497757247093")
        
        if let engineResult = engineResult, 
           let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_µ0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.µ0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("12.566370614E-7")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_epsilon0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.epsilon0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("8.854187817E-12")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_c0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.c0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("2.99792458E8")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }
    
    func testThatOperation_h_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.h.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("6.62607004081E-34")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_k_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.k.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("1.3806485279E-23")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_g_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.g.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("9.80665")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_G_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: Symbols.G.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("6.6740831E-11")
                
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqualWithAccuracy(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    
    func testThatFloatOperationAddWorksMathematicallyCorrect()
    {
        let testSet = [
            ("1.0", "2.0", "3.0"),
            ("10", "20", "30.0"),        
            ("100", "200", "300.0"),
            ("-100", "100", "0.0"),
            ("-123456789", "987654321", "864197532.0"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.plus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }


    func testThatFloatOperationMultiplyWorksMathematicallyCorrect()
    {
        let testSet = [
            ("1.0", "2.0", "2.0"),
            ("10", "20", "200.0"),        
            ("100", "200", "20000.0"),
            ("-100", "100", "-10000.0"),
            ("-123456789", "987654321", "-1.21932631112635e+17"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.multiply.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
    func testThatFloatOperationSubractWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0   value1      value0 - value1
            ("1.0",     "2.0",      "-1.0"),
            ("10",      "20",       "-10.0"),        
            ("100",     "200",      "-100.0"),
            ("100",    "100",       "0.0"),
            ("-123456789", "987654321", "-1111111110.0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.minus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
    func testThatFloatOperationDivistionWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0   value1      value0 / value1
            ("1.0",     "2.0",      "0.5"),
            ("10",      "20",       "0.5"),        
            ("100",     "200",      "0.5"),
            ("100",    "100",       "1.0"),
            ("-123456789", "987654321", "-0.124999998860938"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.divide.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    //--------< e^x >-------------------------------------------
    func testThatFloatOperationEExpXWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0   e^value0
            ("0.0",     "1.0"),
            ("1.0",     "2.71828182846"),
            ("-1.0",    "0.367879441171"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: "eˣ")
            
            let expectedResult = Double(test.1)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
               let engineResult   = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
    //--------< sin x >-----------------------------------------
    func testThatFloatOperationSinusWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0              cos value0
            ("0.0",                 "0.0"),
            ("1.5707963268",        "1.0"),                 // pi/2
            ("3.14159265359",       "0.0"),                 // pi
            ("4.71238898038",       "-1.0"),                // 3pi/2
            ("6.28318530718",       "0.0"),                 // 2pi
            ("-1.5707963268",       "-1.0"),                // -pi/2
            ("-3.14159265359",      "0.0"),                 // -pi
            ("-4.71238898038",      "1.0"),                 // -3pi/2
            ("-6.28318530718",      "0.0"),                 // -2pi
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: "sin")
            
            let expectedResult = Double(test.1)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    //--------< cos x >-----------------------------------------
    func testThatFloatOperationcosinusWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0               cos value0
            ("0.0",                 "1.0"),
            ("1.5707963268",        "0.0"),                 // pi/2
            ("3.14159265359",       "-1.0"),                // pi
            ("4.71238898038",       "0.0"),                 // 3pi/2
            ("6.28318530718",       "1.0"),                 // 2pi
            ("-1.5707963268",       "0.0"),                 // -pi/2
            ("-3.14159265359",      "-1.0"),                // -pi
            ("-4.71238898038",      "0.0"),                 // -3pi/2
            ("-6.28318530718",      "1.0"),                 // -2pi
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: "cos")
            
            let expectedResult = Double(test.1)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
}


