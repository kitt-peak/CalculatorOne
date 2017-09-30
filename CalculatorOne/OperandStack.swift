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
    enum StackError: Error 
    {
        case indexOutOfRange
    }

    private var stack: [Operand]   = [Operand]()
    
    

    init(operands: [Operand])
    {
        stack.removeAll()
        stack.append(contentsOf: operands)
    }
    
    convenience init() 
    {
        self.init(operands: [])
    }
    

    //MARK: - Stack operations    
    func pop() throws -> Operand
    {
        if let last: Operand = stack.popLast()
        {
            return last
        }
        
        throw Engine.EngineError.popOperandFromEmptyStack            
    }

    func pop(count: Int) throws -> [Operand]
    {
        if count <= stack.count
        {
            let result = stack[stack.count - count ..< stack.endIndex]            
            stack.removeSubrange(stack.count - count ..< stack.endIndex)
            
            return Array<Operand>(result)
        }
        
        throw Engine.EngineError.popOperandFromEmptyStack            
    }

    // makeing subscript private until Swift allows to throw in subscript functions
    private subscript(index: Int) -> Operand 
    {
        get 
        {
            return stack[index]                
        }
        
        set(newValue) 
        { 
            stack[index] = newValue
        }
    }
    
    // emulates a subscript function that can throw
    func operandAtIndex(_ index: Int) throws -> Operand
    {
        if index >= 0 && index < stack.count
        {
            return stack[index]
        }
    
        throw StackError.indexOutOfRange
        
    }
    
    // emulates a subscript function that can throw
    func setOperand(_ operand: Operand, atIndex: Int) throws
    {
        if atIndex >= 0 && atIndex < stack.count
        {
            stack[atIndex] = operand
            
            return
        }
        
        throw StackError.indexOutOfRange
        
    }

    
    func push(operand: Operand)
    {
        stack.append(operand)
    }
    
    func push(operands: [Operand])
    {
        stack.append(contentsOf: operands)
    }
    
    func removeOperandsFromTop(count: Int) throws
    {
        guard count <= stack.count else { throw Engine.EngineError.popOperandFromEmptyStack }
        
        stack.removeLast(count)
    }
    
    func removeAll()
    {
        stack.removeAll()
    }
    
    func allOperands() -> [Operand]
    {
        return stack
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

    
    var description: String
    { 
        var operandsDescriptions: [String] = [String]()
        
        for op in stack
        {
            operandsDescriptions.append("{" + op.description + "}")
        }
        
        return "[" + operandsDescriptions.joined(separator: ", ") + "]"
    }
}
