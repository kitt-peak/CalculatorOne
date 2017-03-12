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
        case .integer( _): return "integer " + stringValue
        case .float( _):   return "float " + stringValue
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
    
    // MARK: - Mathematical class variables
    class var const_e: Double  { return 2.71828182845904523536028747135266249775724709369995 }
    class var const_π: Double { return 3.14159265358979323846264338327950288419716939937510 }
    
    class var const_c0:   Double { return 299792458.0}      /* speed of light in m/s, exact */
    class var const_µ0:   Double { return 1.256637061E-6 }  /* magnetic constant */
    class var const_epsilon0: Double { return 8.854187817E-12 } /* electrical constant */
    class var const_h:    Double { return 6.62607004081E-34 }    /* Planck's constant in J*s */
    class var const_k:    Double { return 1.3806485279E-23 }    /* Boltzmann constant */
    class var const_g:    Double { return 9.80665 }           /* earth acceleration */
    class var const_G:    Double { return 6.6740831E-11 }     /* gravitational constant */
    
    
    //case epsilon0 = "ε₀", µ0 = "μ₀", c0 = "c₀", k0 = "k₀", e0 = "e₀", G = "G", g = "g"

    
    
    
    // MARK: - Integer class functions
    @nonobjc class func sum(of a: [Int]) -> Int { return a.reduce(0) { (x, y) -> Int in return x + y } }
    //@nonobjc class func avg(of a: [Int]) -> Int { return a.reduce(0) { (x, y) -> Int in return x + y } / a.count}
    @nonobjc class func factorial(of a: Int) -> Int 
    { 
        if a < 0 { return 0 }
        if a < 1 { return 1 }
        return a * Engine.factorial(of: a-1)
    }
    @nonobjc class func twoExpN(of n: Int) -> Int { return n < 0 ? 0 : n == 0 ? 1 : (2 << (n-1)) } 
    
    /* EUCLID algorithm for GCD */
    @nonobjc class func gcd(of a: Int, _ b: Int) -> Int { if b == 0 { return a } else { return gcd(of: b, a % b)} }  
    @nonobjc class func lcm(of a: Int, _ b: Int) -> Int { return abs(abs(a * b) / gcd(of: a, b)) }  

    // MARK: - Double class functions
    @nonobjc class func sum(of a: [Double]) -> Double { return a.reduce(0.0) { (x, y) -> Double in return x + y } }
    @nonobjc class func avg(of a: [Double]) -> Double { return a.reduce(0.0) { (x, y) -> Double in return x + y } / Double(a.count)}
    @nonobjc class func product(of a: [Double]) -> Double { return a.reduce(1.0) { (x, y) -> Double in return x * y } }
    
    @nonobjc class func nRoot(of a: Double, _ b: Double) -> Double { return pow(const_e, log(a)/b)}
    
    @nonobjc class func geometricalMean(of a: [Double]) -> Double { return Engine.nRoot(of: a.reduce(1.0) { (x, y) -> Double in return x * y },  Double(a.count) ) }

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
        if let savedStack = document.currentConfiguration[Document.ConfigurationKey.stackValues.rawValue] as? NSArray
        {
            if let operandType = document.currentConfiguration[Document.ConfigurationKey.operandType.rawValue] as? Int
            {
                switch operandType 
                {
                case OperandType.float.rawValue:
                    
                    for value in savedStack as! [Double]
                    {
                        stack.append(OperandValue.float(value))
                    }

                case OperandType.integer.rawValue:

                    for value in savedStack as! [Int]
                    {
                        stack.append(OperandValue.integer(value))
                    }
                    
                default: break
                }
            }
            
            updateUI()
        }
    }
    
    func documentWillClose()
    {
        // save the stack to the configuration data in the document
        
        let savedStack: NSMutableArray = NSMutableArray()
        
        for value in stack
        {
            switch value 
            {
            case .float(let f):   savedStack.add(f)
            case .integer(let i): savedStack.add(i)
            }
        }
        
        document.currentConfiguration[Document.ConfigurationKey.stackValues.rawValue] = savedStack        
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
        case dropAll, nDrop, depth
        
        case unary2array(   (OperandValue) -> [(OperandValue)] )
        case binary2array(  (OperandValue, OperandValue) -> [(OperandValue)] )
        case ternary2array( (OperandValue, OperandValue, OperandValue) -> [(OperandValue)] )
                
        case integerUnary2array(  (Int)      -> ([OperandValue]))
        case integerBinary2array( (Int, Int) -> ([OperandValue]))
        case integerArray2array(  ([Int])    -> ([OperandValue]))
        
        case floatNone2array(   () -> ([OperandValue]))
        case floatUnary2array(  (Double)         -> ([OperandValue]))
        case floatBinary2array( (Double, Double) -> ([OperandValue]))
        case floatArray2array(([Double])          -> [OperandValue])      

    }
    
    private var typelessOperations: OperationsTable = 
    [
      Symbols.dup.rawValue       : .unary2array( { (a: OperandValue) -> [OperandValue] in return ([a, a]) }),
      Symbols.dup2.rawValue      : .binary2array({ (a: OperandValue, b: OperandValue) -> [OperandValue] in return [b, a, b, a] }),
        
      Symbols.drop.rawValue      : .unary2array(  { (a: OperandValue) -> [OperandValue] in return []}),
      Symbols.dropAll.rawValue   : .dropAll,
      Symbols.depth.rawValue     : .depth,
        
      Symbols.swap.rawValue      : .binary2array ({ (a: OperandValue, b: OperandValue) -> ([OperandValue]) in return [a, b] }), /*swap*/
        
      Symbols.rotateDown.rawValue: .ternary2array ( { (a: OperandValue, b: OperandValue, c: OperandValue) -> ([OperandValue]) in return [a, c, b] }),
      Symbols.rotateUp.rawValue  : .ternary2array ( { (a: OperandValue, b: OperandValue, c: OperandValue) -> ([OperandValue]) in return [b, a, c] })
    ]
    
    private var floatOperations: OperationsTable =
    [
        Symbols.π.rawValue :    .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_π)] }), 
        Symbols.e.rawValue :    .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_e)]  }),
        Symbols.µ0.rawValue:    .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_µ0)]  }),
        Symbols.epsilon0.rawValue:  .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_epsilon0)] }),
        Symbols.c0.rawValue:    .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_c0)]  }),
        Symbols.h.rawValue:     .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_h)]  }),
        Symbols.k.rawValue:     .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_k)]  }),
        Symbols.g.rawValue:     .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_g)]  }),
        Symbols.G.rawValue:     .floatNone2array( { () -> ([OperandValue]) in return [OperandValue.float(const_G)]  }),
        
        Symbols.plus.rawValue     : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(b + a)] }),
        Symbols.minus.rawValue    : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(b - a)] }),
        Symbols.multiply.rawValue : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(b * a)] }),
        Symbols.divide.rawValue   : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(b / a)] }),
        
       "Yˣ" : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(pow(b, a))] }),
   "logY X" : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(log(a) / log(b))] }),
   
      "N √" : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.nRoot(of: b, a))] }),

        
       "eˣ" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(pow(const_e, a))] }),
      "10ˣ" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(pow(10.0, a))] }),
       "2ˣ" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(pow(2.0, a))] }),

       "ln" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log(a))] }),
      "log" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log10(a))] }),
       "lb" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log2(a))] }),
       
        "√" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(sqrt(a))] }),
        "∛" :  .floatUnary2array( { (a: Double)        -> [OperandValue] in return  [.float(Engine.nRoot(of: a, 3.0))] }),
      "1÷X" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(1.0 / a)] }),
     "1÷X²" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(1.0 / (a * a))] }),      
       "X²" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(a*a)]   }),
       "X³" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(a*a*a)] }),

      "+⇔-" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(-a)]     }),
      "sin"  : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(sin(a))]  }),
      "asin" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(asin(a))] }),
      "cos"  : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(cos(a))]  }),
      "acos" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(acos(a))] }),
      "tan"  : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(tan(a))]  }),
      "atan" : .floatUnary2array( { (a: Double)         -> [OperandValue] in return [.float(atan(a))] }),
      
      "∑" : .floatArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.sum(of: s))]}),
    "AVG" : .floatArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.avg(of: s))]}),
      "∏" : .floatArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.product(of: s))]}),
     "∏√" : .floatArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.geometricalMean(of: s))]}),
        
    ]
    
    private var integerOperations: OperationsTable =  [
           
      "N DROP" : .nDrop,
      
      Symbols.plus.rawValue     : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b + a)] }),
      Symbols.minus.rawValue    : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b - a)] }),
      Symbols.multiply.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b * a)] }),
      Symbols.divide.rawValue   : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b / a)] }),
      Symbols.moduloN.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b % a)] }),
           
      Symbols.and.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b & a)] }),
      Symbols.or.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b | a)] }),
      Symbols.xor.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b ^ a)] }),
           
      Symbols.nShiftLeft.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b << a)] }),
      Symbols.nShiftRight.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(b >> a)] }),
      Symbols.gcd.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(Engine.gcd(of: a, b) )] }),
      Symbols.lcm.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [OperandValue] in return [.integer(Engine.lcm(of: a, b) )] }),

        "+⇔-" : .integerUnary2array( { (a: Int)   -> [OperandValue] in return [.integer(-a)]  }),
           "~" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return [.integer(~a)]  }),
           
          "X²" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a*a)]   }),
          "2ˣ" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(Engine.twoExpN(of: a))] }),
      Symbols.shiftLeft.rawValue : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a << 1)] }),
      Symbols.shiftRight.rawValue : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a >> 1)] }),
         "1 +" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a + 1)] }),
         "1 -" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a - 1)] }),
          
           "∑" : .integerArray2array( { (s: [Int]) -> [OperandValue] in return [.integer( s.reduce(0) { (x, y) -> Int in return x + y })]}),
          
          Symbols.factorial.rawValue : .integerUnary2array( { (a: Int)   -> [OperandValue] in return [.integer(Engine.factorial(of: a) )] })
        
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
    

    /// Tests if an enter command with the specified numerical value can be accepted by the engine 
    /// The engine does not process the numberical value. It only checks if numericalValue is valid
    ///
    /// - Parameters:
    ///   - numericalValue: the value to check as string
    ///   - radix: the radix of the value
    /// - Returns: true if the engine numerical value is valid for the engine, otherwise false
    func userWillInputEnter(numericalValue: String, radix: Int) -> Bool
    {
        // the methods tests if the value can be converted from String to the current operand type
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
        guard numericalValue.characters.count > 0 else { return }
        
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
        DispatchQueue.global(qos: .userInitiated).sync 
        {
            self.processOperation(symbol: symbol)
            
            DispatchQueue.main.async 
            {
                self.updateUI()
            }
        }
        
    }
    
    private func processOperation(symbol: String) 
    {
        var typelessOperationCompleted: Bool = true
        var integerOperationCompleted: Bool = true
        var floatOperationCompleted: Bool = true
        
        // perform typeless operations first. If no typeless information is found,
        // the program continues to look for integer and floating point operations
        if let currentOperation = typelessOperations[symbol]
        {
            switch currentOperation 
            {
                
            case .dropAll:
                stack.removeAll()
                
            case .depth:
                let a: Int = stack.count 
                    
                switch operandType 
                {
                case .integer: stack.append(OperandValue.integer(a))
                case .float  : stack.append(OperandValue.float(Double(a)))
                }
                    
            case .unary2array(let u2aFunction):
                let a: OperandValue = pop()
                
                stack.append(contentsOf: u2aFunction(a))

            case .binary2array(let b2aFunction):
                let a: OperandValue = pop()
                let b: OperandValue = pop()

                stack.append(contentsOf: b2aFunction(a, b))
                
            case .ternary2array(let t2aFunction):
                let a: OperandValue = pop()
                let b: OperandValue = pop()
                let c: OperandValue = pop()
                
                stack.append(contentsOf: t2aFunction(a, b, c))
                

            default:
                typelessOperationCompleted = false
            }
        }
        else
        {
            typelessOperationCompleted = false
        }

        
        switch operandType
        {
        case .integer:
            
            floatOperationCompleted = false
            
            if let currentOperation = integerOperations[symbol]
            {
                switch currentOperation 
                {
                case .integerUnary2array(let int2arrayFunction):
                    let a: Int = popInteger()
                    
                    let r: [OperandValue] = int2arrayFunction(a)
                    
                    stack.append(contentsOf: r)

                case .integerBinary2array(let int2arrayFunction):
                    let a: Int = popInteger()
                    let b: Int = popInteger()
                    
                    let r: [OperandValue] = int2arrayFunction(a, b)
                    
                    stack.append(contentsOf: r)

                                        
                case .integerArray2array(let arrayFunction):
                    let s: [Int] = stack.map({ (e: OperandValue) -> Int in
                        if case .integer(let i) = e { return i}
                        return -1
                    })
                    
                    let b = arrayFunction(s)
                    
                    stack.removeAll()
                    stack.append(contentsOf: b)
                                        
                case .nDrop:
                    let a: Int = popInteger()
                    
                    for _ in 0..<a
                    {
                        _ = stack.popLast()
                    }
                    
                default:
                    integerOperationCompleted = false
                }
            }
            else
            {
                integerOperationCompleted = false
            }
            
        case .float:
            
            integerOperationCompleted = false
            
            if let currentOperation = floatOperations[symbol]
            {
                switch currentOperation 
                {

                case .floatNone2array(let n2aFunction):
                    let s: [OperandValue] = n2aFunction()
                    
                    stack.append(contentsOf: s)
                    
                case .floatUnary2array(let unaryFunction):
                    let a: Double = popFloat()
                    
                    let s: [OperandValue] = unaryFunction(a)
                    
                    stack.append(contentsOf: s)

                case .floatBinary2array(let binaryFunction):
                    let a: Double = popFloat()
                    let b: Double = popFloat()
                    
                    let s: [OperandValue] = binaryFunction(a, b)
                    
                    stack.append(contentsOf: s)
                    
                case .floatArray2array(let arrayFunction):
                    let s: [Double] = stack.map({ (e: OperandValue) -> Double in
                        if case .float(let d) = e { return d }
                        return -1.0 /*should never be executed*/
                    })
                    
                    let r: [OperandValue] = arrayFunction(s)
                    
                    stack.removeAll()
                    stack.append(contentsOf: r)
                    
                default: 
                    floatOperationCompleted = false
            
                }
            }
            else
            {
                floatOperationCompleted = false
            }

        }
        
        if typelessOperationCompleted == false && integerOperationCompleted == false && floatOperationCompleted == false
        {
            print("| engine \(#function): did not recognize operation \(operandType) '\(symbol)', stack not changed")                        
        }
        else
        {
            print("| engine \(#function): performed operation \(operandType) '\(symbol)'")            
            print(stackDescription)
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
