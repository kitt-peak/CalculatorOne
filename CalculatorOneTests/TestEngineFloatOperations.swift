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
        
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatOperation_π_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.π.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "3.14159265358979")
    }
    
    func testThatOperation_e_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.e.rawValue)
        
        let engineResult = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("2.718281828459045235360287471352662497757247093")
        
        if let engineResult = engineResult, 
           let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_µ0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.µ0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("12.566370614E-7")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_epsilon0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.epsilon0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("8.854187817E-12")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: accuracy)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_c0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.c0.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("2.99792458E8")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }
    
    func testThatOperation_h_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.h.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("6.62607004081E-34")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_k_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.k.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("1.3806485279E-23")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_g_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.g.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("9.80665")
        
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    func testThatOperation_G_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.G.rawValue)
        
        let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
        let expectedResult = Double("6.6740831E-11")
                
        if let engineResult = engineResult, 
            let expectedResult = expectedResult
        {
            XCTAssertEqual(engineResult, expectedResult, accuracy: exact)           
        }
        else
        {
            XCTFail("Test failure: could not convert string value to Double value")   
        }
    }

    
    func testThatOperation_Const7M68_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const7M68.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "7680000")
    }

    func testThatOperation_Const30M72_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const30M72.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "30720000")
    }

    func testThatOperation_Const122M88_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const122M88.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "122880000")
    }

    func testThatOperation_Const153M6_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const153M6.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "153600000")
    }

    func testThatOperation_Const245M76_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const245M76.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "245760000")
    }

    func testThatOperation_Const386M64_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const368M64.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "368640000")
    }

    func testThatOperation_Const25M0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const25M0.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "25000000")
    }

    func testThatOperation_Const100M0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const100M0.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "100000000")
    }

    func testThatOperation_Const156M25_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const156M25.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "156250000")
    }

    func testThatOperation_Const125M0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const125M0.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "125000000")
    }

    func testThatOperation_Const1966M08_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const1966M08.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "1966080000")
    }
    
    func testThatOperation_Const2456M7_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const2457M6.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "2457600000")
    }
    
    func testThatOperation_Const2949M12_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const2949M12.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "2949120000")
    }
    
    func testThatOperation_Const3072M0_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const3072M0.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "3072000000")
    }

    func testThatOperation_Const3686M4_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const3868M4.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "3686400000")
    }

    func testThatOperation_Const3932M16_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const3932M16.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "3932160000")
    }

    func testThatOperation_Const4915M2_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const4915M2.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "4915200000")
    }
    
    func testThatOperation_Const5898M24_WorksMathematicallyCorrect()
    {
        engineDUT.userInputOperation(symbol: OperationCode.const5898M24.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "5898240000")
    }

    
    
    
    func testThatOperationAddWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("1", "2", "3"),
            ("10", "20", "30"),        
            ("100", "200", "300"),
            ("-100", "100", "0"),
            ("-123456789", "987654321", "864197532"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.plus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }


    func testThatOperationMultiplyWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("1", "2", "2"),
            ("10", "20", "200"),        
            ("100", "200", "20000"),
            ("-100", "100", "-10000"),
            ("-123456789", "987654321", "-121932631112635264"),
            //            ("-123456789", "987654321", "-1.21932631112635e+17")
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.multiply.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
    func testThatOperationSubractWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0   value1      value0 - value1
            ("1",     "2",      "-1"),
            ("10",      "20",       "-10"),        
            ("100",     "200",      "-100"),
            ("100",    "100",       "0"),
            ("-123456789", "987654321", "-1111111110"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.minus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
    func testThatOperationDivistionWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0   value1      value0 / value1
            ("1",     "2",      "0.5"),
            ("10",      "20",       "0.5"),        
            ("100",     "200",      "0.5"),
            ("100",    "100",       "1"),
            ("-123456789", "987654321", "-0.124999998860938"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.divide.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), test.2)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    //--------< e^x >-------------------------------------------
    func testThatOperationEExpXWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // value0   e^value0
            ("0",     "1"),
            ("1",     "2.71828182846"),
            ("-1",    "0.367879441171"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: "eˣ")
            
            let expectedResult = Double(test.1)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    //--------< y^x >-------------------------------------------
    func testThatOperationYExpXWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0       value1          value0^value1
            ("0",         "1",          "0"),
            ("0",         "0",          "1"),
            ("-100",      "0",          "1"),
            ("-2",        "2",          "4"),
            ("4",         "3",          "64"),
            ("1",         "10000",      "1"),
            ("5",         "-1",         "0.2"),
            ("123",         "0.123",        "1.80741685811"),
            
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: OperationCode.yExpX.rawValue)
            
            let expectedResult = Double(test.2)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
    //--------< y^x >-------------------------------------------
    func testThatOperationLogXYWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value1       value0          log value0, value1
            ("2",         "4",                  "2"),
            ("2",         "1",                  "0"),
            ("2",         "8",                  "3"),
            ("2",         "32",                 "5"),
            ("1.5",         "431439.883274",        "32"),
            ("0.1",         "1.0e50",               "-50"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: OperationCode.logYX.rawValue)
            
            let expectedResult = Double(test.2)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
    //--------< lb ln log >-------------------------------------------
    func testThatOperationsLogarithmWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String, String)] = [
            // value            lb(value)               ln(value)               log(value)
            ("1",             "0",                  "0",                  "0"),
            ("2",             "1",                  "0.69314718056",        "0.301029995664"),
            ("2.71828182846",   "1.44269504089",        "1",                  "0.434294481903"),
            ("10",            "3.32192809488",        "2.30258509299",        "1"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.dup.rawValue)
            engineDUT.userInputOperation(symbol: OperationCode.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: OperationCode.log2.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: OperationCode.logE.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            // -------

            engineDUT.userInputOperation(symbol: OperationCode.log10.rawValue)
            
            expectedResult = Double(test.3)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            // -------

        }
    }

    //--------< 1/x, 1/x*x >-------------------------------------------
    func testThatOperationsReciprocalWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value            1/value                  1/(value * Value)
            ("1",             "1",                   "1"),
            ("-1",            "-1",                  "1"),
            ("2",             "0.5",                   "0.25"),
            ("-2",            "-0.5",                  "0.25"),
            ("0.1",             "10",                  "100"),
            ("-0.1",            "-10",                 "100"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: OperationCode.reciprocal.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: OperationCode.reciprocalSquare.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)

        }
    }

    //--------< x*x, x*x*x >-------------------------------------------
    func testThatOperationsSquareAndCubicWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value            value * value            value * Value * value)
            ("0",             "0",                   "0"),
            ("1",             "1",                   "1"),
            ("-1",            "1",                   "-1"),
            ("2",             "4",                   "8"),
            ("-2",            "4",                   "-8"),
            ("0.1",             "0.01",                  "0.001"),
            ("-0.1",            "0.01",                  "-0.001"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: OperationCode.square.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            // -------
            
            engineDUT.userInputOperation(symbol: OperationCode.cubic.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    
    //--------< Nth Root >-------------------------------------------
    func testThatOperationNRootWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0       value1                  value0th-root of value1
            ("4",         "2",                  "2"),
            ("27",        "3",                  "3"),
            ("256",       "4",                  "4"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: test.1, radix: Radix.decimal.value)
            
            engineDUT.userInputOperation(symbol: OperationCode.nRoot.rawValue)
            
            let expectedResult = Double(test.2)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }
    
    //--------< 10 exp x >-----------------------------------------
    func testThatOperationTenExpXWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // value0               10^value0
            ("0",                  "1"),
            ("0.5",                  "3.16227766016838"),
            ("-0.5",                 "0.316227766016838"),
            ("1",                  "10"),
            ("-1",                 "0.1"),
            ("1.5",                  "31.6227766016838"),
            ("-1.5",                 "0.0316227766016838"),
            ("2",                  "100"),
            ("-2",                 "0.01"),
            ("2.5",                  "316.227766016838"),
            ("-2.5",                 "0.00316227766016838"),
            ("3",                  "1000"),
            ("-3",                 "0.001"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.tenExpX.rawValue)
            
            let expectedResult = Double(test.1)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    //--------< 2 exp x >-----------------------------------------
    func testThatOperationTwoExpXWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // value0                2^value0
            ("0",                  "1"),
            ("0.5",                  "1.41421356237"),
            ("-0.5",                 "0.707106781187"),
            ("1",                  "2"),
            ("-1",                 "0.5"),
            ("1.5",                  "2.82842712475"),
            ("-1.5",                 "0.353553390593"),
            ("2",                  "4"),
            ("-2",                 "0.25"),
            ("2.5",                  "5.65685424949"),
            ("-2.5",                 "0.176776695297"),
            ("3",                  "8"),
            ("-3",                 "0.125"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.twoExpX.rawValue)
            
            let expectedResult = Double(test.1)
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
            
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }
    

    
    //--------< sin x, asin x>-----------------------------------------
    func testThatOperationSinusWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0               sin value0              asin(sin(value0)
            ("0",                 "0",                  "0"),
            ("1.5707963267949",     "1",                  "1.5707963267949"),        // pi/2
            ("3.14159265358979",    "0",                  "0"),                 // pi
            ("4.71238898038469",    "-1",                 "-1.5707963267949"),       // 3pi/2
            ("6.28318530717959",    "0",                  "0"),                 // 2pi
            ("-1.5707963267949",    "-1",                 "-1.5707963267949"),       // -pi/2
            ("-3.14159265358979",   "0",                  "0"),                 // -pi
            ("-4.71238898038469",   "1",                  "1.5707963267949"),        // -3pi/2
            ("-6.28318530717959",   "0",                  "0"),                 // -2pi
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.sinus.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.asinus.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
        }
    }

    //--------< cos x, acos x>-----------------------------------------
    func testThatOperationCosinusWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0               cos value0              acos(cos(value0))
            ("0",                 "1",                  "0"),
            ("1.5707963267949",     "0",                  "1.5707963267949"),         // pi/2
            ("3.14159265358979",    "-1",                 "3.14159265358979"),        // pi
            ("4.71238898038469",    "0",                  "1.5707963267949"),         // 3pi/2
            ("6.28318530717959",    "1",                  "0"),                     // 2pi
            ("-1.5707963267949",    "0",                  "1.5707963267949"),         // -pi/2
            ("-3.14159265358979",   "-1",                 "3.14159265358979"),        // -pi
            ("-4.71238898038469",   "0",                  "1.5707963267949"),         // -3pi/2
            ("-6.28318530717959",   "1",                  "0"),                     // -2pi
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.cosinus.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.acosinus.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
        }
    }
    
    //--------< tan x, atan x>-----------------------------------------
    func testThatOperationTangensWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0               tan value0                  atan(tan(value0))
            ("0",                 "0",                      "0"),
            ("1",                 "1.5574077246549",          "1"),
            ("2",                 "-2.18503986326152",        "-1.14159265358979"),
            ("3",                 "-0.142546543074278",       "-0.141592653589793"),
            ("4",                 "1.15782128234958",         "0.858407346410207"),
            ("5",                 "-3.38051500624658",        "-1.28318530717959"),
            ("-1",                "-1.5574077246549",         "-1"),
            ("-2",                "2.18503986326152",         "1.14159265358979"),
            ("-3",                "0.142546543074278",        "0.141592653589793"),
            ("-4",                "-1.15782128234958",        "-0.858407346410207"),
            ("-5",                "3.38051500624658",         "1.28318530717959"),            
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.tangens.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.atangens.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
        }
    }
    
    //--------< cot x, acotan x>-----------------------------------------
    func testThatOperationCotangensWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0               cot value0                  acot(cot(value0))
            ("1",                 "0.642092615934331",        "1"),
            ("2",                 "-0.457657554360286",       "2"),
            ("3",                 "-7.01525255143453",        "3"),
            ("4",                 "0.863691154450617",        "0.858407346410207"),
            ("5",                 "-0.295812915532746",       "1.858407346410207"),
            ("-1",                "-0.642092615934331",       "2.14159265358979"),
            ("-2",                "0.457657554360286",        "1.14159265358979"),
            ("-3",                "7.01525255143453",         "0.141592653589793"),
            ("-4",                "-0.863691154450617",       "2.28318530717959"),
            ("-5",                "0.295812915532746",        "1.28318530717959"),            
            ]

        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: Radix.decimal.value)
            engineDUT.userInputOperation(symbol: OperationCode.cotangens.rawValue)
            
            var expectedResult = Double(test.1)
            var engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.acotangens.rawValue)
            
            expectedResult = Double(test.2)
            engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
        }
    }


    //--------< sum stack >-----------------------------------------
    func testThatFloatSumOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values     // sum of values
            (["0"],         "0"),
            (["1", "1"],    "2"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "945"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.sum.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)            
        }
        
        
        // test the sum of all integers from 1 to 100: expected result = 5050
        for value: Int in 1...100
        {
            engineDUT.userInputEnter(numericalValue: String(value), radix: 10)
        }
        
        engineDUT.userInputOperation(symbol: OperationCode.sum.rawValue)
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 1)
        XCTAssertEqual(String(engineDUT.registerValue(inRegisterNumber: 0, radix: 10)), "5050")
        
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
    }
    
    //--------< sum n arguments from stack >-----------------------------------------
    func testThatFloatSumOfNArgumentsFromStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String, String)] = [
            // values               // N            // results: sum of N values
            (["0"],                 "1",             "0"),
            (["1", "1"],            "2",             "2"),
            (["10", "1"],           "1",             "1"),
            (["1",  "2", "3"],      "0",             "0"),
            (["1",  "2", "3"],      "1",             "3"),
            (["1",  "2", "3"],      "2",             "5"),
            (["1",  "2", "3"],      "3",             "6"),

//            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0"),
//            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "945"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            // enter arguments
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            // enter the numbers of arguments for the sum function to take from the stack
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            
            // enter the operation
            engineDUT.userInputOperation(symbol: OperationCode.nSum.rawValue)

            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2)
            engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)            
        }
        
        
        // test the sum of all integers from 1 to 100: expected result = 5050
        for value: Int in 1...100
        {
            engineDUT.userInputEnter(numericalValue: String(value), radix: 10)
        }
        
        engineDUT.userInputOperation(symbol: OperationCode.sum.rawValue)
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 1)
        XCTAssertEqual(String(engineDUT.registerValue(inRegisterNumber: 0, radix: 10)), "5050")
        
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
    }

    
    //--------< sum stack >-----------------------------------------
    func testThatFloatAverageOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values     // average of values
            (["0"],         "0"),
            (["1", "1"],    "1"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "94.5"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.avg.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)            
        }
        
    }

    //--------< product stack >-----------------------------------------
    func testThatFloatProductOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values     // product of values
            (["0"],         "0"),
            (["1", "1"],    "1"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0"),
            (["90", "91", "92", "93", "94", "95"],    "625757605200"),
            (["-1.1", "1.2", "-1.3", "1.4", "-1.5"],    "-3.6036"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.product.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)            
        }
        
    }

    
    //--------< square root >-----------------------------------------
    func testThatFloatSquareRootOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // values           // root of value
            ("0",               "0"),
            ("1",               "1"),
            ("2",               "1.41421356237"),
            ("4",               "2"),
            ("40",              "6.32455532034"),
            ("6.32455532034",   "2.51486685937"),
          ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: OperationCode.root.rawValue)
            
            let expectedResult = Double(test.1)
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
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
        
    }


    //--------< third root >-----------------------------------------
    func testThatFloatThirdRootOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // values           // third root of value
            ("0",               "0"),
            ("1",               "1"),
            ("2",               "1.25992104989"),
            ("8",               "2"),
            ("40",              "3.41995189335"),
            ("3.41995189335",   "1.50663019029"),
            ("27",              "3"),
            ("-27",             "-3"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: OperationCode.thridRoot.rawValue)
            
            let expectedResult = Double(test.1)
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
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
        
    }

    
    //--------< geometrical mean of stack >-----------------------------------------
    func testThatFloatGeometricalMeanOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values       // geometrical of values
            (["0"],         "0"),
            (["1", "1"],    "1"),
            (["-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"],    "0"),
            (["2", "4", "6"],                                      "3.63424118566"),
            (["90", "91", "92", "93", "94", "95", "96", "97", "98", "99"],    "94.4563234524"),
            ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.geoMean.rawValue)
            let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
            if let expectedResult = expectedResult,
                let engineResult   = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)

        }
    }

    //--------< variance of stack >-----------------------------------------
    func testThatFloatVarianceOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values                             // variance of values
            (["0", "0"],                      "0"),
            (["1", "1"],                      "0"),
            (["1", "1", "2", "2", "2", "2", "2", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "5", "5", "6"],                                     "1.64761904761905")
            ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.variance.rawValue)
            let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    //--------< standard deviation of stack >-----------------------------------------
    func testThatFloatStandardDeviationOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values                             // variance of values
            (["0", "0"],                      "0"),
            (["1", "1"],                      "0"),
            (["1", "1", "2", "2", "2", "2", "2", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "5", "5", "6"],                                     "1.28359613882991")
        ]
        
        for test in testSet
        {
            for value in test.0
            {
                engineDUT.userInputEnter(numericalValue: value, radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.sigma.rawValue)
            let engineResult   = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value))
            
            let expectedResult = Double(test.1)
            
            if let expectedResult = expectedResult,
                let engineResult  = engineResult
            {
                XCTAssertEqual(expectedResult, engineResult, accuracy: accuracy)                
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    //-------<Random number>--------------------------------------------------------------
    func testThatFloatRandomNumberResultsAreWithinTheExpectedRange()
    {
        // generate random numbers and test that they are in the range of 0 to 1.0
        for _ in 0..<100
        {
            engineDUT.userInputOperation(symbol: OperationCode.random.rawValue)
            
            if let engineResult = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertTrue(engineResult >= 0.0 && engineResult <= 1.0)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }

            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }
    
    func testThatFloatRandomNumberResultsAreOnAverageZeroPointFive()
    {
        // generate random numbers and test that they are around 0.5 on average
        for _ in 0..<10
        {
            for _ in 0..<1000
            {
                engineDUT.userInputOperation(symbol: OperationCode.random.rawValue)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.avg.rawValue)
            
            if let engineResult = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertEqual(engineResult, 0.5, accuracy: 0.1)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }
    
    
    func testThatRectToPolarOfVector2CalculatesCorrectly()
    {
        let testSets: [(String, String, String, String)] = 
        [   // x            y       ->      absolute value          angle
            ("12",         "5",             "13.0",                 "0.394791119699761"),
            
            ("3",          "4",             "5",                    "0.927295218001612"),
            ("-3",         "4",             "5",                    "2.21429743558818"),
            ("-3",         "-4",            "5",                   "-2.21429743558818"),
            ("3",         "-4",             "5",                   "-0.927295218001612"),
        ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: testSet.1, radix: Radix.decimal.value)
            let expectedResultForAbsValue: Double = Double(testSet.2)!
            let expectedResultForAngle: Double = Double(testSet.3)!
            
            // will produce two results: angle and absolute value
            engineDUT.userInputOperation(symbol: OperationCode.rect2polar.rawValue)
            
            if let engineResultForAbsValue = Double(engineDUT.registerValue(inRegisterNumber: 1, radix: 10)),
               let engineResultForAngle =    Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertEqual(engineResultForAngle, expectedResultForAngle, accuracy: accuracy)
                XCTAssertEqual(engineResultForAbsValue, expectedResultForAbsValue, accuracy: accuracy)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }
    
    func testThatPolarToRectOfVector2CalculatesCorrectly()
    {
        let testSets: [(String, String, String, String)] = 
            [   // absoluteValue            angle                  ->       x                  y      
                ("13.0",                    "0.394791119699761",            "12.0",            "5.0"),
                
                ("5",                       "0.927295218001612",            "3",                "4"),
                ("5",                       "2.21429743558818",             "-3",               "4"),
                ("5",                       "-2.21429743558818",            "-3",               "-4"),
                ("5",                       "-0.927295218001612",           "3",                "-4"),
                ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: testSet.1, radix: Radix.decimal.value)
            let expectedResultForX: Double = Double(testSet.2)!
            let expectedResultForY: Double = Double(testSet.3)!
            
            // will produce two results: angle and absolute value
            engineDUT.userInputOperation(symbol: OperationCode.polar2rect.rawValue)
            
            if let engineResultForX = Double(engineDUT.registerValue(inRegisterNumber: 1, radix: 10)),
               let engineResultForY = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
                
            {
                XCTAssertEqual(engineResultForX, expectedResultForX, accuracy: accuracy)
                XCTAssertEqual(engineResultForY, expectedResultForY, accuracy: accuracy)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    func testThatConvertDeg2RadCalculatesCorrectly()
    {
        let testSets: [(String, String)] = 
            [   // deg              rad 
                ("0.0",             "0.0"),                
                ("45.0",            "0.785398163397448"),
                ("90.0",            "1.5707963267949"),
                ("135.0",           "2.35619449019234"),
                ("180.0",           "3.14159265358979"),
                ("225.0",           "3.92699081698724"),
                ("270.0",           "4.71238898038469"),
                ("315.0",           "5.49778714378214"),
                ("360.0",           "6.28318530717959"),
                ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: Radix.decimal.value)
            let expectedResultForRad: Double = Double(testSet.1)!
            
            engineDUT.userInputOperation(symbol: OperationCode.deg2rad.rawValue)
            
            
            if let engineResultForRad = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertEqual(engineResultForRad, expectedResultForRad, accuracy: accuracy)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    func testThatConvertRad2DegCalculatesCorrectly()
    {
        let testSets: [(String, String)] = 
            [   // rad                      deg 
                ("0.0",                     "0.0"),                
                ("0.785398163397448",       "45.0"),
                ("1.5707963267949",         "90.0"),
                ("2.35619449019234",        "135.0"),
                ("3.14159265358979",        "180.0"),
                ("3.92699081698724",        "225.0"),
                ("4.71238898038469",        "270.0"),
                ("5.49778714378214",        "315.0"),
                ("6.28318530717959",        "360.0"),
                ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: Radix.decimal.value)
            let expectedResultForDeg: Double = Double(testSet.1)!
            
            engineDUT.userInputOperation(symbol: OperationCode.rad2deg.rawValue)
            
            
            if let engineResultForDeg = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertEqual(engineResultForDeg, expectedResultForDeg, accuracy: accuracy)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }
    

    func testThatCalculatesCorrectly()
    {
        let testSets: [(String, String, String)] = 
            [   // value1                   value2                  20*log(value1 / value 2)
                ("1.0",                     "1.0",                  "0.0"),            
                ("1.0",                     "2.0",                  "-6.02059991327962"),                
                ("2.0",                     "1.0",                  "6.02059991327962"),                ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: Radix.decimal.value)
            engineDUT.userInputEnter(numericalValue: testSet.1, radix: Radix.decimal.value)
            let expectedResult: Double = Double(testSet.2)!

            
            engineDUT.userInputOperation(symbol: OperationCode.conv22dB.rawValue)
            
            
            if let engineResult = Double(engineDUT.registerValue(inRegisterNumber: 0, radix: 10))
            {
                XCTAssertEqual(engineResult, expectedResult, accuracy: accuracy)
            }
            else
            {
                XCTFail("Test failure: could not convert string value to Double value")
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
        }
    }

    
    
    
}


