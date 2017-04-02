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
    let accuracy = 1.0E-10   
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

    //--------< y^x >-------------------------------------------
    func testThatFloatOperationYExpXWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0       value1          value0^value1
            ("0.0",         "1.0",          "0.0"),
            ("0.0",         "0.0",          "1.0"),
            ("-100.0",      "0.0",          "1.0"),
            ("-2.0",        "2.0",          "4.0"),
            ("4.0",         "3.0",          "64.0"),
            ("1.0",         "10000.0",      "1.0"),
            ("5.0",         "-1.0",         "0.2"),
            ("123",         "0.123",        "1.80741685811"),
            
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: Symbols.yExpX.rawValue)
            
            let expectedResult = Double(test.2)
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

    
    //--------< y^x >-------------------------------------------
    func testThatFloatOperationLogXYWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0       value1          log value0, value1
            ("2.0",         "4.0",                  "2.0"),
            ("2.0",         "1.0",                  "0.0"),
            ("2.0",         "8.0",                  "3.0"),
            ("2.0",         "32.0",                 "5.0"),
            ("1.5",         "431439.883274",        "32.0"),
            ("0.1",         "1.0e50",               "-50"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: Symbols.logYX.rawValue)
            
            let expectedResult = Double(test.2)
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

    
    //--------< lb ln log >-------------------------------------------
    func testThatFloatOperationsLogarithmWorksMathematicallyCorrect()
    {
        let testSet = [
            // value            lb(value)               ln(value)               log(value)
            ("1.0",             "0.0",                  "0.0",                  "0.0"),
            ("2.0",             "1.0",                  "0.69314718056",        "0.301029995664"),
            ("2.71828182846",   "1.44269504089",        "1.0",                  "0.434294481903"),
            ("10.0",            "3.32192809488",        "2.30258509299",        "1.0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.log2.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: Symbols.logE.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            // -------

            engineDUT.userInputOperation(symbol: Symbols.log10.rawValue)
            
            expectedResult = Double(test.3)
            engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            // -------

        }
    }

    //--------< 1/x, 1/x*x >-------------------------------------------
    func testThatFloatOperationsReciprocalWorksMathematicallyCorrect()
    {
        let testSet = [
            // value            1/value                  1/(value * Value)
            ("1.0",             "1.0",                   "1.0"),
            ("-1.0",            "-1.0",                  "1.0"),
            ("2.0",             "0.5",                   "0.25"),
            ("-2.0",            "-0.5",                  "0.25"),
            ("0.1",             "10.0",                  "100.0"),
            ("-0.1",            "-10.0",                 "100.0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.reciprocal.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: Symbols.reciprocalSquare.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
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

    //--------< x*x, x*x*x >-------------------------------------------
    func testThatFloatOperationsSquareAndCubicWorksMathematicallyCorrect()
    {
        let testSet = [
            // value            value * value            value * Value * value)
            ("0.0",             "0.0",                   "0.0"),
            ("1.0",             "1.0",                   "1.0"),
            ("-1.0",            "1.0",                   "-1.0"),
            ("2.0",             "4.0",                   "8.0"),
            ("-2.0",            "4.0",                   "-8.0"),
            ("0.1",             "0.01",                  "0.001"),
            ("-0.1",            "0.01",                  "-0.001"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.square.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: Symbols.cubic.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
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

    
    //--------< Nth Root >-------------------------------------------
    func testThatFloatOperationNRootWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0       value1                  value0th-root of value1
            ("4.0",         "2.0",                  "2.0"),
            ("27.0",        "3.0",                  "3.0"),
            ("256.0",       "4.0",                  "4.0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: Symbols.nRoot.rawValue)
            
            let expectedResult = Double(test.2)
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
    
    //--------< 10 exp x >-----------------------------------------
    func testThatFloatOperationTenExpXWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0               10^value0
            ("0.0",                  "1.0"),
            ("0.5",                  "3.16227766016838"),
            ("-0.5",                 "0.316227766016838"),
            ("1.0",                  "10.0"),
            ("-1.0",                 "0.1"),
            ("1.5",                  "31.6227766016838"),
            ("-1.5",                 "0.0316227766016838"),
            ("2.0",                  "100.0"),
            ("-2.0",                 "0.01"),
            ("2.5",                  "316.227766016838"),
            ("-2.5",                 "0.00316227766016838"),
            ("3.0",                  "1000.0"),
            ("-3.0",                 "0.001"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.tenExpX.rawValue)
            
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

    //--------< 2 exp x >-----------------------------------------
    func testThatFloatOperationTwoExpXWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0                2^value0
            ("0.0",                  "1.0"),
            ("0.5",                  "1.41421356237"),
            ("-0.5",                 "0.707106781187"),
            ("1.0",                  "2.0"),
            ("-1.0",                 "0.5"),
            ("1.5",                  "2.82842712475"),
            ("-1.5",                 "0.353553390593"),
            ("2.0",                  "4.0"),
            ("-2.0",                 "0.25"),
            ("2.5",                  "5.65685424949"),
            ("-2.5",                 "0.176776695297"),
            ("3.0",                  "8.0"),
            ("-3.0",                 "0.125"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.twoExpX.rawValue)
            
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
    

    
    //--------< sin x, asin x>-----------------------------------------
    func testThatFloatOperationSinusWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0               sin value0              asin(sin(value0)
            ("0.0",                 "0.0",                  "0.0"),
            ("1.5707963268",        "1.0",                  "1.5707963268"),        // pi/2
            ("3.14159265359",       "0.0",                  "0.0"),                 // pi
            ("4.71238898038",       "-1.0",                 "-1.5707963268"),       // 3pi/2
            ("6.28318530718",       "0.0",                  "0.0"),                 // 2pi
            ("-1.5707963268",       "-1.0",                 "-1.5707963268"),       // -pi/2
            ("-3.14159265359",      "0.0",                  "0.0"),                 // -pi
            ("-4.71238898038",      "1.0",                  "1.5707963268"),        // -3pi/2
            ("-6.28318530718",      "0.0",                  "0.0"),                 // -2pi
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.sinus.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: Symbols.asinus.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqualWithAccuracy(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
        }
    }

    //--------< cos x >-----------------------------------------
    func testThatFloatOperationCosinusWorksMathematicallyCorrect()
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
    
    //--------< tangens x >-----------------------------------------
    func testThatFloatOperationTangensWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0               tan value0
            ("-1",                  "-1.55740772465"),
            ("-0.2",                "-0.202710035509"),
            ("-0.1",                "-0.100334672085"),
            ("0.0",                 "0.0"),
            ("0.1",                 "0.100334672085"),
            ("0.2",                 "0.202710035509"),
            ("1",                   "1.55740772465"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.tangens.rawValue)
            
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
    
    //--------< tangens x >-----------------------------------------
    func testThatFloatOperationCotangensWorksMathematicallyCorrect()
    {
        let testSet = [
            // value0               cot value0
            ("-1",                  "-0.642092615936"),
            ("-0.2",                "-4.93315487558"),
            ("-0.1",                "-9.9666444233"),
            ("0.1",                 "9.9666444233"),
            ("0.2",                 "4.93315487558"),
            ("1",                   "0.642092615936"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: Symbols.cotangens.rawValue)
            
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



    //--------< sum stack >-----------------------------------------
    func testThatFloatSumOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values     // sum of values
            (["0"],         "0.0"),
            (["1", "1"],    "2.0"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0.0"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "945.0"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.sum.rawValue)
            result = engineDUT.registerValue(registerNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
        
        
        // test the sum of all integers from 1 to 100: expected result = 5050
        for value: Int in 1...100
        {
            engineDUT.userInputEnter(numericalValue: String(value), radix: 10)
        }
        
        engineDUT.userInputOperation(symbol: Symbols.sum.rawValue)
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 1)
        XCTAssertEqual(String(engineDUT.registerValue(registerNumber: 0, radix: 10)), "5050.0")
        
        engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        
    }
    
    //--------< sum stack >-----------------------------------------
    func testThatFloatAverageOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values     // average of values
            (["0"],         "0.0"),
            (["1", "1"],    "1.0"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0.0"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "94.5"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.avg.rawValue)
            result = engineDUT.registerValue(registerNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
        
    }

    //--------< product stack >-----------------------------------------
    func testThatFloatProductOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values     // product of values
            (["0"],         "0.0"),
            (["1", "1"],    "1.0"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0.0"),
            (["90", "91", "92", "93", "94", "95"],    "625757605200.0"),
            (["-1.1", "1.2", "-1.3", "1.4", "-1.5"],    "-3.6036"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.product.rawValue)
            result = engineDUT.registerValue(registerNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
        
    }

    
    //--------< square root >-----------------------------------------
    func testThatFloatSquareRootOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values           // root of value
            ("0",               "0.0"),
            ("1",               "1.0"),
            ("2",               "1.41421356237"),
            ("4",               "2.0"),
            ("40",              "6.32455532034"),
            ("6.32455532034",   "2.51486685937"),
          ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.root.rawValue)
            
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


    //--------< third root >-----------------------------------------
    func testThatFloatThirdRootOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values           // third root of value
            ("0",               "0.0"),
            ("1",               "1.0"),
            ("2",               "1.25992104989"),
            ("8",               "2.0"),
            ("40",              "3.41995189335"),
            ("3.41995189335",   "1.50663019029"),
            ("27",              "3.0"),
            ("-27",             "-3.0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.thridRoot.rawValue)
            
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

    
    //--------< geometrical mean of stack >-----------------------------------------
    func testThatFloatGeometricalMeanOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values       // geometrical of values
            (["0"],         "0.0"),
            (["1", "1"],    "1.0"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0.0"),
            (["2", "4", "6"],                                      "3.63424118566"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "94.4563234524"),
            ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.geoMean.rawValue)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
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

    //--------< variance of stack >-----------------------------------------
    func testThatFloatVarianceOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values                             // variance of values
            (["0.0", "0.0"],                      "0.0"),
            (["1.0", "1.0"],                      "0.0"),
            (["1", "1", "2", "2", "2", "2", "2", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "5", "5", "6"],                                     "1.64761904761905")
            ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.variance.rawValue)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
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

    //--------< standard deviation of stack >-----------------------------------------
    func testThatFloatStandardDeviationOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet = [
            // values                             // variance of values
            (["0.0", "0.0"],                      "0.0"),
            (["1.0", "1.0"],                      "0.0"),
            (["1", "1", "2", "2", "2", "2", "2", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "5", "5", "6"],                                     "1.28359613882991")
        ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: Symbols.sigma.rawValue)
            let engineResult   = Double(engineDUT.registerValue(registerNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
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


