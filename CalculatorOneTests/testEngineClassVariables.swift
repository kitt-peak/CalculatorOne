//
//  testEngineClassVariables.swift
//  CalculatorOne
//
//  Created by Andreas on 05/03/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class testEngineClassVariables: XCTestCase
{
    var engineDUT: Engine!
    
    let accuracy = 1E-16
    let exact    = 0.0
    
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

    func testThatConstant_π_isCorrect()
    {
        XCTAssertEqual(Double.π, Double.pi, accuracy: accuracy)
    }

    func testThatConstant_e_isCorrect()
    {
        XCTAssertEqual(Double.e, 2.718281828459045235360287471352662497757247, accuracy: accuracy)
    }
    
    func testThatConstant_c0_isCorrect()
    {
        XCTAssertEqual(Double.c0, 2.99792458E8, accuracy: exact)
    }

    func testThatConstant_U0_isCorrect()
    {
        XCTAssertEqual(Double.µ0, 1.256637061E-6, accuracy: exact)
    }

    func testThatConstant_E0_isCorrect()
    {
        XCTAssertEqual(Double.epsilon0, 8.854187817E-12, accuracy: exact)
    }


}
