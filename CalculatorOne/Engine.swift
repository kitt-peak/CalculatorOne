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


enum OperandType: Int
{
    case integer, float
}

enum OperandValue: CustomStringConvertible
{
    case integer(Int)
    case float(Double)
    
    var stringValue: String
    {
        switch self 
        {
        case .integer(let i): return String(describing: i)
        case .float(let f):   return String(describing: f)
        }
    }
    
    var description: String
    {
        switch self 
        {
        case .integer(let i): return "integer " + String(describing: i)
        case .float(let f):   return "float " + String(describing: f)
        }        
    }
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
    
    private var stack: [OperandValue] = [OperandValue]()
    
    private var operandType: OperandType = .integer
    
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
    
    //MARK: - Stack operations    
    private func pop() -> OperandValue
    {
        if let last: OperandValue = stack.popLast()
        {
            return last
        }
        else
        {
            assertionFailure("! Abort due to empty engine stack")
            abort()
        }
    }


    private func popInteger() -> Int
    {
        let value: OperandValue = pop()
        
        if case .integer(let integerValue) = value
        {
            return integerValue
        }
        
        assertionFailure("! Abort due to mismatched engine stack type")
        abort()
        
    }

    private func popFloat() -> Double
    {
        let value: OperandValue = pop()
        
        if case .float(let floatValue) = value
        {
            return floatValue
        }
        
        assertionFailure("! Abort due to mismatched engine stack type")
        abort()
        
    }

    
    //MARK: - Core operations
    private typealias OperationsTable = [String : OperationClass]!
    
    private enum OperationClass
    {
        case drop
        case dropN
        case dropAll
        case binary2binary(   (OperandValue, OperandValue) -> (OperandValue, OperandValue))
        case ternary2ternary( (OperandValue, OperandValue, OperandValue) -> (OperandValue, OperandValue, OperandValue) )
        case unary2binary(    (OperandValue)      -> (OperandValue, OperandValue))
        
        case integerBinary(   (Int, Int)       -> OperandValue)
        case integerUnary(    (Int)            -> OperandValue)
        
        case floatUnary(      (Double) -> OperandValue)
        case floatBinary(     (Double, Double) -> OperandValue)
        case floatConstant    (OperandValue)

    }
    
    private var typelessOperations: OperationsTable = 
    [
        "DUP"       : .unary2binary({ (a: OperandValue) -> (OperandValue, OperandValue) in return (a, a) }),
        
        "DROP"      : .drop,
        "DROP ALL"  : .dropAll,
        
        "⇔" : .binary2binary ({ (a: OperandValue, b: OperandValue) -> (OperandValue, OperandValue) in return (b, a) }), /*swap*/
        
        "R↓"  : .ternary2ternary ( { (a: OperandValue, b: OperandValue, c: OperandValue) -> (OperandValue, OperandValue, OperandValue) in return (b, c, a) }),
        "R↑"  : .ternary2ternary ( { (a: OperandValue, b: OperandValue, c: OperandValue) -> (OperandValue, OperandValue, OperandValue) in return (c, a, b) })

        
    ]
    
    private var floatOperations: OperationsTable =
    [
        "π" : .floatConstant(OperandValue.float(Double.pi)), 
        
        "+" : .floatBinary( { (a: Double, b: Double) -> OperandValue in return .float(b + a) }),
        "-" : .floatBinary( { (a: Double, b: Double) -> OperandValue in return .float(b - a) }),
        "*" : .floatBinary( { (a: Double, b: Double) -> OperandValue in return .float(b * a) }),
        "÷" : .floatBinary( { (a: Double, b: Double) -> OperandValue in return .float(b / a) }),
        
        "√" : .floatUnary( { (a: Double)         -> OperandValue in return  .float(sqrt(a))}),
      "SQR" : .floatUnary( { (a: Double)         -> OperandValue in return  .float(a*a)   }),
    "1 ÷ X" : .floatUnary( { (a: Double)         -> OperandValue in return  .float(1.0 / a)}),


    "+ ⇔ -" : .floatUnary( { (a: Double)         -> OperandValue in return .float(-a)    }),

    ]
    
    private var integerOperations: OperationsTable =  [
           
           "N DROP" : .dropN,

       "+ ⇔ -" : .integerUnary( { (a: Int)         -> OperandValue in return .integer(-a)    }),
           
           "!" : .integerUnary( { (a: Int)         -> OperandValue in return .integer(~a)  }),
       
           "+" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b + a) }),
           "-" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b - a) }),
           "*" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b * a) }),
           "÷" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b / a) }),
           "%" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b % a) }),
           "&" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b & a) }),
           "|" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b | a) }),
           "^" : .integerBinary({ (a: Int, b: Int) -> OperandValue in return .integer(b ^ a) }),
       "X * X" : .integerUnary( { (a: Int)       -> OperandValue in return  .integer(a*a)   }),

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
                //stack.append(updatedInt)
            }
            else
            {
                //stack[stack.count - 1] = updatedInt
            }
            
            updateUI()
        }
    }
    
    func userInputOperandType(_ type: Int) 
    {
        if let newOperandType: OperandType = OperandType(rawValue: type)
        {
            operandType = newOperandType
            
            // convert all elements on the stack to the new operand
            for (index, value) in stack.enumerated()
            {
                switch value 
                {
                case .integer(let i): stack[index] = .float(Double(i))
                case .float(let f):   stack[index] = .integer(Int(f))
                }
            }
            
            updateUI()
        }
    }
    

    func userWillInputEnter(numericalValue: String, radix: Int) -> Bool
    {
        switch operandType 
        {
        case .integer: 
            if let _ = Int(numericalValue, radix: radix) { return true }
        case .float:
            if let _ = Double(numericalValue) { return true }
        }
        
        return false
    }
    
    
    func userInputEnter(numericalValue: String, radix: Int)
    {        
        var value: OperandValue!
        
        switch operandType 
        {
        case .integer: value = OperandValue.integer(Int(numericalValue, radix: radix)!)
        case .float:   value = OperandValue.float(Double(numericalValue)!)
        }
        
        print("\(self)\n| \(#function): adding '\(value)' to top of stack")
        stack.append(value)
        print(stackDescription)

        updateUI()
    }
    
    func userInputOperation(symbol: String) 
    {
        
        // perform typeless operations first. If no typeless information is found,
        // the program continues to look for integer and floating point operations
        if let currentOperation = typelessOperations[symbol]
        {
            print("\(self)\n| \(#function): performing operation '\(symbol)'")
            
            switch currentOperation 
            {
            case .drop:
                _ = stack.popLast()!
                
            case .dropAll:
                stack.removeAll()

            case .binary2binary(let swapFunction):
                var a: OperandValue = pop()
                var b: OperandValue = pop()
                
                (a, b) = swapFunction(a, b)
                
                stack.append(b)
                stack.append(a)
                
                
            case .ternary2ternary(let ternaryFunction):
                var a: OperandValue = pop()
                var b: OperandValue = pop()
                var c: OperandValue = pop()
                
                (a, b, c) = ternaryFunction(a, b, c)
                
                stack.append(c)
                stack.append(b)
                stack.append(a)
                
            case .unary2binary(let unary2binaryFunction):
                var a: OperandValue = pop()
                var b: OperandValue = .integer(0)
                
                (a, b) = unary2binaryFunction(a)
                
                stack.append(b)
                stack.append(a)

            default:
                break
            }
            
        }
        
        
        switch operandType
        {
        case .integer:
            
            if let currentOperation = integerOperations[symbol]
            {
                print("\(self)\n| \(#function): performing integer operation '\(symbol)'")
                
                switch currentOperation 
                {
                case .integerBinary(let binaryFunction):
                    let a: Int = popInteger()
                    let b: Int = popInteger()
                    
                    let r: OperandValue = binaryFunction(a, b)
                    
                    stack.append(r)
                    
                case .integerUnary(let unaryFunction):
                    let a: Int = popInteger()
                    
                    let r: OperandValue = unaryFunction(a)
                    
                    stack.append(r)
                    
                case .dropN:
                    let a: Int = popInteger()
                    
                    for _ in 0..<a
                    {
                        _ = stack.popLast()
                    }
                    
                    
                default:
                    break
                }
            }
            else
            {
                print("\(self)\n| \(#function): integer operation '\(symbol)' not implemented. Stack was not changed")                    
            }
            
            
        case .float:
            
            if let currentOperation = floatOperations[symbol]
            {
                print("\(self)\n| \(#function): performing float operation '\(symbol)'")
                
                switch currentOperation 
                {
                case .floatConstant(let c):
                    stack.append(c)
                    
                case .floatBinary(let binaryFunction):
                    let a: Double = popFloat()
                    let b: Double = popFloat()
                    
                    let r: OperandValue = binaryFunction(a, b)
                    
                    stack.append(r)
                    
                case .floatUnary(let unaryFunction):
                    let a: Double = popFloat()
                    
                    let r: OperandValue = unaryFunction(a)
                    
                    stack.append(r)
            
                default:
                    break
                }
            }
        }
        
            
        updateUI() 
            
        print(stackDescription)

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
    
    func registerValue(registerNumber: Int, radix: Int) -> String
    {
        let value: OperandValue = stack.reversed()[registerNumber]
        
        switch value 
        {
        case .integer(let i): return String(i, radix: radix, uppercase: true)
        case .float(let f):   return String(describing: f)
        }
    }
    
    func registerValueChanged(newValue: Int, forRegisterNumber: Int) 
    {
        if stack.isEmpty
        {
            //stack.append(newValue)
        }
        else
        {
            //stack[stack.count - forRegisterNumber - 1] = newValue            
        }
    }
    
    private var stackDescription: String
    {
        return "| Stack [\(stack.count)]: " + stack.description
    }
    
    override var description: String
    {
        var str: String = "Engine [\(Unmanaged.passUnretained(self).toOpaque())]\n" 

        str = str + stackDescription
        
        return str
    }
    
    
    
}
