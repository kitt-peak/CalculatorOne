//
//  TestEngineTypeLessOperation.swift
//  CalculatorOne
//
//  Created by Andreas on 25/02/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineTypeLessOperation: XCTestCase 
{

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


    func testThatOperationDUPCorrectlyDuplicatesTheTopOfStack()
    {
        let testValue: String = "12345"
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
        
        engineDUT.userInputEnter(numericalValue: testValue, radix: 10)
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 1)
        
        engineDUT.userInputOperation(symbol: OperationCode.dup.rawValue)
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 2)
        
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), testValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), testValue)

        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)

        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
    }

    func testThatOperationDUP2CorrectlyDuplicatesTwoValuesAtTheTopOfStack()
    {
        
        let testValue1: String =  "1.1111"
        let testValue2: String = "-2.2222"
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
        
        engineDUT.userInputEnter(numericalValue: testValue1, radix: 10)
        engineDUT.userInputEnter(numericalValue: testValue2, radix: 10)
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 2)
        
        engineDUT.userInputOperation(symbol: OperationCode.dup2.rawValue)
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 4)
        
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), testValue2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), testValue1)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 2, radix: 10), testValue2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 3, radix: 10), testValue1)
        
        engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
    }

    
    func testThatOperationDROPRemovesTheTopValueFromTheStack()
    {
    
        let n = 100
        
        // enter n values...
        for i in 0..<n
        {
            engineDUT.userInputEnter(numericalValue: String(i), radix: 10)
            XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), i + 1)
        }
        
        // drop n values...
        for i in 0..<n
        {            
            XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), n - i)
            
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
            
            XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), n - i - 1)
        }
        
        XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
            
    }
    
    
    func testThatOperationDROPALLCorrectlyRemovesAllVAluesFromTheStack()
    {
        
        // put a huge number of values on the stack and drop them all, then check for an empty stack
        for i in 0..<10 
        {
            for j in 0..<20
            {
                engineDUT.userInputEnter(numericalValue: String(i * j), radix: 10)
            }
            
            engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
            XCTAssertEqual(engineDUT.numberOfRegistersWithContent(), 0)
        }
    }

    
    func testThatOperationSWAPCorrectlyExchangesTopOfStackValues()
    {
        
        let value1 = "1.2345"
        let value2 = "0.4444"
        
        engineDUT.userInputEnter(numericalValue: value1, radix: 10)
        engineDUT.userInputEnter(numericalValue: value2, radix: 10)

        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value1)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value2)
        
        engineDUT.userInputOperation(symbol: OperationCode.swap.rawValue)

        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value1)
        
        engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
        
    }
    
    func testThatOperationNDROPCorrectlyRemovesTopOfStackValues()
    {
        
        // put 10 values on the stack 
        engineDUT.userInputEnter(numericalValue: "1", radix: 10)
        engineDUT.userInputEnter(numericalValue: "2", radix: 10)
        engineDUT.userInputEnter(numericalValue: "3", radix: 10)
        engineDUT.userInputEnter(numericalValue: "4", radix: 10)
        engineDUT.userInputEnter(numericalValue: "5", radix: 10)
        engineDUT.userInputEnter(numericalValue: "6", radix: 10)
        engineDUT.userInputEnter(numericalValue: "7", radix: 10)
        engineDUT.userInputEnter(numericalValue: "8", radix: 10)
        engineDUT.userInputEnter(numericalValue: "9", radix: 10)
        engineDUT.userInputEnter(numericalValue: "10", radix: 10)

        // remove 3 values
        engineDUT.userInputEnter(numericalValue: "3", radix: 10)
        engineDUT.userInputOperation(symbol: OperationCode.nDrop.rawValue)
        
        // top of stack must now be "7"
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), "7")
        
        // remove 7 values
        engineDUT.userInputEnter(numericalValue: "7", radix: 10)
        engineDUT.userInputOperation(symbol: OperationCode.nDrop.rawValue)
        
        // stack must now be empty
        engineDUT.userInputOperation(symbol: OperationCode.depth.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), "0")
    }


    
    func testThatOperationROTATEDOWNCorrectlyExchangesTopOfStackValues()
    {
        
        let value1 = "1.2345"
        let value2 = "0.4444"
        let value3 = "-0.009"
        
        engineDUT.userInputEnter(numericalValue: value1, radix: 10)
        engineDUT.userInputEnter(numericalValue: value2, radix: 10)
        engineDUT.userInputEnter(numericalValue: value3, radix: 10)

        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 2, radix: 10), value1)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value3)
        
        engineDUT.userInputOperation(symbol: OperationCode.rotateDown.rawValue)
        
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 2, radix: 10), value3)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value1)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value2)
        
        engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
        
    }

    func testThatOperationROTATEUPCorrectlyExchangesTopOfStackValues()
    {
        
        let value1 = "1.2345"
        let value2 = "0.4444"
        let value3 = "-0.009"
        
        engineDUT.userInputEnter(numericalValue: value1, radix: 10)
        engineDUT.userInputEnter(numericalValue: value2, radix: 10)
        engineDUT.userInputEnter(numericalValue: value3, radix: 10)
        
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 2, radix: 10), value1)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value3)
        
        engineDUT.userInputOperation(symbol: OperationCode.rotateUp.rawValue)
        
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 2, radix: 10), value2)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 1, radix: 10), value3)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), value1)
        
        engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
        
    }
    
    func testThatOperationDEPTHCorrectlyCountsTheElementsOnTheStack()
    {

        for i in 1..<30
        {
            engineDUT.userInputEnter(numericalValue: String(i), radix: 10)
            engineDUT.userInputOperation(symbol: OperationCode.depth.rawValue)
            
            XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: 10), String(i)) 
            engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        }
    }

    
    func testThatOperationNPICKCorrectlyReturnsTheCorrectStackElement()
    {

        engineDUT.userInputEnter(numericalValue: "21", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "42", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "84", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "168", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "336", radix: Radix.decimal.value)
        
        /* pick the 0st element (the "0" itself) */
        engineDUT.userInputEnter(numericalValue: "0", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "0")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)

        /* pick the 1th element */
        engineDUT.userInputEnter(numericalValue: "1", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "336")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 2th element */
        engineDUT.userInputEnter(numericalValue: "2", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "168")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)

        /* pick the 3rd element */
        engineDUT.userInputEnter(numericalValue: "3", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "84")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 4th element */
        engineDUT.userInputEnter(numericalValue: "4", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "42")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 5th element */
        engineDUT.userInputEnter(numericalValue: "5", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "21")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        
        engineDUT.userInputOperation(symbol: OperationCode.dropAll.rawValue)
                
        engineDUT.userInputEnter(numericalValue: "21.21", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "42.42", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "84.84", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "168.168", radix: Radix.decimal.value)
        engineDUT.userInputEnter(numericalValue: "336.336", radix: Radix.decimal.value)
        
        /* pick the 0st element (the "0" itself) */
        engineDUT.userInputEnter(numericalValue: "0", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "0")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 1th element */
        engineDUT.userInputEnter(numericalValue: "1", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "336.336")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 2th element */
        engineDUT.userInputEnter(numericalValue: "2", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "168.168")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 3rd element */
        engineDUT.userInputEnter(numericalValue: "3", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "84.84")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 4th element */
        engineDUT.userInputEnter(numericalValue: "4", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "42.42")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
        /* pick the 5th element */
        engineDUT.userInputEnter(numericalValue: "5", radix: Radix.decimal.value)
        engineDUT.userInputOperation(symbol: OperationCode.nPick.rawValue)
        XCTAssertEqual(engineDUT.registerValue(inRegisterNumber: 0, radix: Radix.decimal.value), "21.21")
        engineDUT.userInputOperation(symbol: OperationCode.drop.rawValue)
        
    }    

}
