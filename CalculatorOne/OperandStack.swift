//
//  OperandStack.swift
//  CalculatorOne
//
//  Created by Andreas on 15.08.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Foundation

class OperandStack: CustomStringConvertible
{
    private var stack: [Operand]   = [Operand]()

    init(operands: [Operand])
    {
        stack.removeAll()
        stack.append(contentsOf: operands)
    }
    

    //MARK: - Stack operations    
    func pop() throws -> Operand
    {
        if let last: Operand = stack.popLast()
        {
            return last
        }
        else
        {
            throw Engine.EngineError.popOperandFromEmptyStack            
        }
    }
    
    // TODO: make this function throw and use subscript syntax of Swift
    func operandAtIndex(_ index: Int) -> Operand
    {
        return stack[index]
    }
    
    func push(operand: Operand)
    {
        stack.append(operand)
    }
    
    func push(operands: [Operand])
    {
        stack.append(contentsOf: operands)
    }
    
    func clear()
    {
        stack.removeAll()
    }
    
    func allOperands() -> [Operand]
    {
        return stack
    }

    func updateAtIndex(_ index: Int, withValue: Operand)
    {
        if index >= 0 && index <= stack.endIndex
        {
            stack[index] = withValue
        }
        else
        {
            assertionFailure("! Error stack update index <\(index)> out of range (allowed stack index range: \(stack.startIndex)..<\(stack.endIndex))")
        }
    }
    
    func operandAtIndexFromTop(_ index: Int) -> Operand
    {
        if index >= 0 && index <= stack.endIndex
        {
            return stack.reversed()[index]
        }
        else
        {
            assertionFailure("! Error stack update index <\(index)> out of range (allowed stack index range: \(stack.startIndex)..<\(stack.endIndex))")
        }
        
        abort()
    }
    
    
    var count: Int { return stack.count }

    var isFloatingPointPresentable: Bool 
    {
        let result: Bool = stack.reduce(true, { (lastResult, operand) -> Bool in
            return lastResult && operand.isFloatingPointPresentable
        })
        
        return result
    }

    var isIntegerPresentable: Bool 
    {
        let result: Bool = stack.reduce(true, { (lastResult, operand) -> Bool in
            return lastResult && operand.isIntegerPresentable
        })
        
        return result
    }

    
    var description: String { return "???" }
}
