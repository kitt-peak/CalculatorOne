//
//  Engine.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Foundation




func sign<T: Integer>(_ x: T) -> Int
{
    return x == 0 ? 1 : (x > 0 ? 1 : -1)
}


enum Radix: Int
{
    case binary = 0, octal = 1, decimal = 2, hex = 3
    
    var value: Int
    {
        switch self 
        {
        case .binary:   return 2
        case .octal:    return 8
        case .decimal:  return 10
        case .hex:      return 16
        }
    }
}


class Engine: NSObject, DependendObjectLifeCycle, KeypadControllerDelegate, DisplayDataSource, KeypadDataSource
{
    
    //MARK: - Mathematical class functions
    
    class func valueWithDigitCleared(value: Int, digitIndex: Int, radix: Int) -> Int
    {
        let leftDigitsSetToZero: Int = value % Int(pow(Double(radix), Double(digitIndex + 1)))
        let rightDigits: Int         = value % Int(pow(Double(radix), Double(digitIndex)))
        
        let newValue = value - leftDigitsSetToZero + rightDigits
    
        return newValue
    }
    
    
    class func valueWithDigitReplaced(value: Int, digitIndex: Int, newDigitValue: Int, radix: Int) -> Int
    {
        let valueWithDigitCleared: Int = Engine.valueWithDigitCleared(value: value, digitIndex: digitIndex, radix: radix)
        let valueNewDigit: Int         = newDigitValue * Int(pow(Double(radix),Double(digitIndex)))
        let valueNewDigitSignCorrected = valueNewDigit * sign(value)
        
        return valueWithDigitCleared + valueNewDigitSignCorrected
    }
    
    
    //MARK: - Private properties
    
    private var stack: [Int] = [Int]()
    
    @IBOutlet weak var document: Document!
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() 
    {
        super.awakeFromNib()
    }
    
    
    func documentDidOpen() 
    {
        
    }
    
    func documentWillClose()
    {
        
    }
    
    //MARK: - Stack operation    
    private func pop() -> Int
    {
        if let last: Int = stack.popLast()
        {
            return last
        }
        else
        {
            assertionFailure("! Abort due to empty engine stack")
            abort()
        }
    }

    
    
    
    //MARK: - Core operations
    private typealias OperationsTable = [String : OperationType]!
    
    private enum OperationType
    {
        case drop
        case constant         (Int)
        case unary2binary(    (Int)      -> (Int, Int))
        case unary(           (Int)      -> Int)
        case binary(          (Int, Int) -> Int)
        case binary2binary(   (Int, Int) -> (Int, Int))
        case ternary2ternary( (Int, Int, Int) -> (Int, Int, Int) )
    }
    
    private var operations: OperationsTable =  [
           "π" : .constant(3), 

           "±" : .unary( { (a: Int)         -> Int in return -a    }),
           "√" : .unary( { (a: Int)         -> Int in return (Int(sqrt(Double(a))))}),
           "!" : .unary( { (a: Int)         -> Int in return  ~a   }),
           
         "DUP" : .unary2binary({ (a: Int) -> (Int, Int) in return (a, a) }),
           
        "DROP" : .drop,

           "+" : .binary({ (a: Int, b: Int) -> Int in return a + b }),
           "-" : .binary({ (a: Int, b: Int) -> Int in return b - a }),
           "*" : .binary({ (a: Int, b: Int) -> Int in return a * b }),
           "/" : .binary({ (a: Int, b: Int) -> Int in return b / a }),
           "&" : .binary({ (a: Int, b: Int) -> Int in return a & b }),
           "|" : .binary({ (a: Int, b: Int) -> Int in return b | a }),
           "^" : .binary({ (a: Int, b: Int) -> Int in return a ^ b }),

        "SWAP" : .binary2binary ({ (a: Int, b: Int) -> (Int, Int) in return (b, a) }),
        
        "ROT"  : .ternary2ternary ( { (a: Int, b: Int, c: Int) -> (Int, Int, Int) in return (b, c, a) })
    ]
    
    
    // MARK: - Output to user
    private func updateUI()
    {
        let updateUINote: Notification = Notification(name: GlobalNotification.newEngineResult.notificationName, object: document, userInfo: [:])
        NotificationCenter.default.post(updateUINote)
    }


    // MARK: - Keypad controller delegate: user input
    func userUpdatedStackTopValue(_ updatedValue: String, radix: Int)
    {
        if let updatedInt: Int = Int(updatedValue, radix: radix)
        {
            if stack.isEmpty
            {
                stack.append(updatedInt)
            }
            else
            {
                stack[stack.count - 1] = updatedInt
            }
            
            updateUI()
        }
    }
    
    func userInputEnter()
    {
        if !stack.isEmpty
        {
            stack.append(stack.last!)
        }
        else
        {
            stack.append(0)            
        }
        
        updateUI()
    }
    
    func userInputOperand(operandSymbol: String) 
    {
        if let currentOperation = operations[operandSymbol]
        {
            switch currentOperation 
            {
            case .constant(let c):
                stack.append(c)

            case .binary(let binaryFunction):
                let a: Int = pop()
                let b: Int = pop()
                
                let r: Int = binaryFunction(a, b)
                
                stack.append(r)
                
            case .unary(let unaryFunction):
                let a: Int = pop()
                
                let r: Int = unaryFunction(a)

                stack.append(r)
                
            case .drop:
                _ = stack.popLast()!
                
                
            case .binary2binary(let swapFunction):
                var a: Int = pop()
                var b: Int = pop()

                (a, b) = swapFunction(a, b)
                
                stack.append(b)
                stack.append(a)
                
               
            case .ternary2ternary(let ternaryFunction):
                var a: Int = pop()
                var b: Int = pop()
                var c: Int = pop()
                
                (a, b, c) = ternaryFunction(a, b, c)
                
                stack.append(c)
                stack.append(b)
                stack.append(a)
                
            case .unary2binary(let unary2binaryFunction):
                var a: Int = pop()
                var b: Int = 0
                
                (a, b) = unary2binaryFunction(a)
                
                stack.append(b)
                stack.append(a)
                
            }
            
            updateUI()            
        }

        else
        {
            print("! operand \(operandSymbol) not implemented")
        }
    }
        

    //MARK: - Keypad data source protocoll
    func numberOfRegistersWithContent() -> Int 
    {
        return stack.count
    }
    
    //MARK: - Display data source protocoll
    func hasValueForRegister(registerNumber: Int) -> Bool 
    {
        return stack.count > registerNumber
    }
    
    func registerValue(registerNumber: Int) -> Int 
    {
        return stack.reversed()[registerNumber]
    }
    
    func registerValueChanged(newValue: Int, forRegisterNumber: Int) 
    {
        if stack.isEmpty
        {
            stack.append(newValue)
        }
        else
        {
            stack[stack.count - forRegisterNumber - 1] = newValue            
        }
    }
    
    
    override var description: String
    {
        var s: String = super.description + "\n"
        
        s = s + stack.description
        
        return s
    }
    
    
    
}
