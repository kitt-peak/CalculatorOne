//
//  TestEngineStackOperations.swift
//  CalculatorOne
//
//  Created by Andreas on 15/01/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineStackOperations: XCTestCase 
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
    
    
    
    func testThatTheStackAcceptsPushAndPopOneValue()
    {
        let testValue = "0"
        engineDUT.userInputEnter(numericalValue: testValue, radix: 10)
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == true)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 1) == false)

        XCTAssert(engineDUT.numberOfRegistersWithContent() == 1)
        XCTAssert(engineDUT.registerValue(registerNumber: 0, radix: 10) == testValue)
        
        engineDUT.userInputOperation(symbol: "DROP")
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == false)
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 0)

    }


    func testThatTheStackAcceptsPushAndPopTwoValues()
    {
        
        let testValue0 = "-42"
        let testValue1 = "52"

        engineDUT.userInputEnter(numericalValue: testValue0, radix: 10)
        engineDUT.userInputEnter(numericalValue: testValue1, radix: 10)
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == true)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 1) == true)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 2) == false)
        
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 2)
        XCTAssert(engineDUT.registerValue(registerNumber: 0, radix: 10) == testValue1)
        XCTAssert(engineDUT.registerValue(registerNumber: 1, radix: 10) == testValue0)
        
        engineDUT.userInputOperation(symbol: "DROP")
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == true)
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 1)
        XCTAssert(engineDUT.registerValue(registerNumber: 0, radix: 10) == testValue0)

        engineDUT.userInputOperation(symbol: "DROP")
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == false)
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 0)
        
    }
    
    func testThatStackOperationSwapWorksCorrectly()
    {
        engineDUT.userInputEnter(numericalValue: "42", radix: 10)
        engineDUT.userInputEnter(numericalValue: "55", radix: 10)
        engineDUT.userInputOperation(symbol: "SWAP")
        
        XCTAssertEqual(engineDUT.registerValue(registerNumber: 0, radix: 10), "55")
        XCTAssertEqual(engineDUT.registerValue(registerNumber: 1, radix: 10), "42")
    }
    
    
}
