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
        if let savedStack = document.currentSaveDataSet[Document.ConfigurationKey.stackValues] as? NSArray
        {
            // TODO: save and load any values as String to avoid loss of precision.
            for value in savedStack as! [Double]
            {
                stack.push(operand: Operand(floatingPointValue: value))
            }
        }

        if let savedMemoryA = document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues] as? NSArray
        {
            // TODO: save and load any values as String to avoid loss of precision.
            for value in savedMemoryA as! [Double]
            {
                 memoryA.append(Operand(floatingPointValue: value))
            }
        }

        if let savedMemoryB = document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues] as? NSArray
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

        document.currentSaveDataSet[Document.ConfigurationKey.stackValues] = savedStack        
        
        // save memory A and B to the configuration data in the document        
        // TODO: make memory A and B compliant to NSCoding protocol
        // TODO: save and load any values as String to avoid loss of precision.
        let savedMemoryA: NSMutableArray = NSMutableArray()
        
        savedMemoryA.addObjects(from: doubleArray(fromOperandArray: memoryA)!)
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryAValues] = savedMemoryA

        // save memory B to the configuration data in the document        
        let savedMemoryB: NSMutableArray = NSMutableArray()
        
        savedMemoryB.addObjects(from: doubleArray(fromOperandArray: memoryB)!)
        
        document.currentSaveDataSet[Document.ConfigurationKey.memoryBValues] = savedMemoryB

    }
    
    //MARK: - Core operations
    private typealias OperationsTable = [OperationCode : FunctionClass]

    private enum FunctionClass
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
        .dup       : .unary2array( { (a: Double) -> [Double] in return ([a, a]) }),
        .dup2      : .binary2array({ (a: Double, b: Double) -> [Double] in return [b, a, b, a] }),
        
        .drop      : .unary2array(  { (a: Double) -> [Double] in return []}),
        .dropAll   : .dropAll,
        .nDrop     : .nDrop,
        .depth     : .depth,
        .over      : .binary2array({ (a: Double, b: Double) -> [Double] in return [b, a, b] }),
        
        .swap      : .binary2array ({ (a: Double, b: Double) -> ([Double]) in return [a, b] }), /*swap*/
        .nPick     : .nPick,
        
        .rotateDown: .ternary2array ( { (a: Double, b: Double, c: Double) -> ([Double]) in return [a, c, b] }),
        .rotateUp  : .ternary2array ( { (a: Double, b: Double, c: Double) -> ([Double]) in return [b, a, c] }),
        
        .copyAToStack : .copyAToStack,
        .copyBToStack : .copyBToStack,
        .copyStackToA : .copyStackToA,
        .copyStackToB : .copyStackToB,

        
        // former float operations
        .π :        .none2array( { () -> ([Double]) in return [Double.π]  }), 
        .e :        .none2array( { () -> ([Double]) in return [Double.e]  }),
        .µ0:        .none2array( { () -> ([Double]) in return [Double.µ0] }),
        .epsilon0:  .none2array( { () -> ([Double]) in return [Double.epsilon0] }),
        .c0:        .none2array( { () -> ([Double]) in return [Double.c0]  }),
        .h:         .none2array( { () -> ([Double]) in return [Double.h]  }),
        .k:         .none2array( { () -> ([Double]) in return [Double.k]  }),
        .g:         .none2array( { () -> ([Double]) in return [Double.g]  }),
        .G:         .none2array( { () -> ([Double]) in return [Double.G]  }),
        
        .const7M68 :    .none2array( { () -> ([Double]) in return [ const_7M68] }), 
        .const30M72 :   .none2array( { () -> ([Double]) in return [ const_30M72] }), 
        .const122M88 :  .none2array( { () -> ([Double]) in return [ const_122M88] }), 
        .const245M76 :  .none2array( { () -> ([Double]) in return [ const_245M76] }), 
        .const153M6 :   .none2array( { () -> ([Double]) in return [ const_153M6] }), 
        .const368M64 :  .none2array( { () -> ([Double]) in return [ const_368M64] }), 
        .const1966M08 : .none2array( { () -> ([Double]) in return [ const_1966M08] }), 
        .const2457M6 :  .none2array( { () -> ([Double]) in return [ const_2457M6] }), 
        .const2949M12 : .none2array( { () -> ([Double]) in return [ const_2949M12] }), 
        .const3072M0 :  .none2array( { () -> ([Double]) in return [ const_3072M0] }), 
        .const3868M4 :  .none2array( { () -> ([Double]) in return [ const_3686M4] }), 
        .const3932M16 : .none2array( { () -> ([Double]) in return [ const_3932M16] }), 
        .const4915M2 :  .none2array( { () -> ([Double]) in return [ const_4915M2] }), 
        .const5898M24 : .none2array( { () -> ([Double]) in return [ const_5898M24] }),
        .const25M0 :    .none2array( { () -> ([Double]) in return [ const_25M0] }),
        .const100M0 :   .none2array( { () -> ([Double]) in return [ const_100M0] }),
        .const125M0 :   .none2array( { () -> ([Double]) in return [ const_125M0] }),
        .const156M25 :  .none2array( { () -> ([Double]) in return [ const_156M25] }),
        
        .plus     : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.add(b, a) ]  }),
        
        .minus    : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.subtract(b, a)] }),
        
        .multiply : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.multiply(b, a)] }),
        
        .divide   : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.divide(b, a)] }),
        
        .yExpX : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [ Engine.xExpY(of: b, exp: a)] }),
        
        .logYX : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [Engine.logXBaseY(b, base: a)] }),
        
        .nRoot   : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [Engine.nRoot(of: b, a)] }),
        
        .eExpX   : .unary2array(  { (a: Double) -> [Double] in return 
            [Engine.eExpX(of: a)] }),
          
        .tenExpX : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.xExpY(of: 10.0, exp: a)] }),
        
        .twoExpX : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.xExpY(of: 2.0,  exp: a)] }),
        
        .logE    : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBaseE(of: a)] }),
        
        .log10   : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBase10(of: a)] }),
        
        .log2    : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.logBase2(of: a)] }),
        
        .root : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.squareRoot(of: a)] }),
        
        .thridRoot :  .unary2array( { (a: Double)   -> [Double] in return  
            [Engine.cubicRoot(of: a)] }),
        
        .reciprocal: .unary2array( { (a: Double)       -> [Double] in return  
            [Engine.reciprocal(of: a)] }),
        
        .reciprocalSquare: .unary2array( { (a: Double) -> [Double] in return  
            [Engine.reciprocalSquare(of: a)] }), 
        
        .square : .unary2array( { (a: Double)         -> [Double] in return   
            [Engine.square(of: a)] }),
        
        .cubic  : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.cubic(of: a)] }),
        
        .invertSign: .unary2array( { (a: Double) -> [Double] in return 
            [Engine.invertSign(of: a)] }),
        
        .sinus  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.sinus(a)]  }),
        
        .asinus : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcSinus(a)] }),
        
        .cosinus  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.cosinus(a)]  }),
        
        .acosinus : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcCosine(a)] }),
        
        .tangens  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.tangens(a)]  }),
        
        .atangens : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcTangens(a)] }),
        
        .cotangens  : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.cotangens(a)]  }),
        
        .acotangens : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.arcCotangens(a)] }),
        
        .sum  : .array2array({ (s: [Double]) ->      [Double] in return 
            [Engine.sum(of: s) ]}),
        
        .nSum : .nArray2array({(s: [Double]) ->      [Double] in return 
            [Engine.sum(of: s)]}),
        
        .avg  : .array2array({ (s: [Double]) ->      [Double] in return 
            [Engine.avg(of: s)]}),
        
        .nAvg : .nArray2array({ (s: [Double]) ->     [Double] in return 
            [Engine.avg(of: s)]}),
        
        .product  : .array2array({ (s: [Double]) ->  [Double] in return 
            [Engine.product(of: s)]}),
        
        .nProduct : .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.product(of: s)]}),
        
        .geoMean  : .array2array({  (s: [Double]) -> [Double] in return 
            [Engine.geometricalMean(of: s)]}),
        
        .nGeoMean : .nArray2array({ (s: [Double]) -> [Double] in return
            [Engine.geometricalMean(of: s)]}),
        
        .sigma    : .array2array({  (s: [Double]) -> [Double] in return 
            [Engine.standardDeviation(of: s)]}),
        
        .nSigma   : .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.standardDeviation(of: s)]}),
        
        .variance : .array2array( { (s: [Double]) -> [Double] in return 
            [Engine.variance(of: s)]}),
        
        .nVariance: .nArray2array({ (s: [Double]) -> [Double] in return 
            [Engine.variance(of: s)]}),
        
        .multiply66divide64 : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.m33d32(of: a)] }),
        
        .multiply64divide66 : .unary2array( { (a: Double)         -> [Double] in return  
            [Engine.m32d33(of: a)] }),
    
        .conv22dB : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [Engine.convertRatioToDB(x: a, y: b) ]}),

        .random : .none2array( { () -> ([Double]) in return 
            [Engine.randomNumber()] }),
    
        .rect2polar : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [Engine.absoluteValueOfVector2(x: b, y: a), Engine.angleOfVector2(x: b, y: a)] }),
        
        .polar2rect : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [b * Engine.cosinus(a), b * Engine.sinus(a) ] }),
        
        .rad2deg : .unary2array({ (a: Double) -> [Double] in return 
            [Engine.convertRad2Deg(rad: a)] }),
        
        .deg2rad : .unary2array({ (a: Double) -> [Double] in return 
            [Engine.convertDeg2Rad(deg: a)] }),
        
        .hypot : .binary2array( { (a: Double, b: Double) -> [Double] in return 
            [Engine.hypothenusis(x: a, y: b)] }),
        
        .convert2Int : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.roundLowToInteger(x: a)] }),

        .round2Int : .unary2array( { (a: Double) -> [Double] in return 
            [Engine.roundToNearestInteger(x: a)] }),
         
        .convertStack2Int: .array2array( { (s: [Double]) -> [Double] in return 
            Engine.roundLowToInteger(s: s) }),

        .roundStack2Int: .array2array( { (s: [Double]) -> [Double] in return 
            Engine.roundToNearestInteger(s: s) }),

    // former integer Operations
        .moduloN : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerModulo(x: b, y: a)] }),
    
        .and : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerBinaryAnd(x: a, y: b)] }),
        
        .or : .integerBinary2array({ (a: Int, b: Int) ->  [Int]  in return 
            [Engine.integerBinaryOr(x: a, y: b)] }),
        
        .xor : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.integerBinaryXor(x: a, y: b)] }),
       
        .nShiftLeft : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.integerBinaryShiftLeft(x: b, numberOfBits: a)] }),
        
        .nShiftRight : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.integerBinaryShiftRight(x: b, numberOfBits: a)] }),
        
        .gcd : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [Engine.gcd(of: a, b) ] }),
        
        .lcm : .integerBinary2array({ (a: Int, b: Int) -> [Int] in return 
            [try Engine.lcm(of: a, b) ] }),
        
        .invertBits : .integerUnary2array( { (a: Int)  -> [Int] in return 
            [~a]  }),
        
        .factorial : .integerUnary2array( { (a: Int)   -> [Int] in return 
            [Engine.factorial(of: a) ] }),

        .shiftLeft : .integerUnary2array( { (a: Int) -> [Int] in return
            [a << 1] }),
        
        .shiftRight : .integerUnary2array( { (a: Int) -> [Int] in return  
            [a >> 1] }),

        .increment: .integerUnary2array( { (a: Int)  -> [Int] in return  
            [a + 1] }),
        
        .decrement: .integerUnary2array( { (a: Int)  -> [Int] in return  
            [a - 1] }),
                
        .primes : .integerUnary2array( { (a: Int) -> [Int]  in return 
            Engine.primeFactors(of: a) }),
                                                       
        .countOnes : .integerUnary2array( { (a: Int) -> [Int]  in return 
            [Engine.integerCountOneBits(x: a) ] }),
        
        .countZeros : .integerUnary2array( { (a: Int) -> [Int]  in return 
            [Engine.integerCountZeroBits(x: a) ] })
    ]
    
    
    private func processOperation(symbol: String) throws
    {
        // store the current stack for potential undo-operation
        addToRedoBuffer(item: .stack(stack.allOperands()))
        
        let currentOperationCode: OperationCode? = OperationCode(rawValue: symbol)
        
        guard currentOperationCode != nil else 
        {
            throw EngineError.invalidOperation(symbol: symbol)            
        }
            
        let currentOperation: FunctionClass? = operations[currentOperationCode!]
   
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
        let updateUINote: Notification = Notification(name: GlobalConstants.InterObjectNotification.newEngineResult.name, object: document, userInfo: ["OperandTypeKey": /*operandType*/ "former OperandTypeKey. TODO: fix since OperandType does not exist" ])
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
        let clearErrorNote: Notification = Notification(name: GlobalConstants.InterObjectNotification.newError.name, object: document, userInfo: 
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
        
        let updateUINote: Notification = Notification(name: GlobalConstants.InterObjectNotification.newError.name, object: document, userInfo: errorDescriptor)        
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
