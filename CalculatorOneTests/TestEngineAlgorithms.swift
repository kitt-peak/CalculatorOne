//
//  TestEngineAlgorithms.swift
//  CalculatorOne
//
//  Created by Andreas on 10/01/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import XCTest
@testable import CalculatorOne

class TestEngineClassAlgorithms: XCTestCase 
{
    var engineDUT: Engine!
    
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
}
