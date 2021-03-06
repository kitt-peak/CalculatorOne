//
//  TestEngineOperandDisplayFormat.swift
//  CalculatorOne
//
//  Created by Andreas on 05/03/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne


class TestEngineOperandDisplayFormat: XCTestCase {

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
    

    func testThatADecimalNumberIsConvertedCorrectlyToBinOctHexDisplayFormat()
    {
        let testSets: [(String, String, String, String)] = [
            
            // Decimal,             Binary,         Octal,      Hexadecimal
            ("0",                   "0",            "0",        "0"),
            ("1",                   "1",            "1",        "1"),
            ("-1",                  "-1",           "-1",       "-1"),
            ("255",                 "11111111",     "377",      "FF"),
            ("267242409",           "1111111011011100101110101001",     "1773345651",      "FEDCBA9"),
            ("72057594037927",      "10000011000100100110111010010111100011010100111",     "2030446722743247",  "4189374BC6A7")
            
        ]
        
        for testSet in testSets
        {
            engineDUT.userInputEnter(numericalValue: testSet.0, radix: 10)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.binary.value), testSet.1)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.octal.value), testSet.2)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), testSet.0)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.hex.value), testSet.3)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
/*    func testThatBinOctHexNumbersAreConvertedCorrectlyToDecimalDisplayFormat()
    {
        let testSets = [
            
            // Decimal,     Binary,         Octal,      Hexadecimal
            ("0",               "0",            "0",        "0"),
            ("1",               "1",            "1",        "1"),
            ("-1",              "-1",           "-1",       "-1"),
            ("255",             "11111111",     "377",      "FF"),
            ("267242409",       "1111111011011100101110101001",     
                                                "1773345651",      
                                                            "FEDCBA9"),
            ("9223372036854775807",   
                            "111111111111111111111111111111111111111111111111111111111111111",
                                            "777777777777777777777",
                                                        "7FFFFFFFFFFFFFFF")
        ]
        
        for testSet in testSets
        {
            // input binary, test decimal
            engineDUT.userInputEnter(numericalValue: testSet.1, radix: Radix.binary.value)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), testSet.0)

            // input octal, test decimal
            engineDUT.userInputEnter(numericalValue: testSet.2, radix: Radix.octal.value)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), testSet.0)

            // input octal, test decimal
            engineDUT.userInputEnter(numericalValue: testSet.3, radix: Radix.hex.value)
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), testSet.0)

            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }
 */

}
