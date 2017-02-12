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
        
        engineDUT.userUpdatedStackTopValue("0", radix: 10)
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == true)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 1) == false)

        XCTAssert(engineDUT.numberOfRegistersWithContent() == 1)
        XCTAssert(engineDUT.registerValue(registerNumber: 0) == 0)
        
        engineDUT.userInputOperation(symbol: "DROP")
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == false)
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 0)

    }


    func testThatTheStackAcceptsPushAndPopTwoValues()
    {
        
        engineDUT.userUpdatedStackTopValue("42", radix: 10)
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == true)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 1) == false)
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 2) == false)
        
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 1)
        XCTAssert(engineDUT.registerValue(registerNumber: 0) == 42)
        
        engineDUT.userInputOperation(symbol: "DROP")
        
        XCTAssert(engineDUT.hasValueForRegister(registerNumber: 0) == false)
        XCTAssert(engineDUT.numberOfRegistersWithContent() == 0)
        
    }
    
    func testThatStackOperationSwapWorksCorrectly()
    {
        engineDUT.userInputEnter(numericalValue: 42)
        engineDUT.userInputEnter(numericalValue: 55)
        engineDUT.userInputOperation(symbol: "SWAP")
        
        XCTAssertEqual(engineDUT.registerValue(registerNumber: 0), 55)
        XCTAssertEqual(engineDUT.registerValue(registerNumber: 1), 42)
    }
    
    
}
