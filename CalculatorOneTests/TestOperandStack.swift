//
//  TestOperandStack.swift
//  CalculatorOne
//
//  Created by Andreas on 02.09.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestOperandStack: XCTestCase 
{
    private var stackDUT: OperandStack = OperandStack(operands: [])
    
    override func setUp() 
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


}
