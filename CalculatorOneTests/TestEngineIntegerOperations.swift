//
//  TestEngineIntegerOperations.swift
//  CalculatorOne
//
//  Created by Andreas on 19/02/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineIntegerOperations: XCTestCase {

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
    

    func testThatIntegerOperationAddWorksMathematicallyCorrect()
    {
        let largeNumber : String = String(Int.max / 10000)
        
        let testSet: [(String, String, String)] = [
            ("1", "2", "3"),
            ("10", "20", "30"),        
            ("100", "200", "300"),
            ("-100", "100", "0"),
            ("-123456789", "987654321", "864197532"),
            (largeNumber, "0", largeNumber)
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.plus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }
    

   
    func testThatIntegerOperationSubtractWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("0", "0", "0"),
            ("1", "2", "-1"),
            ("10", "20", "-10"),        
            ("100", "200", "-100"),
            ("-100", "100", "-200"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.minus.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    

    
    func testThatIntegerOperationMultiplicationWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("0", "0", "0"),
            ("0", "2", "0"),
            ("1", "-1", "-1"),
            ("-1", "-2", "2"),
            ("1", "-2", "-2"),
            ("-1", "2", "-2"),
            ("10", "20", "200"),        
            ("100", "200", "20000"),
            ("-16", "16", "-256"),
            ("2", "2", "4"),
            ("4", "2", "8"),
            ("8", "2", "16"),
            ("16", "2", "32"),
            ("32", "2", "64"),
            ("64", "2", "128"),
            ("128", "2", "256"),
            ("256", "2", "512"),
            ("512", "2", "1024"),
            ("1024", "2", "2048"),
            ("2048", "2", "4096"),
            ("4096", "2", "8192"),
            ("8192", "2", "16384"),
            ("16384", "2", "32768"),
        ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.multiply.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    func testThatIntegerOperationDivisionWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("0", "1", "0"),
            ("0", "2", "0"),
            ("1", "-1", "-1"),
            ("-2", "-1", "2"),
            ("10", "-2", "-5"),
            ("200", "10", "20"),        
            ("200", "100", "2"),
            ("-256", "16", "-16"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.divide.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    func testThatIntegerOperationModuloDivisionWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            ("0", "1", "0"),
            ("0", "2", "0"),
            ("10", "-1", "0"),
            ("10", "1", "0"),
            ("10", "2", "0"),
            ("10", "3", "1"),
            ("10", "4", "2"),
            ("10", "5", "0"),
            ("10", "6", "4"),
            ("10", "7", "3"),
            ("10", "8", "2"),
            ("10", "9", "1"),
            ("10", "10", "0"),
            ("7", "7", "0"),
            ("7", "6", "1"),
            ("7", "5", "2"),
            ("7", "4", "3"),
            ("7", "3", "1"),
            ("7", "2", "1"),
            ("7", "1", "0"),
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.moduloN.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), test.2)
            
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    
    func testThatIntegerBINARY_LOGICAL_OperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String, String, String)] = [
            // value 0    value 1     AND         OR          XOR         
            ("0",        "0",         "0",        "0",        "0"),
            ("0",        "1",         "0",        "1",        "1"),
            ("1",        "0",         "0",        "1",        "1"),
            ("1",        "1",         "1",        "1",        "0"),
            ("11111111", "10101010",  "10101010", "11111111", "1010101"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 2)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 2)            
            engineDUT.userInputOperation(symbol: Symbols.dup2.rawValue)
            engineDUT.userInputOperation(symbol: Symbols.dup2.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.and.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 2)
            XCTAssertEqual(result, test.2 /* AND */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)

            engineDUT.userInputOperation(symbol: Symbols.or.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 2)
            XCTAssertEqual(result, test.3 /* OR */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.xor.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 2)
            XCTAssertEqual(result, test.4 /* XOR */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    func testThatIntegerUNARY_LOGICAL_OperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value     ~value        -value
            ("0",        "-1",         "0"),
            ("1",        "-10",        "-1"),
            ("-1",       "0",          "1"),
            ("-10",      "1",          "10"),
            ("111",      "-1000",      "-111"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 2)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.invertBits.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 2)
            XCTAssertEqual(result, test.1 /* ! */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.invertSign.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 2)
            XCTAssertEqual(result, test.2 /* ! */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
        }
    }

    func testThatIntegerFactorialOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String)] = [
            // value      value!
            ("-1",        "0"),     
            ("0",         "1"),
            ("1",         "1"),
            ("2",         "2"),
            ("3",         "6"),
            ("4",         "24"),
            ("5",         "120"),
            ("6",         "720"), 
            ("7",         "5040"),
            ("8",	      "40320"),
            ("9",	      "362880"),
            ("10",	      "3628800"),
            ("11",	      "39916800"),
            ("12",	      "479001600"),
            ("13",	      "6227020800"),
            ("14",	      "87178291200"),
            ("15",	      "1307674368000"),
            ("16",	      "20922789888000"),
            ("17",	      "355687428096000"),
            ("18",	      "6402373705728000"),
            ("19",	      "121645100408832000"),
            ("20",	      "2432902008176640000")        
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            
            engineDUT.userInputOperation(symbol: Symbols.factorial.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
    }


    func testThatIntegerSumOfStackOperationsWorksMathematicallyCorrect()
    {
        let testSet: [([String], String)] = [
            // values     // sum of values
            ([""],          ""),
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
            
            engineDUT.userInputOperation(symbol: Symbols.sum.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
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
        XCTAssertEqual(String(engineDUT.registerValue(inRegisterNumber: 0, radix: 10)), "5050")
        
        engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)

    }

    
    func testThatIntegerIncrementAndDecrementOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value      value++       value--
            ("0",         "1",          "-1"),
            ("1",         "2",          "0"),
            ("-1",        "0",          "-2"),
            ("-2",        "-1",         "-3"),
            ("4",         "5",          "3"),
            ("5",         "6",          "4"),
            ("6",         "7",          "5"),
            ("7",         "8",          "6")
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.increment.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            

            engineDUT.userInputOperation(symbol: Symbols.decrement.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
    }

    
    func testThatIntegerUNARY_SHIFT_OperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value     // <<         // >>
            ("0",        "0",          "0"),
            ("1",        "2",          "0"),
            ("2",        "4",          "1"),
            ("4",        "8",          "2"),
            ("8",        "16",         "4"),
            ("16",       "32",         "8"),
            ("1123",     "2246",       "561"),
            ("2567",     "5134",       "1283"),
            ("-1",       "-2",         "-1"),
            ("-2",       "-4",         "-1"),
            ("-4",       "-8",         "-2"),
            ("-8",       "-16",        "-4"),
            ("-16",      "-32",        "-8"),
            ("-1123",    "-2246",      "-562"),
            ("-2567",    "-5134",      "-1284"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputOperation(symbol: Symbols.dup.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.shiftLeft.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.1 /* << */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
            engineDUT.userInputOperation(symbol: Symbols.shiftRight.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2 /* >> */)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
            
        }
    }


    func testThatIntegerBINARY_SHIFT_LEFTOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value     // N       // N <<
            ("0",        "0",       "0"),
            ("1",        "1",       "2"),
            ("34",       "1",       "68"),
            ("34",       "2",       "136"),
            ("34",       "3",       "272"),
            ("-1",       "1",       "-2"),
            ("-34",      "1",       "-68"),
            ("-34",      "2",       "-136"),
            ("-34",      "3",       "-272"),
            ("1",        "64",      "64"),      // invalid operation: 1 << 64 throws an exception and leaves 1 and 64 on the stack
            ("1",        "-1",      "-1"),      // invalid operation: 1 << -1 throws an exception and leaves 1 and 64 on the stack
            ("1",        "65",      "65"),      // invalid operation: 1 << 65 throws an exception and leaves 1 and 65 on the stack
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            
            engineDUT.userInputOperation(symbol: Symbols.nShiftLeft.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2 /* N << */)
            engineDUT.userInputOperation(symbol: Symbols.dropAll.rawValue)
        }
    }
    
    func testThatIntegerBINARY_SHIFT_RIGHTOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value     // N       // N >>
            ("0",        "0",       "0"),
            ("1",        "1",       "0"),
            ("34",       "1",       "17"),
            ("34",       "2",       "8"),
            ("34",       "3",       "4"),
            ("-1",       "1",       "-1"),
            ("-34",      "1",       "-17"),
            ("-34",      "2",       "-9"),
            ("-34",      "3",       "-5"),
            ("1",        "64",      "64"),      // invalid operation: 1 >> 64 throws an exception and leaves 1 and 64 on the stack
            ("1",        "-1",      "-1"),      // invalid operation: 1 >> -1 throws an exception and leaves 1 and 64 on the stack
            ("1",        "65",      "65"),      // invalid operation: 1 >> 65 throws an exception and leaves 1 and 65 on the stack
            
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            
            engineDUT.userInputOperation(symbol: Symbols.nShiftRight.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2 /* N >> */)
            
            engineDUT.userInputOperation(symbol: Symbols.dropAll.rawValue)            
        }
    }


    
    func testThatIntegerGCDOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0       value1       GCD
            ("1",           "1",         "1"),
            ("2",           "4",         "2"),
            ("44",          "12",        "4"),
            ("45",          "27",        "9"),
            ("7",           "13",        "1"),
            ("-12",         "15",        "3"),
            ("13",          "1",         "1"),
            ("5",           "0",         "5"),
        ]
                
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            
            engineDUT.userInputOperation(symbol: Symbols.gcd.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)                        
        }
    }

    func testThatIntegerLCMOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, String, String)] = [
            // value0       value1       LCM
            ("1",           "1",          "1"),
            ("2",           "4",          "4"),
            ("2",           "5",          "10"),
            ("2",           "-5",         "10"),
            ("-2",          "5",          "10"),
            ("-2",          "-5",         "10"),
            ("122880",      "153600",     "614400"),
            ("245760",      "307200",     "1228800"),
            ("983040",      "307200",     "4915200"),
            ("45",          "27",         "135"),
            ("7",           "13",         "91"),
            ("-12",         "15",         "60"),
            ("13",          "1",          "13"),
            ("5",           "1",          "5"),
            ]
        
        for test in testSet
        {
            var result: String = ""
            
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            engineDUT.userInputEnter(numericalValue: test.1, radix: 10)
            
            engineDUT.userInputOperation(symbol: Symbols.lcm.rawValue)
            result = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            XCTAssertEqual(result, test.2)
            engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)            
        }
    }
    
    
    //--------< prime factors >-----------------------------------------
    func testThatIntegerPrimeFactorDivisionOperationsWorksMathematicallyCorrect()
    {
        let testSet: [(String, [String])] = [
            // values                       // prime factors
            ("0",                           ["0"]),
            ("1",                           ["1"]),
            ("2",                           ["2"]),
            ("3",                           ["3"]),
            ("4",                           ["2", "2"]),
            ("5",                           ["5"]),
            ("6",                           ["3", "2"]),
            ("7",                           ["7"]),
            ("8",                           ["2", "2", "2"]),
            ("9",                           ["3", "3"]),
            ("10",                          ["5", "2"]),
            ("1234567890",                  ["3803", "3607", "5", "3", "3", "2"]),
            ("998877665544332211",          ["9833", "9277", "883", "547", "229", "11", "3", "3"]) 
            ]
        
        for test in testSet
        {
            engineDUT.userInputEnter(numericalValue: test.0, radix: 10)
            
            // the prime factor function replaces the number on top of the stack by its prime factors
            // this is at least one value and can be multiple values all on the stack
            engineDUT.userInputOperation(symbol: Symbols.primes.rawValue)
            
            // test for the correct number of prime factors. Determine the number of prime factors on the stack
            engineDUT.userInputOperation(symbol: Symbols.depth.rawValue)
            let countFactorsStr: String = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
            if let countFactors: Int = Int(countFactorsStr)
            {
                // drop the count, not needed any more
                engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
                
                // read each factor, one by one, into an array
                var resultFactors: [String] = [String]()
                for _ in 0..<countFactors
                {
                    let factor: String = engineDUT.registerValue(inRegisterNumber: 0, radix: 10)
                    engineDUT.userInputOperation(symbol: Symbols.drop.rawValue)
                    
                    resultFactors.append(factor)
                }
                
                // compare to the expected result
                XCTAssertEqual(test.1, resultFactors)
                
            }
            else
            {
                // error - the number of prime factors is not an integer
                XCTFail("Test failure: could not convert string value to Integer value")
            }
            
            
        }
    }


}
