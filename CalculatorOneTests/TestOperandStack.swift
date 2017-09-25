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
    
    override func setUp() 
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testThatAOperandStackInstanceCanBeCreated()
    {
        let stackDUT: OperandStack = OperandStack()
        XCTAssertNotNil(stackDUT)
    }
    
    
    func testThatTheCreationOfAnOperandStackInstanceCreatesAnEmptyStack()
    {
        let stackDUT: OperandStack = OperandStack()
        XCTAssertEqual(stackDUT.count, 0)
    }
    
    func testThatAOperandStackInstanceCanBeCreatedWithAnOperandAsArgument()
    {
        let operandArray: [Operand] = [Operand(floatingPointValue: Double.pi)]
        let stackDUT: OperandStack  = OperandStack(operands: operandArray)
        
        XCTAssertNotNil(stackDUT)
        XCTAssertEqual(stackDUT.count, 1)

        XCTAssertEqual(try stackDUT.pop(), operandArray[0])
    }
    
    func testThatThePushFunctionPutsAnOperandOnTheStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        stackDUT.push(operand: Operand(floatingPointValue: 1.0))
        
        XCTAssertEqual(stackDUT.count, 1)
        
    }
    
    func testThatThePushFunctionPutsAnArrayOfOperandsOnTheStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)

        stackDUT.push(operands: [operand1, operand2, operand3])
        
        XCTAssertEqual(stackDUT.count, 3)

        XCTAssertEqual(try stackDUT.pop(), operand3)
        XCTAssertEqual(try stackDUT.pop(), operand2)
        XCTAssertEqual(try stackDUT.pop(), operand1)
    }
    
    func testThatTheAllOperandsFunctionReturnsAllOperandsFromTheStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)
        
        let operandArray: [Operand] = [operand1, operand2, operand3]
        
        stackDUT.push(operands: operandArray)
        
        XCTAssertEqual(stackDUT.count, 3)
        
        XCTAssertEqual(stackDUT.allOperands(), operandArray)
        
        // test that allOperands() did not remove any operands
        XCTAssertEqual(stackDUT.count, 3)
    }


    
    func testThatThePopFunctionReturnsTheTopOfStackOperand()
    {
        let stackDUT: OperandStack  = OperandStack()

        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)
        
        stackDUT.push(operand: operand1)
        stackDUT.push(operand: operand2)
        stackDUT.push(operand: operand3)
        
        XCTAssertEqual(try stackDUT.pop(), operand3)
        XCTAssertEqual(try stackDUT.pop(), operand2)
        XCTAssertEqual(try stackDUT.pop(), operand1)
        
    }
    
    func testThatTheRemoveAllFunctionRemovesAllOOperandFromTheStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)

        stackDUT.push(operand: operand1)
        stackDUT.push(operand: operand2)
        stackDUT.push(operand: operand3)
        
        XCTAssertEqual(stackDUT.count, 3)
        
        stackDUT.removeAll()

        XCTAssertEqual(stackDUT.count, 0)

    }

    
    func testThatTheSubscriptFunctionWorksLikeAnArraySubscriptInReadingFromTheStackArray()
    {
        let stackDUT: OperandStack  = OperandStack()

        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)
        let operand4: Operand = Operand(floatingPointValue: 4.0)
        let operand5: Operand = Operand(floatingPointValue: 5.0)
        
        stackDUT.push(operand: operand1)
        stackDUT.push(operand: operand2)
        stackDUT.push(operand: operand3)
        stackDUT.push(operand: operand4)
        stackDUT.push(operand: operand5)
        
        XCTAssertEqual(try stackDUT.operandAtIndex(0), operand1)
        XCTAssertEqual(try stackDUT.operandAtIndex(1), operand2)
        XCTAssertEqual(try stackDUT.operandAtIndex(2), operand3)
        XCTAssertEqual(try stackDUT.operandAtIndex(3), operand4)
        XCTAssertEqual(try stackDUT.operandAtIndex(4), operand5)
    }

    func testThatTheSubscriptFunctionWorksLikeAnArraySubscriptInWritingToTheStackArray()
    {
        let stackDUT: OperandStack  = OperandStack()
                
        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: -2.0)
        
        stackDUT.push(operand: operand1)
        stackDUT.push(operand: operand1)
        stackDUT.push(operand: operand1)

        try! stackDUT.setOperand(operand2, atIndex: 0)
        try! stackDUT.setOperand(operand2, atIndex: 1)
        try! stackDUT.setOperand(operand2, atIndex: 2)
        
        XCTAssertEqual(try stackDUT.operandAtIndex(0), operand2)
        XCTAssertEqual(try stackDUT.operandAtIndex(1), operand2)
        XCTAssertEqual(try stackDUT.operandAtIndex(2), operand2)
    }

    func testThatTheSetOperandFunctionUpdatesOperandsOnTheStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let operand1: Operand = Operand(floatingPointValue: 1.0)
        let operand2: Operand = Operand(floatingPointValue: 2.0)
        let operand3: Operand = Operand(floatingPointValue: 3.0)
        let operand4: Operand = Operand(floatingPointValue: 4.0)
        let operand5: Operand = Operand(floatingPointValue: 5.0)
        
        let operandArray : [Operand] = [operand1, operand2, operand3, operand4, operand5]
        stackDUT.push(operands: operandArray)

        let operandA: Operand = Operand(floatingPointValue: -1.0)
        let operandB: Operand = Operand(floatingPointValue: -2.0)
        let operandC: Operand = Operand(floatingPointValue: -3.0)
        let operandD: Operand = Operand(floatingPointValue: -4.0)
        let operandE: Operand = Operand(floatingPointValue: -5.0)
        
        try! stackDUT.setOperand(operandA, atIndex: 0)
        try! stackDUT.setOperand(operandB, atIndex: 1)
        try! stackDUT.setOperand(operandC, atIndex: 2)
        try! stackDUT.setOperand(operandD, atIndex: 3)
        try! stackDUT.setOperand(operandE, atIndex: 4)

        XCTAssertEqual(try stackDUT.operandAtIndex(0), operandA)
        XCTAssertEqual(try stackDUT.operandAtIndex(1), operandB)
        XCTAssertEqual(try stackDUT.operandAtIndex(2), operandC)
        XCTAssertEqual(try stackDUT.operandAtIndex(3), operandD)
        XCTAssertEqual(try stackDUT.operandAtIndex(4), operandE)
        
        XCTAssertEqual(stackDUT.count, 5)
    }
    
    func testThatAnErrorIsThrownWhenAccessingTheStackAtAnInvalidIndex()
    {
        let stackDUT: OperandStack  = OperandStack()

        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(0))
        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(-1))
        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(1))
        
        let operand: Operand = Operand(floatingPointValue: Double.pi)
        
        stackDUT.push(operand: operand)

        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(1))
        
        // test that the stack did not change
        XCTAssertEqual(stackDUT.count, 1)
        XCTAssertEqual(stackDUT.allOperands(), [operand])
    }
    
    func testThatAnErrorIsThrownWhenSettingTheStackAtAnInvalidIndex()
    {
        let stackDUT: OperandStack  = OperandStack()

        let operand1: Operand = Operand(floatingPointValue: Double.pi)
        let operand2: Operand = Operand(floatingPointValue: -Double.pi)


        stackDUT.push(operands: [operand1, operand2])
        
        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(2))
        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(-1))
        XCTAssertThrowsError(try _ = stackDUT.operandAtIndex(Int.max))
        
        XCTAssertThrowsError(try stackDUT.setOperand(operand2, atIndex: 2))
        XCTAssertThrowsError(try stackDUT.setOperand(operand2, atIndex: 3))
        XCTAssertThrowsError(try stackDUT.setOperand(operand2, atIndex: -1))
        
        // test that the stack did not change
        XCTAssertEqual(stackDUT.count, 2)
        XCTAssertEqual(stackDUT.allOperands(), [operand1, operand2])
    }

    func testThatAnErrorIsThrownWhenPoppingAnEmptyStack()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        XCTAssertThrowsError(try _ = stackDUT.pop())    
        
        let operand1: Operand = Operand(floatingPointValue: Double.pi)
        let operand2: Operand = Operand(floatingPointValue: -Double.pi)
        
        stackDUT.push(operands: [operand1, operand2])
        
        XCTAssertNoThrow(try _ = stackDUT.pop())
        XCTAssertNoThrow(try _ = stackDUT.pop())
        
        XCTAssertThrowsError(try _ = stackDUT.pop())            
    }
    
    func testThatAnEmptyStackIsIntegerPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()
        XCTAssertTrue(stackDUT.isIntegerPresentable)        
    }

    func testThatAnEmptyStackIsFloatingPointPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()
        XCTAssertTrue(stackDUT.isFloatingPointPresentable)        
    }
        
    func testThatAStackWithIntegerOperandsIsIntegerPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()

        let intOperand1 : Operand = Operand(integerValue: 0)
        let intOperand2 : Operand = Operand(integerValue: 1)
        let intOperand3 : Operand = Operand(integerValue: -1)
        let intOperand4 : Operand = Operand(integerValue: Int.max)
        
        let intOperands : [Operand] = [intOperand1, intOperand2, intOperand3, intOperand4]
        
        stackDUT.push(operands: intOperands)
        
        XCTAssertTrue(stackDUT.isIntegerPresentable)
    }

    func testThatAStackWithIntegerOperandsAndIntegerFloatingPpintsIsIntegerPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let intOperand1 : Operand = Operand(floatingPointValue: 300.0)
        let intOperand2 : Operand = Operand(floatingPointValue: -12223300.0)
        let intOperand3 : Operand = Operand(integerValue: -1)
        let intOperand4 : Operand = Operand(integerValue: Int.max)
        
        let intOperands : [Operand] = [intOperand1, intOperand2, intOperand3, intOperand4]
        
        stackDUT.push(operands: intOperands)
        
        XCTAssertTrue(stackDUT.isIntegerPresentable)
    }

    func testThatAStackWithFloatingPointOperandsIsFloatingPointPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let floatOperand1 : Operand = Operand(floatingPointValue: 0.1)
        let floatOperand2 : Operand = Operand(floatingPointValue: 1.234)
        let floatOperand3 : Operand = Operand(floatingPointValue: -1.33)
        let floatOperand4 : Operand = Operand(floatingPointValue: Double.greatestFiniteMagnitude)
        
        let floatOperands : [Operand] = [floatOperand1, floatOperand2, floatOperand3, floatOperand4]
        
        stackDUT.push(operands: floatOperands)
        
        XCTAssertTrue(stackDUT.isFloatingPointPresentable)
    }

    func testThatAStackWithFloatingPointOperandsIsNotIntegerPresentatable()
    {
        let stackDUT: OperandStack  = OperandStack()
        
        let floatOperand1 : Operand = Operand(floatingPointValue: 0.1)
        let floatOperand2 : Operand = Operand(floatingPointValue: 1.234)
        let floatOperand3 : Operand = Operand(floatingPointValue: -1.33)
        let floatOperand4 : Operand = Operand(floatingPointValue: Double.greatestFiniteMagnitude)
        
        let floatOperands : [Operand] = [floatOperand1, floatOperand2, floatOperand3, floatOperand4]
        
        stackDUT.push(operands: floatOperands)
        
        XCTAssertFalse(stackDUT.isIntegerPresentable)

        // sneak in one integer operand
        stackDUT.push(operand: Operand(integerValue: 1))
        
        // the stack should not be integerpresentable
        XCTAssertFalse(stackDUT.isIntegerPresentable)

    }
    

}
