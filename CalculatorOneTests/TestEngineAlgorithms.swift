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


    func testThatFunction_ClearDigitWithIndex_worksCorrectlyForRadix10()
    {
        let tests = 
        [
            (value:     5, index: 0, radix: 10, result:  0),
            (value:    45, index: 1, radix: 10, result:  5),
            (value:   345, index: 1, radix: 10, result:  305),
            (value: 98765, index: 0, radix: 10, result:  98760),
            (value: 98765, index: 1, radix: 10, result:  98705),
            (value: 98765, index: 2, radix: 10, result:  98065),
            (value: 98765, index: 3, radix: 10, result:  90765),
            (value: 98765, index: 4, radix: 10, result:   8765),

            (value:     -5, index: 0, radix: 10, result:  0),
            (value:    -45, index: 1, radix: 10, result:  -5),
            (value:   -345, index: 1, radix: 10, result:  -305),
            (value: -98765, index: 0, radix: 10, result:  -98760),
            (value: -98765, index: 1, radix: 10, result:  -98705),
            (value: -98765, index: 2, radix: 10, result:  -98065),
            (value: -98765, index: 3, radix: 10, result:  -90765),
            (value: -98765, index: 4, radix: 10, result:  -8765),
        ]
        
        for test in tests
        {
            let result = Engine.valueWithDigitCleared(value: test.value, digitIndex: test.index, radix: test.radix)            
            XCTAssertEqual(result, test.result)            
        }
    }
    
    
    func testThatFunction_ClearDigitWithIndex_worksCorrectlyForRadix16()
    {
        let tests = 
            [
                (value:     0x5, index: 0, radix: 16, result:  0x0),
                (value:    0x45, index: 1, radix: 16, result:  0x05),
                (value:    0xC1, index: 1, radix: 16, result:  0x01),
                
                (value:    0xDA, index: 1, radix: 16, result:  0x0A),
                (value:    -0xDA, index: 1, radix: 16, result:  -0x0A),

                (value:   0x345, index: 1, radix: 16, result:  0x305),
                (value: 0x9EB65, index: 0, radix: 16, result:  0x9EB60),
                (value: 0x9EB65, index: 1, radix: 16, result:  0x9EB05),
                (value: 0x9EB65, index: 2, radix: 16, result:  0x9E065),
                (value: 0x9EB65, index: 3, radix: 16, result:  0x90B65),
                (value: 0x9EB65, index: 4, radix: 16, result:  0x0EB65),
                
                (value:  0xFFEEBBCC00, index: 6, radix: 16, result:  0xFFE0BBCC00),                
                (value: -0xFFEEBBCC00, index: 6, radix: 16, result: -0xFFE0BBCC00),                
            ]
        
        for test in tests
        {
            let result = Engine.valueWithDigitCleared(value: test.value, digitIndex: test.index, radix: test.radix)            
            XCTAssertEqual(result, test.result)            
        }
    }
    
    
    
    func testThatFunction_valueWithDigitReplaced_worksCorrectlyForRadix10()
    {
        let tests = 
            [
                (value:     0, index: 0, newDigitValue: 0, radix: 10, result:  0),                
                (value:     0, index: 1, newDigitValue: 8, radix: 10, result:  80),
                (value:     0, index: 9, newDigitValue: 7, radix: 10, result:  7000000000),                

                
                (value:     5, index: 0, newDigitValue: 0, radix: 10, result:  0),
                (value:    45, index: 1, newDigitValue: 1, radix: 10, result:  15),
                (value:   345, index: 1, newDigitValue: 3, radix: 10, result:  335),
                (value: 98765, index: 0, newDigitValue: 9, radix: 10, result:  98769),
                (value: 98765, index: 1, newDigitValue: 6, radix: 10, result:  98765),
                (value: 98765, index: 2, newDigitValue: 5, radix: 10, result:  98565),
                (value: 98765, index: 3, newDigitValue: 4, radix: 10, result:  94765),
                (value: 98765, index: 4, newDigitValue: 7, radix: 10, result:  78765),
                
                (value:     -5, index: 0, newDigitValue: 0, radix: 10, result:  0),
                (value:    -45, index: 1, newDigitValue: 1, radix: 10, result:  -15),
                (value:   -345, index: 1, newDigitValue: 3, radix: 10, result:  -335),
                (value: -98765, index: 0, newDigitValue: 9, radix: 10, result:  -98769),
                (value: -98765, index: 1, newDigitValue: 6, radix: 10, result:  -98765),
                (value: -98765, index: 2, newDigitValue: 5, radix: 10, result:  -98565),
                (value: -98765, index: 3, newDigitValue: 4, radix: 10, result:  -94765),
                (value: -98765, index: 4, newDigitValue: 7, radix: 10, result:  -78765)
            ]
        
        for test in tests
        {
            let result = Engine.valueWithDigitReplaced(value: test.value, digitIndex: test.index, newDigitValue: test.newDigitValue, radix: test.radix)            
            XCTAssertEqual(result, test.result)            
        }
    }


    func testThatFunction_valueWithDigitReplaced_worksCorrectlyForRadix8()
    {
        let tests = 
            [
                (value:       5, index: 0, newDigitValue: 0, radix: 8, result:  0),
                (value:    0o45, index: 1, newDigitValue: 1, radix: 8, result:  0o15),
                (value:   0o345, index: 1, newDigitValue: 3, radix: 8, result:  0o335),
                (value: 0o12765, index: 0, newDigitValue: 2, radix: 8, result:  0o12762),
                (value: 0o12765, index: 1, newDigitValue: 6, radix: 8, result:  0o12765),
                (value: 0o12765, index: 2, newDigitValue: 5, radix: 8, result:  0o12565),
                (value: 0o12765, index: 3, newDigitValue: 4, radix: 8, result:  0o14765),
                (value: 0o12765, index: 4, newDigitValue: 7, radix: 8, result:  0o72765),
                
                (value:       -5, index: 0, newDigitValue: 0, radix: 8, result:  0),
                (value:    -0o45, index: 1, newDigitValue: 1, radix: 8, result:  -0o15),
                (value:   -0o345, index: 1, newDigitValue: 3, radix: 8, result:  -0o335),
                (value: -0o12765, index: 0, newDigitValue: 2, radix: 8, result:  -0o12762),
                (value: -0o12765, index: 1, newDigitValue: 6, radix: 8, result:  -0o12765),
                (value: -0o12765, index: 2, newDigitValue: 5, radix: 8, result:  -0o12565),
                (value: -0o12765, index: 3, newDigitValue: 4, radix: 8, result:  -0o14765),
                (value: -0o12765, index: 4, newDigitValue: 7, radix: 8, result:  -0o72765),
        ]
        
        for test in tests
        {
            let result = Engine.valueWithDigitReplaced(value: test.value, digitIndex: test.index, newDigitValue: test.newDigitValue, radix: test.radix)            
            XCTAssertEqual(result, test.result)            
        }
    }

    
}
