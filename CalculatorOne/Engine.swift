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
    
    
    
    //MARK: - Private properties
    
    private var stack: [OperandValue] = [OperandValue]()
    private var memoryA: [OperandValue] = [OperandValue]() 
    private var memoryB: [OperandValue] = [OperandValue]() 
    
    private var operandType: OperandType = .integer
    
    @IBOutlet weak var document: Document!
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() 
    {
        super.awakeFromNib()
    }
    
    
    func documentDidOpen() 
    {
        if let savedStack = document.currentSaveDataSet[Document.ConfigurationKey.stackValues.rawValue] as? NSArray
        {
            if let operandType = document.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue] as? Int
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
        }

        if let savedMemoryA = document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue] as? NSArray
        {
            if let operandType = document.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue] as? Int
            {
                switch operandType 
                {
                case OperandType.float.rawValue:
                    
                    for value in savedMemoryA as! [Double]
                    {
                        memoryA.append(OperandValue.float(value))
                    }
                    
                case OperandType.integer.rawValue:
                    
                    for value in savedMemoryA as! [Int]
                    {
                        memoryA.append(OperandValue.integer(value))
                    }
                    
                default: break
                }
            }            
        }

        if let savedMemoryB = document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue] as? NSArray
        {
            if let operandType = document.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue] as? Int
            {
                switch operandType 
                {
                case OperandType.float.rawValue:
                    
                    for value in savedMemoryB as! [Double]
                    {
                        memoryB.append(OperandValue.float(value))
                    }
                    
                case OperandType.integer.rawValue:
                    
                    for value in savedMemoryB as! [Int]
                    {
                        memoryB.append(OperandValue.integer(value))
                    }
                    
                default: break
                }
            }            
        }

        
        updateUI()

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
        
        document.currentSaveDataSet[Document.ConfigurationKey.stackValues.rawValue] = savedStack        
        
        // save memory A to the configuration data in the document        
        let savedMemoryA: NSMutableArray = NSMutableArray()
        
        for value in memoryA
        {
            switch value 
            {
            case .float(let f):   savedMemoryA.add(f)
            case .integer(let i): savedMemoryA.add(i)
            }
        }
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue] = savedMemoryA        

        // save memory B to the configuration data in the document        
        let savedMemoryB: NSMutableArray = NSMutableArray()
        
        for value in memoryB
        {
            switch value 
            {
            case .float(let f):   savedMemoryB.add(f)
            case .integer(let i): savedMemoryB.add(i)
            }
        }
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue] = savedMemoryB        

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
        case copyStackToA, copyStackToB, copyAToStack, copyBToStack
        
        case unary2array(   (OperandValue) -> [(OperandValue)] )
        case binary2array(  (OperandValue, OperandValue) -> [(OperandValue)] )
        case ternary2array( (OperandValue, OperandValue, OperandValue) -> [(OperandValue)] )
                
        case integerUnary2array(  (Int)      -> [OperandValue])
        case integerBinary2array( (Int, Int) -> [OperandValue])
        case integerArray2array(  ([Int])    -> [OperandValue])
        case integerNArray2array( ([Int])    -> [OperandValue])
        
        case floatNone2array(   () -> ([OperandValue]))
        case floatUnary2array(  (Double)         ->  [OperandValue])
        case floatBinary2array( (Double, Double) ->  [OperandValue])
        case floatArray2array(([Double])          -> [OperandValue])      
        case floatNArray2array(([Double])         -> [OperandValue])      

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
      Symbols.rotateUp.rawValue  : .ternary2array ( { (a: OperandValue, b: OperandValue, c: OperandValue) -> ([OperandValue]) in return [b, a, c] }),
      
      Symbols.copyAToStack.rawValue : .copyAToStack,
      Symbols.copyBToStack.rawValue : .copyBToStack,
      Symbols.copyStackToA.rawValue : .copyStackToA,
      Symbols.copyStackToB.rawValue : .copyStackToB,
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
        Symbols.plus.rawValue     : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.add(b, a))] }),
        Symbols.minus.rawValue    : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.subtract(b, a))] }),
        Symbols.multiply.rawValue : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.multiply(b, a))] }),
        Symbols.divide.rawValue   : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.divide(b, a))] }),
        Symbols.yExpX.rawValue : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(pow(b, a))] }),
        Symbols.logYX.rawValue : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(log(a) / log(b))] }),
        Symbols.nRoot.rawValue   : .floatBinary2array( { (a: Double, b: Double) -> [OperandValue] in return [.float(Engine.nRoot(of: b, a))] }),
        Symbols.eExpX.rawValue   : .floatUnary2array(  { (a: Double) -> [OperandValue] in return [.float(pow(const_e, a))] }),
        Symbols.tenExpX.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(pow(10.0, a))] }),
        Symbols.twoExpX.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(pow(2.0, a))] }),
        Symbols.logE.rawValue    : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log(a))] }),
        Symbols.log10.rawValue   : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log10(a))] }),
        Symbols.log2.rawValue    : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(log2(a))] }),
        Symbols.root.rawValue : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(sqrt(a))] }),
        Symbols.thridRoot.rawValue :  .floatUnary2array( { (a: Double)   -> [OperandValue] in return  [.float(Engine.thirdRoot(of: a))] }),
        Symbols.reciprocal.rawValue: .floatUnary2array( { (a: Double)       -> [OperandValue] in return  [.float(1.0 / a)] }),
        Symbols.reciprocalSquare.rawValue: .floatUnary2array( { (a: Double) -> [OperandValue] in return  [.float(1.0 / (a * a))] }),      
        Symbols.square.rawValue : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(a*a)]   }),
        Symbols.cubic.rawValue  : .floatUnary2array( { (a: Double)         -> [OperandValue] in return  [.float(a*a*a)] }),
        
      "+⇔-" : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(-a)]}),
        Symbols.sinus.rawValue  : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.sinus(a))]  }),
        Symbols.asinus.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.arcSinus(a))] }),
        Symbols.cosinus.rawValue  : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.cosinus(a))]  }),
        Symbols.acosinus.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.arcCosine(a))] }),
        Symbols.tangens.rawValue  : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.tangens(a))]  }),
        Symbols.atangens.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.arcTangens(a))] }),
        Symbols.cotangens.rawValue  : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.cotangens(a))]  }),
        Symbols.acotangens.rawValue : .floatUnary2array( { (a: Double) -> [OperandValue] in return [.float(Engine.arcCotangens(a))] }),
    Symbols.sum.rawValue  : .floatArray2array({ (s: [Double]) ->      [OperandValue] in return [.float(Engine.sum(of: s))]}),
    Symbols.nSum.rawValue : .floatNArray2array({(s: [Double]) ->      [OperandValue] in return [.float(Engine.sum(of: s))]}),
    Symbols.avg.rawValue  : .floatArray2array({ (s: [Double]) ->      [OperandValue] in return [.float(Engine.avg(of: s))]}),
    Symbols.nAvg.rawValue : .floatNArray2array({ (s: [Double]) ->     [OperandValue] in return [.float(Engine.avg(of: s))]}),
    Symbols.product.rawValue  : .floatArray2array({ (s: [Double]) ->  [OperandValue] in return [.float(Engine.product(of: s))]}),
    Symbols.nProduct.rawValue : .floatNArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.product(of: s))]}),
    Symbols.geoMean.rawValue  : .floatArray2array({  (s: [Double]) -> [OperandValue] in return [.float(Engine.geometricalMean(of: s))]}),
    Symbols.nGeoMean.rawValue : .floatNArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.geometricalMean(of: s))]}),
    Symbols.sigma.rawValue    : .floatArray2array({  (s: [Double]) -> [OperandValue] in return [.float(Engine.standardDeviation(of: s))]}),
    Symbols.nSigma.rawValue   : .floatNArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.standardDeviation(of: s))]}),
    Symbols.variance.rawValue : .floatArray2array( { (s: [Double]) -> [OperandValue] in return [.float(Engine.variance(of: s))]}),
    Symbols.nVariance.rawValue: .floatNArray2array({ (s: [Double]) -> [OperandValue] in return [.float(Engine.variance(of: s))]}),
        
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
           
      Symbols.square.rawValue : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a*a)]   }),
          "2ˣ" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(Engine.twoExpN(of: a))] }),
      Symbols.shiftLeft.rawValue : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a << 1)] }),
      Symbols.shiftRight.rawValue : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a >> 1)] }),
         "1 +" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a + 1)] }),
         "1 -" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a - 1)] }),
          
      Symbols.sum.rawValue  : .integerArray2array( { (s: [Int]) -> [OperandValue] in return [.integer(Engine.sum(of: s))]}),
      Symbols.nSum.rawValue : .integerNArray2array( { (s: [Int]) -> [OperandValue] in return [.integer(Engine.sum(of: s))]}),
      
      Symbols.factorial.rawValue : .integerUnary2array( { (a: Int)   -> [OperandValue] in return [.integer(Engine.factorial(of: a) )] })
        
    ]
    
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
                
            case .copyAToStack:
                stack.removeAll()
                stack.append(contentsOf: memoryA)
                
            case .copyBToStack: 
                stack.removeAll()
                stack.append(contentsOf: memoryB)
                
            case .copyStackToA:
                memoryA.removeAll()                
                memoryA.append(contentsOf: stack)
                
            case .copyStackToB:
                memoryB.removeAll()                
                memoryB.append(contentsOf: stack)
                
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
                    
                    /*take N arguments from the stack */
                case .integerNArray2array(let arrayFunction):
                    
                    let n: Int   = popInteger()    // specifies the number of arguments to pop from the stack
                    var s: [Int] = [Int]()         // the array of elements popped from the stack
                    
                    for _ : Int in 0 ..< n          // pop the specified number of arguments from the stack and put into array
                    {
                        s.append(popInteger())
                    }
                    
                    let r: [OperandValue] = arrayFunction(s)
                    stack.append(contentsOf: r)
                    
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
                    
                    // copy the entire stack into the array stackCopy
                    let stackCopy: [Double] = stack.map({ (e: OperandValue) -> Double in
                        if case .float(let d) = e { return d }
                        return -1.0 /*should never be executed*/
                    })
                    
                    stack.removeAll()
                    
                    if stackCopy.count > 0
                    {   let r: [OperandValue] = arrayFunction(stackCopy)
                        stack.append(contentsOf: r) }
                    
                    /*take N arguments from the stack */
                case .floatNArray2array(let arrayFunction):
                    
                    let n: Double   = popFloat()    // specifies the number of arguments to pop from the stack
                    var s: [Double] = [Double]()    // the array of elements popped from the stack
                    
                    for _ : Int in 0 ..< Int(n)          // pop the specified number of arguments from the stack and put into array
                    {
                        s.append(popFloat())
                    }
                    
                    let r: [OperandValue] = arrayFunction(s)
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
            print(description)
        }
        
        
    }
    

    
    // MARK: - Output to user
    private func updateUI()
    {
        let updateUINote: Notification = Notification(name: GlobalNotification.newEngineResult.name, object: document, userInfo: [:])
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
            
            // convert all elements on the stack to the new operand type
            for (index, value) in stack.enumerated()
            {
                switch value 
                {
                case .integer(let i): stack[index] = .float(Double(i))
                case .float(let f):   stack[index] = .integer(Int(f))
                }
            }
            
            // convert all elements in register A to the new operand type
            for (index, value) in memoryA.enumerated()
            {
                switch value 
                {
                case .integer(let i): memoryA[index] = .float(Double(i))
                case .float(let f):   memoryA[index] = .integer(Int(f))
                }
            }

            // convert all elements in register B to the new operand type
            for (index, value) in memoryB.enumerated()
            {
                switch value 
                {
                case .integer(let i): memoryB[index] = .float(Double(i))
                case .float(let f):   memoryB[index] = .integer(Int(f))
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
    
    func isMemoryAEmpty() -> Bool 
    {
        return memoryA.isEmpty
    }
    
    func isMemoryBEmpty() -> Bool 
    {
        return memoryB.isEmpty
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

    private var memoryADescription: String
    {
        return "| Reg. A [\(memoryA.count)]: " + memoryA.description
    }

    private var memoryBDescription: String
    {
        return "| Reg. B [\(memoryB.count)]: " + memoryB.description
    }
    
    override var description: String
    {
        var str: String = "Engine [\(Unmanaged.passUnretained(self).toOpaque())]\n" 

        str = str + stackDescription + "\n" + memoryADescription + "\n" + memoryBDescription
        
        return str
    }
    
    
    
}
