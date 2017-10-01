//
//  Engine.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Foundation

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

class Engine: NSObject, DependendObjectLifeCycle, KeypadControllerDelegate,  DisplayDataSource, KeypadDataSource
{
     
    private func operandArray(fromDoubleArray: [Double]) -> [Operand] 
    {
        return fromDoubleArray.map({ (v: Double) -> Operand in return Operand(floatingPointValue: v) })
    }
    
    private func operandArray(fromIntegerArray: [Int]) -> [Operand] 
    {
        return fromIntegerArray.map({ (v: Int) -> Operand in return Operand(integerValue: v) })
    }


    private func doubleArray(fromOperandArray: [Operand]) -> [Double]? 
    {
        // are all elements of the 'fromOperandArray' convertable to Double? If not, return nil
        let isConvertible: Bool = fromOperandArray.reduce(true, { (last: Bool, operand: Operand) -> Bool in
            return last && operand.isFloatingPointPresentable
        })
        
        guard isConvertible == true else { return nil }
        
        return fromOperandArray.map({ (operand: Operand) -> Double in
            return operand.fValue!
        })        
    }
    
    
    enum UndoItem 
    {
        case stack([Operand])
        case radix(Radix)
    }

    enum EngineError: Error 
    {
        case invalidOperation(symbol: String)
        case popOperandFromEmptyStack
        case invalidNumberOfBitsForShitIntegerValueOperation(invalidShiftCount: Int)
        case invalidIntegerArgumentExpectedGreaterThanZero
        case overflowDuringIntegerMultiplication
        case invalidStackIndex(index: Int)
    }

    
    //MARK: - Private properties
    
    private var stack: OperandStack = OperandStack()
    private var memoryA: [Operand] = [Operand]() 
    private var memoryB: [Operand] = [Operand]()
    
    private var undoBuffer: [UndoItem] = [UndoItem]()
    
    private let engineProcessQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
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
            // TODO: save and load any values as String to avoid loss of precision.
            for value in savedStack as! [Double]
            {
                stack.push(operand: Operand(floatingPointValue: value))
            }
        }

        if let savedMemoryA = document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue] as? NSArray
        {
            // TODO: save and load any values as String to avoid loss of precision.
            for value in savedMemoryA as! [Double]
            {
                 memoryA.append(Operand(floatingPointValue: value))
            }
        }

        if let savedMemoryB = document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue] as? NSArray
        {
            for value in savedMemoryB as! [Double]
            {
                memoryB.append(Operand(floatingPointValue: value))
            }                    
        }

        undoBuffer.removeAll()
        updateUI()

    }
    
    func documentWillClose()
    {
        // save the stack to the configuration data in the document
        // Convert to double values to enable saving by using the NSCoding protocoll
        // TODO: make stack compliant to NSCoding protocol
        // TODO: save and load any values as String to avoid loss of precision.
        let savedStack: NSMutableArray = NSMutableArray()
    
        savedStack.addObjects(from: doubleArray(fromOperandArray: stack.allOperands())!)

        document.currentSaveDataSet[Document.ConfigurationKey.stackValues.rawValue] = savedStack        
        
        // save memory A and B to the configuration data in the document        
        // TODO: make memory A and B compliant to NSCoding protocol
        // TODO: save and load any values as String to avoid loss of precision.
        let savedMemoryA: NSMutableArray = NSMutableArray()
        
        savedMemoryA.addObjects(from: doubleArray(fromOperandArray: memoryA)!)
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues.rawValue] = savedMemoryA        

        // save memory B to the configuration data in the document        
        let savedMemoryB: NSMutableArray = NSMutableArray()
        
        savedMemoryB.addObjects(from: doubleArray(fromOperandArray: memoryB)!)
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues.rawValue] = savedMemoryB        

    }
    


    
    //MARK: - Core operations
    private typealias OperationsTable = [String : OperationClass]

    private enum OperationClass
    {
        case dropAll, nDrop, depth
        case copyStackToA, copyStackToB, copyAToStack, copyBToStack
        case nPick
        
        case none2array(    ()                          -> ([Double]))
        case unary2array(   (Double)                    -> [(Double)] )
        case binary2array(  (Double, Double)            -> [(Double)] )
        case ternary2array( (Double, Double, Double)    -> [(Double)] )
        case array2array(  ([Double])                   -> [Double])
        case nArray2array( ([Double])                   -> [Double])      

        case integerBinary2array( (Int, Int) throws     -> [Int])
        case integerUnary2array(  (Int)                 -> [Int])
    }
    
    private var operations: OperationsTable =
    [
        // former typless operations
        Symbols.dup.rawValue       : .unary2array( { (a: Double) -> [Double] in return ([a, a]) }),
        Symbols.dup2.rawValue      : .binary2array({ (a: Double, b: Double) -> [Double] in return [b, a, b, a] }),
        
        Symbols.drop.rawValue      : .unary2array(  { (a: Double) -> [Double] in return []}),
        Symbols.dropAll.rawValue   : .dropAll,
        Symbols.nDrop.rawValue     : .nDrop,
        Symbols.depth.rawValue     : .depth,
        Symbols.over.rawValue      : .binary2array({ (a: Double, b: Double) -> [Double] in return [b, a, b] }),
        
        Symbols.swap.rawValue      : .binary2array ({ (a: Double, b: Double) -> ([Double]) in return [a, b] }), /*swap*/
        Symbols.nPick.rawValue     : .nPick,
        
        Symbols.rotateDown.rawValue: .ternary2array ( { (a: Double, b: Double, c: Double) -> ([Double]) in return [a, c, b] }),
        Symbols.rotateUp.rawValue  : .ternary2array ( { (a: Double, b: Double, c: Double) -> ([Double]) in return [b, a, c] }),
        
        Symbols.copyAToStack.rawValue : .copyAToStack,
        Symbols.copyBToStack.rawValue : .copyBToStack,
        Symbols.copyStackToA.rawValue : .copyStackToA,
        Symbols.copyStackToB.rawValue : .copyStackToB,

        
        // former float operations
        Symbols.π.rawValue :        .none2array( { () -> ([Double]) in return [Double.π]  }), 
        Symbols.e.rawValue :        .none2array( { () -> ([Double]) in return [Double.e]  }),
        Symbols.µ0.rawValue:        .none2array( { () -> ([Double]) in return [Double.µ0] }),
        Symbols.epsilon0.rawValue:  .none2array( { () -> ([Double]) in return [Double.epsilon0] }),
        Symbols.c0.rawValue:        .none2array( { () -> ([Double]) in return [Double.c0]  }),
        Symbols.h.rawValue:         .none2array( { () -> ([Double]) in return [Double.h]  }),
        Symbols.k.rawValue:         .none2array( { () -> ([Double]) in return [Double.k]  }),
        Symbols.g.rawValue:         .none2array( { () -> ([Double]) in return [Double.g]  }),
        Symbols.G.rawValue:         .none2array( { () -> ([Double]) in return [Double.G]  }),
        
        Symbols.const7M68.rawValue :    .none2array( { () -> ([Double]) in return [ const_7M68] }), 
        Symbols.const30M72.rawValue :   .none2array( { () -> ([Double]) in return [ const_30M72] }), 
        Symbols.const122M88.rawValue :  .none2array( { () -> ([Double]) in return [ const_122M88] }), 
        Symbols.const245M76.rawValue :  .none2array( { () -> ([Double]) in return [ const_245M76] }), 
        Symbols.const153M6.rawValue :   .none2array( { () -> ([Double]) in return [ const_153M6] }), 
        Symbols.const368M64.rawValue :  .none2array( { () -> ([Double]) in return [ const_368M64] }), 
        Symbols.const1966M08.rawValue : .none2array( { () -> ([Double]) in return [ const_1966M08] }), 
        Symbols.const2457M6.rawValue :  .none2array( { () -> ([Double]) in return [ const_2457M6] }), 
        Symbols.const2949M12.rawValue : .none2array( { () -> ([Double]) in return [ const_2949M12] }), 
        Symbols.const3072M0.rawValue :  .none2array( { () -> ([Double]) in return [ const_3072M0] }), 
        Symbols.const3868M4.rawValue :  .none2array( { () -> ([Double]) in return [ const_3686M4] }), 
        Symbols.const3932M16.rawValue : .none2array( { () -> ([Double]) in return [ const_3932M16] }), 
        Symbols.const4915M2.rawValue :  .none2array( { () -> ([Double]) in return [ const_4915M2] }), 
        Symbols.const5898M24.rawValue : .none2array( { () -> ([Double]) in return [ const_5898M24] }),
        Symbols.const25M0.rawValue :    .none2array( { () -> ([Double]) in return [ const_25M0] }),
        Symbols.const100M0.rawValue :   .none2array( { () -> ([Double]) in return [ const_100M0] }),
        Symbols.const125M0.rawValue :   .none2array( { () -> ([Double]) in return [ const_125M0] }),
        Symbols.const156M25.rawValue :  .none2array( { () -> ([Double]) in return [ const_156M25] }),
        
        Symbols.plus.rawValue     : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.add(b, a) ]  }),
        
        Symbols.minus.rawValue    : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.subtract(b, a)] }),
        
        Symbols.multiply.rawValue : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.multiply(b, a)] }),
        
        Symbols.divide.rawValue   : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.divide(b, a)] }),
        
        Symbols.yExpX.rawValue : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.xExpY(of: b, exp: a)] }),
        
        Symbols.logYX.rawValue : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [Engine.logXBaseY(b, base: a)] }),
        
        Symbols.nRoot.rawValue   : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [Engine.nRoot(of: b, a)] }),
        
        Symbols.eExpX.rawValue   : .unary2array(  { (a: Double) -> [Double] in return 
            [Engine.eExpX(of: a)] }),
          
        Symbols.tenExpX.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.xExpY(of: 10.0, exp: a)] }),
        
        Symbols.twoExpX.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.xExpY(of: 2.0,  exp: a)] }),
        
        Symbols.logE.rawValue    : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBaseE(of: a)] }),
        
        Symbols.log10.rawValue   : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBase10(of: a)] }),
        
        Symbols.log2.rawValue    : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBase2(of: a)] }),
        
        Symbols.root.rawValue : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.squareRoot(of: a)] }),
        
        Symbols.thridRoot.rawValue :  .unary2array( { (a: Double)   -> [Double] in return  
            [Engine.cubicRoot(of: a)] }),
        
        Symbols.reciprocal.rawValue: .unary2array( { (a: Double)       -> [Double] in return  
            [Engine.reciprocal(of: a)] }),
        
        Symbols.reciprocalSquare.rawValue: .unary2array( { (a: Double) -> [Double] in return  
            [Engine.reciprocalSquare(of: a)] }), 
        
        Symbols.square.rawValue : .unary2array( { (a: Double)         -> [Double] in return   
            [Engine.square(of: a)] }),
        
        Symbols.cubic.rawValue  : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.cubic(of: a)] }),
        
        Symbols.invertSign.rawValue: .unary2array( { (a: Double) -> [Double] in return 
            [Engine.invertSign(of: a)] }),
        
        Symbols.sinus.rawValue  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.sinus(a)]  }),
        
        Symbols.asinus.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcSinus(a)] }),
        
        Symbols.cosinus.rawValue  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.cosinus(a)]  }),
        
        Symbols.acosinus.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcCosine(a)] }),
        
        Symbols.tangens.rawValue  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.tangens(a)]  }),
        
        Symbols.atangens.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcTangens(a)] }),
        
        Symbols.cotangens.rawValue  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.cotangens(a)]  }),
        
        Symbols.acotangens.rawValue : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcCotangens(a)] }),
        
        Symbols.sum.rawValue  : .array2array({ (s: [Double]) ->      [Double] in return 
            [Engine.sum(of: s) ]}),
        
        Symbols.nSum.rawValue : .nArray2array({(s: [Double]) ->      [Double] in return 
            [Engine.sum(of: s)]}),
        
        Symbols.avg.rawValue  : .array2array({ (s: [Double]) ->      [Double] in return 
            [Engine.avg(of: s)]}),
        
        Symbols.nAvg.rawValue : .nArray2array({ (s: [Double]) ->     [Double] in return 
            [Engine.avg(of: s)]}),
        
        Symbols.product.rawValue  : .array2array({ (s: [Double]) ->  [Double] in return 
            [Engine.product(of: s)]}),
        
        Symbols.nProduct.rawValue : .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.product(of: s)]}),
        
        Symbols.geoMean.rawValue  : .array2array({  (s: [Double]) -> [Double] in return 
            [Engine.geometricalMean(of: s)]}),
        
        Symbols.nGeoMean.rawValue : .nArray2array({ (s: [Double]) -> [Double] in return
            [Engine.geometricalMean(of: s)]}),
        
        Symbols.sigma.rawValue    : .array2array({  (s: [Double]) -> [Double] in return 
            [Engine.standardDeviation(of: s)]}),
        
        Symbols.nSigma.rawValue   : .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.standardDeviation(of: s)]}),
        
        Symbols.variance.rawValue : .array2array( { (s: [Double]) -> [Double] in return 
            [Engine.variance(of: s)]}),
        
        Symbols.nVariance.rawValue: .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.variance(of: s)]}),
        
        Symbols.multiply66divide64.rawValue : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.m33d32(of: a)] }),
        
        Symbols.multiply64divide66.rawValue : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.m32d33(of: a)] }),
    
        Symbols.conv22dB.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [Engine.convertRatioToDB(x: a, y: b) ]}),

        Symbols.random.rawValue : .none2array( { () -> ([Double]) in return 
            [Engine.randomNumber()] }),
    
        Symbols.rect2polar.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [Engine.absoluteValueOfVector2(x: b, y: a), Engine.angleOfVector2(x: b, y: a)] }),
        
        Symbols.polar2rect.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [b * Engine.cosinus(a), b * Engine.sinus(a) ] }),
        
        Symbols.rad2deg.rawValue : .unary2array({ (a: Double) -> [Double] in return 
            [Engine.convertRad2Deg(rad: a)] }),
        
        Symbols.deg2rad.rawValue : .unary2array({ (a: Double) -> [Double] in return 
            [Engine.convertDeg2Rad(deg: a)] }),

    // former integer Operations
        Symbols.moduloN.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerModulo(x: b, y: a)] }),
    
        Symbols.and.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerBinaryAnd(x: a, y: b)] }),
        
        Symbols.or.rawValue : .integerBinary2array({ (a: Int, b: Int) ->  [Int]  in return 
            [Engine.integerBinaryOr(x: a, y: b)] }),
        
        Symbols.xor.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerBinaryXor(x: a, y: b)] }),
       
        Symbols.nShiftLeft.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.integerBinaryShiftLeft(x: b, numberOfBits: a)] }),
        
        Symbols.nShiftRight.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.integerBinaryShiftRight(x: b, numberOfBits: a)] }),
        
        Symbols.gcd.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.gcd(of: a, b) ] }),
        
        Symbols.lcm.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.lcm(of: a, b) ] }),
        
        Symbols.invertBits.rawValue : .integerUnary2array( { (a: Int)  -> [Int] in return 
            [~a]  }),
        
        Symbols.factorial.rawValue : .integerUnary2array( { (a: Int)   -> [Int] in return 
            [Engine.factorial(of: a) ] }),

        Symbols.shiftLeft.rawValue : .integerUnary2array( { (a: Int) -> [Int] in return
            [a << 1] }),
        
        Symbols.shiftRight.rawValue : .integerUnary2array( { (a: Int) -> [Int] in return  
            [a >> 1] }),

        Symbols.increment.rawValue: .integerUnary2array( { (a: Int)  -> [Int] in return  
            [a + 1] }),
        
        Symbols.decrement.rawValue: .integerUnary2array( { (a: Int)  -> [Int] in return  
            [a - 1] }),
                
        Symbols.primes.rawValue : .integerUnary2array( { (a: Int) -> [Int]  in 
            return Engine.primeFactors(of: a)  
            /* return r.map { (x: Int) -> Int in return x */ }
        )
    ]
    
    
    private func processOperation(symbol: String) throws
    {
        // store the current stack for potential undo-operation
        addToRedoBuffer(item: .stack(stack.allOperands()))
        
        let currentOperation: OperationClass? = operations[symbol]
   
        guard currentOperation != nil else 
        { 
            throw EngineError.invalidOperation(symbol: symbol)
        }

        switch currentOperation!
        {
        case .dropAll:
            stack.removeAll()

        case .nPick:                            
            /* copy the n-th element of the stack to the stack */
            /* the 0th element is the top of stack value */
            if let n: Int = try stack.pop().iValue, n>0
            {
                let result: Operand = try stack.operandAtIndex(stack.count - n)
                stack.push(operands: [result])
            }
            else
            {
                throw EngineError.invalidIntegerArgumentExpectedGreaterThanZero   
            }
            
        case .nDrop:
            /* the 0th element is the top of stack value */
            if let n: Int = try stack.pop().iValue, n>0
            {
                try stack.removeOperandsFromTop(count: n)
            }
            else
            {
                throw EngineError.invalidIntegerArgumentExpectedGreaterThanZero
            }
            
        case .depth:
            let n: Operand = Operand(integerValue: stack.count)
            stack.push(operands: [n])
            
        case .unary2array(let u2aFunction):
            
            // get the argument from the stack, as Double value
            let argument: Double = try stack.pop().fValue!
            
            // apply a function to the argument and get a result back as double array 
            let fResult: [Double] = u2aFunction(argument)
            
            // convert the double array to a Operand array and store on the stack
            stack.push(operands: operandArray(fromDoubleArray: fResult))
            
        case .integerUnary2array(let intUnaryToArryFunction):
            
            // get one integer argument from the stack
            if let intArgument: Int = try stack.pop().iValue
            {
                let intResult: [Int] = intUnaryToArryFunction(intArgument)
                
                // convert the integer array to a Operand array and store on the stack
                stack.push(operands: operandArray(fromIntegerArray: intResult))
            }
            else
            {
                throw EngineError.popOperandFromEmptyStack
            }
            
        case .binary2array(let b2aFunction):
            
            // get both arguments from the stack, as Double values
            let argumentA: Double = try stack.pop().fValue!
            let argumentB: Double = try stack.pop().fValue!
            
            // apply a function to the arguments and get a result back as double array 
            let fResult: [Double] = b2aFunction(argumentA, argumentB)
            
            // convert the double array to a Operand array and store on the stack
            stack.push(operands: operandArray(fromDoubleArray: fResult))
            
            
        case .integerBinary2array(let intBinaryToArrayFunction):
            
            
            // get integer arguments from the stack
            if let intArgumentA: Int = try stack.pop().iValue,
                let intArgumentB: Int = try stack.pop().iValue
            {   
                let intResult: [Int] =  try intBinaryToArrayFunction(intArgumentA, intArgumentB)
                
                // convert the integer array to a Operand array and store on the stack
                stack.push(operands: operandArray(fromIntegerArray: intResult))
            }
            else
            {
                throw EngineError.popOperandFromEmptyStack
            }
            
            
            
        case .ternary2array(let t2aFunction):
            
            // get the three arguments from the stack, as Double values
            if let argumentA: Double = try stack.pop().fValue,
                let argumentB: Double = try stack.pop().fValue,
                let argumentC: Double = try stack.pop().fValue
            {
                
                // apply a function to the arguments and get a result back as double array 
                let fResult: [Double] = t2aFunction(argumentA, argumentB, argumentC)
                
                // convert the double array to a Operand array and store on the stack
                stack.push(operands: operandArray(fromDoubleArray: fResult))
            }
            else
            {
                throw EngineError.popOperandFromEmptyStack
            }
            
        case .copyAToStack:
            stack.removeAll()
            stack.push(operands: memoryA)
            
        case .copyBToStack: 
            stack.removeAll()
            stack.push(operands: memoryB)
            
        case .copyStackToA:
            memoryA.removeAll()                
            memoryA.append(contentsOf: stack.allOperands())
            
        case .copyStackToB:
            memoryB.removeAll()                
            memoryB.append(contentsOf: stack.allOperands())
            
            
        case .none2array(let n2aFunction):
            
            // apply the function and get a result back as double array 
            let fResult: [Double] = n2aFunction()
            
            // convert the double array to a Operand array and store on the stack
            stack.push(operands: operandArray(fromDoubleArray: fResult))
            
            
        case .array2array(let arrayFunction):
            
            // copy the entire stack into the array stackCopy
            
            let stackCopy: [Double] = doubleArray(fromOperandArray: stack.allOperands())! 
            stack.removeAll()
            
            // TODO: replace if clause by error handling
            if stackCopy.count > 0
            {   
                //let r: [Operand] = arrayFunction(stackCopy)
                let result: [Double] = arrayFunction(stackCopy)
                
                stack.push(operands: operandArray(fromDoubleArray: result)) 
            }
            
            /*take N arguments from the stack */
        case .nArray2array(let arrayFunction):
            
            // take the first argument from the stack. This argument specifies the number of further argument to take from the stack
            let countArguments: Int   = try stack.pop().iValue!    // specifies the number of arguments to pop from the stack
            
            // the array of elements to pop from the stack, convert them to an array of double values
            let functionArgumentsAsOperands = try stack.pop(count: countArguments)
            let functionArguments: [Double] = doubleArray(fromOperandArray: functionArgumentsAsOperands)!
            
            let results: [Double] = arrayFunction(functionArguments)
            stack.push(operands: operandArray(fromDoubleArray: results))                    
        }
    }           
    
    // MARK: - Undo/Redo 
    private func addToRedoBuffer(item: UndoItem)
    {
        undoBuffer.append(item)
    }
    
    private func undoLastItem()
    {
        if let item: UndoItem = undoBuffer.popLast()
        {
            switch item
            {
            case .stack(let formerStack):
                stack = OperandStack(operands: formerStack)//formerStack
                updateUI()
                
            case .radix(_/* let formerRadix*/):
                break
            }
        }
    }
    
    // MARK: - Output to user
    private func updateUI()
    {
        let updateUINote: Notification = Notification(name: GlobalNotification.newEngineResult.name, object: document, userInfo: ["OperandTypeKey": /*operandType*/ "former OperandTypeKey. TODO: fix since OperandType does not exist" ])
        NotificationCenter.default.post(updateUINote)
        
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
        return nil != Operand(stringRepresentation: numericalValue, radix: radix)        
    }
    
    
    func userInputEnter(numericalValue: String, radix: Int)
    {   
        guard numericalValue.characters.count > 0 else { return }
        
        engineProcessQueue.sync
        {
            // store the current stack for potential undo-operation
            addToRedoBuffer(item: .stack(stack.allOperands()))

            if let value: Operand = Operand(stringRepresentation: numericalValue, radix: radix)
            {
                stack.push(operand: value)
                
                DispatchQueue.main.async
                {
                    self.updateUI()
                }                
            }
            else
            {
                handleError(message: "illegal input value: \(numericalValue)")
            }
        }
    }
    
    func userInputOperation(symbol: String)
    {
        engineProcessQueue.sync
            {
                do
                {
                    clearErrorIndicator()
                    try processOperation(symbol: symbol)
                }
                catch EngineError.invalidNumberOfBitsForShitIntegerValueOperation(let invalidShiftCount)
                {
                    handleError(message: "\(invalidShiftCount) is an invalid number of bits specified for integer shift operation")                
                }
                catch EngineError.invalidIntegerArgumentExpectedGreaterThanZero
                {
                    handleError(message: "Invalid argument, expected positive integer greater than zero")             
                }
                catch EngineError.overflowDuringIntegerMultiplication
                {
                    handleError(message: "Integer arguments too large, causing overflow")
                }
                catch EngineError.invalidOperation(let invalidSymbol)
                {
                    handleError(message: "Invalid operation \(invalidSymbol). Stack was not changed")
                }
                catch EngineError.popOperandFromEmptyStack
                {
                    handleError(message: "Error attempting to take more argumnets from stack then avaialble during operation \(symbol)")
                }
                catch EngineError.invalidStackIndex(let invalidIndex)
                {
                    handleError(message: "Stack error: element \(stack.count - invalidIndex) from top is not valid for a stack with \(stack.count) elements")
                }
                catch 
                {
                    handleError(message: "Unspecified error occuring during operation \(symbol)")
                }
                
                DispatchQueue.main.async
                {
                    self.updateUI()
                }
        }
        
    }

    
    // MARK: Error handling
    private func clearErrorIndicator() 
    {
        // clear an error indication, if exist
        let clearErrorNote: Notification = Notification(name: GlobalNotification.newError.name, object: document, userInfo: 
            ["errorState"   : false,
             "errorMessage" : ""
            ])
        NotificationCenter.default.post(clearErrorNote)
    }
    
    
    
    private func handleError(message: String) 
    {
        let errorDescriptor: [String : Any] = 
            ["errorState"   : true,
             "errorMessage" : message]
        
        let updateUINote: Notification = Notification(name: GlobalNotification.newError.name, object: document, userInfo: errorDescriptor)        
        NotificationCenter.default.post(updateUINote)
        
        undo()
    }
    
    
    func undo() 
    {
        undoLastItem()
        updateUI()
    }
    
    func redo() 
    {
        
    }
    
    //MARK: - Keypad data source protocoll
    func numberOfRegistersWithContent() -> Int 
    {
        return stack.count
    }
    
    func isMemoryAEmpty() -> Bool { return memoryA.isEmpty }
    func isMemoryBEmpty() -> Bool { return memoryB.isEmpty }
    func canUndo() -> Bool { return undoBuffer.count > 0 }
    func canRedo() -> Bool { return false }
    
    
    
    //MARK: - Display data source protocoll
    func hasValueForRegister(registerNumber: Int) -> Bool 
    {
        var result: Bool = false
        
        engineProcessQueue.sync
        {
            result = stack.count > registerNumber
        }
        
        return result
    }
    
    
    func registerValuesAreIntegerPresentable() -> Bool 
    {
        var result: Bool = true
        
        engineProcessQueue.sync
        {   
            result = stack.isIntegerPresentable     
        }
        
        return result
    }
    
    
    func registerValuesAreFloatingPointPresentable() -> Bool 
    {
        var result: Bool = true
        
        engineProcessQueue.sync
        {   
            result = stack.isFloatingPointPresentable     
        }
        
        return result
    }

    
    
    /// Returns the content of the specified register as formatted, human-readable String
    ///
    /// - Parameters:
    ///   - inRegisterNumber: number of the register to return, positive value
    ///   - radix: returns as binary, octal, decimal of hexadecimal number
    /// - Returns: content of the specified register, formatted as human-readable String
    func registerValue(inRegisterNumber: Int, radix: Int) -> String
    {
        var result: String = ""
        
        // is registerNumber valid? 
        guard hasValueForRegister(registerNumber: inRegisterNumber) == true else { return result }

        engineProcessQueue.sync
        {  
            do
            {
                let value: Operand = try stack.operandAtIndex(stack.count - inRegisterNumber - 1)
                
                if let r = value.stringValueWithRadix(radix: radix)
                {
                    result = r
                }
                else
                {
                    result = value.stringValue
                }                    
            }
            catch
            {
                undo()
            }            
        }
        
        return result
    }    
    
    func registerValueWillChange(newValue: String, radix: Int, forRegisterNumber: Int) -> Bool
    {
        var result: Bool = false
        
        engineProcessQueue.sync
        {
            result = hasValueForRegister(registerNumber: forRegisterNumber)
        }

        // is registerNumber valid (are that many values on the stack)
        if  result == false 
        {
            print("Engine refused to change register \(forRegisterNumber) because the register is empty")
            return false
        }
        
        
        // Can valueStr be represented as a numerical Value? If yes, return true, otherwise, false
        return nil != Operand(stringRepresentation: newValue, radix: radix)
        //return Operand(fromString: newValue, radix: radix) != nil
    }
    
    
    func registerValueDidChange(newValue: String, radix: Int, forRegisterNumber: Int)
    {
        engineProcessQueue.sync
        {
            // is registerNumber valid (are that many values on the stack)
            if hasValueForRegister(registerNumber: forRegisterNumber) == true
            {
                // convert valueStr to a numerical value and enter into the specified register
                if let v: Operand = Operand(stringRepresentation: newValue, radix: radix)
                {
                    do
                    {
                        let index = stack.count - forRegisterNumber - 1
                        try stack.setOperand(v, atIndex: index)                        
                    }
                    catch
                    {
                        // nothing.
                    }
                    
                
                    // store the current stack for potential undo-operation
                    addToRedoBuffer(item: .stack(stack.allOperands()))
                    
                    print(stackDescription)
                }
            } 
            
            return
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
    
    private var undoStackDescription: String
    {
        return "| Undo [\(undoBuffer.count)]" 
    }
    
    override var description: String
    {
        var str: String = "Engine [\(Unmanaged.passUnretained(self).toOpaque())]\n" 

        str = str + stackDescription + "\n" 
                  + memoryADescription + "\n" 
                  + memoryBDescription + "\n"
                  + undoStackDescription
        
        return str
    }
    
    
    
}
