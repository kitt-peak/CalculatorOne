//
//  TestOperand.swift
//  CalculatorOne
//
//  Created by Andreas on 02.09.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne


class TestOperand: XCTestCase 
{

    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatOperandsCanBeCreatedFromIntegerValues()
    {
        let integerValues: [Int] = [-1, 0, 1, Int.max, Int.min]
        
        for integerValue in integerValues
        {
            let newOperand: Operand = Operand(integerValue: integerValue)

            XCTAssertNotNil(newOperand)
            XCTAssertTrue(newOperand.isIntegerPresentable)
            
            if let i=newOperand.iValue
            {
                XCTAssertEqual(i, integerValue)                
            }
            else
            {
                XCTFail("Could not convert \(newOperand) to an Int Value")
            }
        }
        
    }
    
    func testThatIntegerOperandsHaveCorrectFloatingPointRepresentations()
    {
        let values: [(Int, Double)] = 
        [
            (-1,                        -1.0),
            ( 0,                         0.0),
            ( 1,                         1.0),
            ( 9223372036854775807,       9223372036854775807.0),
            (-9223372036854775807,      -9223372036854775807.0),
        ]
        
        for value in values
        {
            let newOperand: Operand = Operand(integerValue: value.0)
            
            XCTAssertNotNil(newOperand)
            XCTAssertTrue(newOperand.isIntegerPresentable)
            XCTAssertTrue(newOperand.isFloatingPointPresentable)
                
            // correct integer value?
            if let i=newOperand.iValue
            {
                XCTAssertEqual(i, value.0)  
            }
            else
            {
                XCTFail("Could not convert \(newOperand) to an Int value")
            }
            
            // correct floating point value?
            if let f=newOperand.fValue
            {
                XCTAssertEqual(f, value.1)  
            }
            else
            {
                XCTFail("Could not convert \(newOperand) to a floating point value")
            }

        }
    }
    
    func testThatFloatingPointOperandsHaveCorrectIntegerRepresentations()
    {
        let values: [(Double, Int)] = 
            [
                (-1.0,                        -1),
                ( 0.0,                         0),
                ( 1.0,                         1),
                ( 22.0,                        22),
                ( 333.0,                       333),
                ( 4444.0,                      4444),
                ( 55555.0,                     55555),
                ( 666666.0,                    666666),
                ( 88888888.0,                  88888888),
                ( 1.0E10,                      10_000_000_000),
                ( 1.0E12,                      1_000_000_000_000),
                ( 1.0E14,                      100_000_000_000_000),
                ( 1.0E16,                      10_000_000_000_000_000),
                ( 1.0E17,                      100_000_000_000_000_000),
                ( 1.0E18,                      1_000_000_000_000_000_000),                
                ( 922337203685477.0,           922337203685477),
                (-922337203685477.0,          -922337203685477),
                ]
        
        for value in values
        {
            let newOperand: Operand = Operand(floatingPointValue: value.0)
            
            XCTAssertNotNil(newOperand)
            XCTAssertTrue(newOperand.isIntegerPresentable)
            XCTAssertTrue(newOperand.isFloatingPointPresentable)
            
            // correct floating point value?
            if let f=newOperand.fValue
            {
                XCTAssertEqual(f, value.0)  
            }
            else
            {
                XCTFail("Could not convert \(newOperand) to a floating point value")
            }
            
            // correct integer value?
            if let i=newOperand.iValue
            {
                XCTAssertEqual(i, value.1)  
            }
            else
            {
                XCTFail("Could not convert \(newOperand) to an integer value")
            }
            
        }
    }

    func testLargeIntegerOperandsHaveNoFloatingPointRepresentation()
    {
        let values: [Int] = 
            [   
                //  0x7FFF_FFFF_FFFF_FFFF,
                // -0x8000_0000_0000_0000  
            ]
        
        for value in values
        {
            let newOperand: Operand = Operand(integerValue: value)
            
            XCTAssertNotNil(newOperand)
            XCTAssertTrue(newOperand.isIntegerPresentable)
            XCTAssertFalse(newOperand.isFloatingPointPresentable)
        }
    }

    
    func testLargeFloatingPointOperandsHaveNoIntegerRepresentation()
    {
        let values: [Double] = 
            [   
                 9223372036854775807.0,
                -92233720368547758999.0,
                1.0E19,
                -1.0E19
            ]
        
        for value in values
        {
            let newOperand: Operand = Operand(floatingPointValue: value)
            
            XCTAssertNotNil(newOperand)
            XCTAssertTrue(newOperand.isFloatingPointPresentable)
            XCTAssertFalse(newOperand.isIntegerPresentable)
            
        }
    }
    
    func testThatDecimalIntegerNumbersHaveCorrectOperandRepresentationsAsIntegerAndAsFloatingPoint()
    {
        let testArguments: [(String, Bool, Bool)] = 
            [   
                // argument           isInteger    isFloatingPoint
                //                    ("7FFFFFFFFFFFFFFF",  true,        false),  /* largest integer, has no exact representation as floating point */
                //                    ("-8000000000000000", true,        true),   /* smallest integer, has a exact representation as floating point */
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
            // test if argument is accepted as integer
            if let integerOperand: Operand = Operand(stringRepresentation: testArgument.0, radix: radix)
            {
                XCTAssertEqual(integerOperand.isIntegerPresentable, testArgument.1)
                XCTAssertEqual(integerOperand.isFloatingPointPresentable, testArgument.2)
                
                XCTAssertEqual(String(integerOperand.iValue!), testArgument.0)
            }
            else
            {
                XCTFail("Cannot create Operand with string argument \(testArgument.0)")
            }
        }
    }
    

    func testThatFractionalNumberOperandsAreCorrectRepresentedAsFloatingPointAndNotAsInteger()
    {
        
        // other numbers, for instance 3.45 have fractional and therefore have no integer representation
        let testArguments: [(String, Bool, Bool)] = 
            [   
                // argument           isInteger    isFloatingPoint
                ("0.1",               false,        true),  
                ("-3.45",             false,        true),  
                ("-1e-07",            false,        true),
                ]
        
        let radix: Int = Radix.decimal.value
        
        for testArgument in testArguments 
        {
            // test if argument is accepted as floating point
            if let floatingPointOperand: Operand = Operand(stringRepresentation: testArgument.0, radix: radix)
            {
                XCTAssertEqual(floatingPointOperand.isIntegerPresentable, testArgument.1)
                XCTAssertEqual(floatingPointOperand.isFloatingPointPresentable, testArgument.2)
                
                XCTAssertEqual(String(floatingPointOperand.fValue!), testArgument.0)
            }
            else
            {
                XCTFail("Cannot create Operand with string argument \(testArgument.0)")
            }

        }
    }
    
    func testThatOperandsCannotBeInstantiatedFromNonNumericalStrings()
    {
        // test that string values are not accepted as valid operands
        let testValues: [String] = 
            [   "-",            // not a number
                ".",            // not a number
                "-.",           // not a number
        ]
        
        for testValue in testValues
        {
            let operand: Operand? = Operand(stringRepresentation: testValue, radix: Radix.decimal.value)  
            
            XCTAssertNil(operand)
        }
    }
    
    func testThatEqualOperandsComparedEqual()
    {
        let testValues : [(Operand, Operand)] =
        [
            (Operand(integerValue: 0), Operand(integerValue: 0)),  
            (Operand(integerValue: 1), Operand(integerValue: 1)),  
            (Operand(integerValue: -1), Operand(integerValue: -1)),  
            (Operand(integerValue: -42), Operand(integerValue: -42)),  
            (Operand(integerValue: 1000000000), Operand(integerValue: 1000000000)),  
            
            (Operand(floatingPointValue: Double.pi), Operand(floatingPointValue: Double.pi)),  
            (Operand(floatingPointValue: -0.00001), Operand(floatingPointValue: -0.00001)),  
            (Operand(floatingPointValue:  0.00001), Operand(floatingPointValue:  0.00001)),
            (Operand(floatingPointValue: Double.greatestFiniteMagnitude), Operand(floatingPointValue: Double.greatestFiniteMagnitude)),  
            (Operand(floatingPointValue: Double.leastNonzeroMagnitude), Operand(floatingPointValue: Double.leastNonzeroMagnitude)),  

            (Operand(integerValue: 0),  Operand(floatingPointValue: 0)),  
            (Operand(integerValue: 1),  Operand(floatingPointValue: 1)),  
            (Operand(integerValue: -1), Operand(floatingPointValue: -1)),  
            (Operand(integerValue: -42), Operand(floatingPointValue: -42)),  
            (Operand(integerValue: 1000000000), Operand(floatingPointValue: 1000000000)),  
            
        ]
        
        for testValue in testValues
        {
            XCTAssertEqual(testValue.0, testValue.1)
        }
    }

    func testThatNonEqualOperandsComparedNotEqual()
    {
        let testValues : [(Operand, Operand)] =
            [
                (Operand(integerValue: 0), Operand(integerValue: 1)),  
                (Operand(integerValue: 1), Operand(integerValue: -1)),  
                (Operand(integerValue: -1), Operand(integerValue: 1)),  
                (Operand(integerValue: 42), Operand(integerValue: 43)),  
                (Operand(integerValue: 1000000000), Operand(integerValue: 1000000001)),  
                
                (Operand(floatingPointValue: Double.pi), Operand(floatingPointValue: -Double.pi)),  
                (Operand(floatingPointValue: -0.00001), Operand(floatingPointValue: -0.10001)),  
                (Operand(floatingPointValue:  0.00001), Operand(floatingPointValue:  0.10001)),
                
                (Operand(integerValue: 0),  Operand(floatingPointValue: 0.1)),  
                (Operand(integerValue: 1),  Operand(floatingPointValue: 1.9)),  
                (Operand(integerValue: -1), Operand(floatingPointValue: -1.1)),  
                (Operand(integerValue: -42), Operand(floatingPointValue: -42.42)),  
                (Operand(integerValue: 1000000000), Operand(floatingPointValue: -1000000000)),  

                (Operand(stringRepresentation: Int64.max.description, radix: 10)!, Operand(stringRepresentation: "0.3", radix: 10)!),
                
                ]
        
        for testValue in testValues
        {
            XCTAssertNotEqual(testValue.0, testValue.1)
        }
    }

    
    func testThatStringValueReturnsCorrectStringRepresenationsOfOperands()
    {
        let testValues : [(Operand, String)] =
            [
                (Operand(integerValue: 0),      "0"),  
                (Operand(integerValue: 1),      "1"),  
                (Operand(integerValue: -1),     "-1"),  
                (Operand(integerValue: 42),     "42"),  
                (Operand(integerValue: 100000), "100000"),  
                
                (Operand(floatingPointValue: -1E-5), "-1e-05"),  
                (Operand(floatingPointValue: -1E-6), "-1e-06"),
                
                (Operand(floatingPointValue: 1E55), "1e+55"),
                (Operand(floatingPointValue: -1E-55), "-1e-55"),
                
                (Operand(floatingPointValue: 1.111E55), "1.111e+55"),
                (Operand(floatingPointValue: -1.111E55), "-1.111e+55"),
                
                (Operand(floatingPointValue: 1.222222E55), "1.222222e+55"),
                (Operand(floatingPointValue: -1.222222E-55), "-1.222222e-55"),
                
                (Operand(floatingPointValue: 1.333333333333E55), "1.333333333333e+55"),
                (Operand(floatingPointValue: -1.333333333333E-55), "-1.333333333333e-55"),
                
                ]
        
        for testValue in testValues
        {
            XCTAssertEqual(testValue.0.stringValue, testValue.1)
        }
    }
    
    
    func test1()
    {
        let testValues : [(Operand, String, String, String, String)] =
            [                                   // bin          // oct          // dec          // hex
                (Operand(integerValue: 0),      "0",            "0",            "0",            "0"),  
                (Operand(integerValue: 1),      "1",            "1",            "1",            "1"),  
                (Operand(integerValue: -1),     "-1",           "-1",           "-1",           "-1"),  
                (Operand(integerValue: 42),     "101010",       "52",           "42",           "2A"),  
                (Operand(integerValue: 10),     "1010",         "12",           "10",           "A"),  
                (Operand(integerValue: 255),    "11111111",     "377",          "255",          "FF"),  
                (Operand(integerValue: -255),    "-11111111",   "-377",         "-255",         "-FF"),  
            ]        
    
        
        for testValue in testValues
        {
            XCTAssertEqual(testValue.0.stringValueWithRadix(radix: Radix.binary.value), testValue.1)
            XCTAssertEqual(testValue.0.stringValueWithRadix(radix: Radix.octal.value), testValue.2)
            XCTAssertEqual(testValue.0.stringValueWithRadix(radix: Radix.decimal.value), testValue.3)
            XCTAssertEqual(testValue.0.stringValueWithRadix(radix: Radix.hex.value), testValue.4)
        }

    }
    
    
}
