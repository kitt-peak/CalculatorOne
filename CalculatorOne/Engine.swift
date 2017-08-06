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



class Engine: NSObject, DependendObjectLifeCycle, KeypadControllerDelegate,  DisplayDataSource, KeypadDataSource
{
    
    struct Operand : CustomStringConvertible
    {
        
        private static func convertToInteger(stringRepresentation: String, radix: Int) -> Int?
        {
            return Int(stringRepresentation, radix: radix)
        }

        private static func convertToFloatingPoint(stringRepresentation: String, radix: Int) -> Double?
        {
            // handle radix of 10 first by trying to directly convert to floating point
            switch radix 
            {
            case 10:  return Double(stringRepresentation)
                
            case 2, 8, 16:    
                 
                // try to convert to an integer first using the specified radix, then convert to floating point
                if let integerValue: Int = convertToInteger(stringRepresentation: stringRepresentation, radix: radix)
                {
                    return Double(exactly: integerValue)
                }
                
            default:
                return nil
            }
            
            return nil
        }
        
        
        // by default, an operand is stored as floating point number and as integer number. Because some numbers
        // do not allow storage as integer and floating point, both variables are optional tpyes
        private var _fValue: Double? = nil
        private var _iValue: Int? = nil
        //private var _isIntegerConvertible:       Bool = false
        //private var _isFloatingPointConvertible: Bool = false
        
        var isIntegerPresentable:       Bool { return _iValue != nil /*&& _isIntegerConvertible == true*/}
        var isFloatingPointPresentable: Bool { return _fValue != nil /*&& _isFloatingPointConvertible == true*/}
        
        var fValue: Double? { return _fValue }
        var iValue: Int?    { return _iValue }
            
        // Initializer from a floating point value
        init(floatingPointValue: Double)
        {
            _fValue = floatingPointValue

            // can the floating point value be trule converted to a integer value? Fractional digits prevent conversion
            _iValue = Int(exactly: floatingPointValue)
        }
        
        // Initializer from an integer value
        init(integerValue: Int)
        {
            _iValue = integerValue
            //_isIntegerConvertible = true
            
            _fValue = Double(exactly: integerValue)
        }
        
        // Initializer from a String representing a number (failable)
        init?(stringRepresentation: String, radix: Int)
        {
            // conversion to integer is first priority
            if let integerValue = Operand.convertToInteger(stringRepresentation: stringRepresentation, radix: radix)
            {
                _iValue = integerValue  
                //_isIntegerConvertible = true
                
                if let convertedToFloatingPoint = Double(exactly: integerValue)
                {
                    _fValue = convertedToFloatingPoint
                    //_isFloatingPointConvertible = true
                }
                else
                {
                    _fValue = nil
                    //_isFloatingPointConvertible = false
                }
            }
            else if let floatingPointValue = Operand.convertToFloatingPoint(stringRepresentation: stringRepresentation, radix: radix)
            {
                // accept as floating point, but not as integer value
                _fValue = floatingPointValue
                _iValue = nil
                
                return
            }
            
            // initializer was not successful in creating the Operand struct: both integer and floating point failed
            return nil
        }        
        

        var stringValue: String 
        {
            // the type Operand can always be converted to a human readable string.
            // either the integer or the floating point representation will work

            if isIntegerPresentable == true
            {
                return String(describing: _iValue!)
            }
            else
            {
                if _fValue == nil { abort() }
                var sValue = String(describing: _fValue!)
                
                // The String(describing: fValue) initializer returns a String ending ".0" for _fValues without fraction
                // trim the trailing ".0" suffix, if it exists
                if sValue.hasSuffix(".0")
                {
                    let c = sValue.characters
                    sValue = String(c.prefix(c.count - 2))
                }
                
                return sValue
                
            }
        }
        
        func stringValueWithRadix(radix: Int) -> String?
        {
            // works only for integer
            return isIntegerPresentable == true ? String(_iValue!, radix: radix, uppercase: true) : nil
        }
        
        var description: String 
        { 
            let iResult: String = isIntegerPresentable       ? "iValue=" + stringValue + " ": ""
            let fResult: String = isFloatingPointPresentable ? "fValue=" + stringValue : ""
            
            return iResult + fResult
        
        }
    }
 
    private func operandArray(fromDoubleArray: [Double]) -> [Operand] 
    {
        return fromDoubleArray.map({ (v: Double) -> Operand in return Operand(floatingPointValue: v) })
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

    enum engineError: Error 
    {
        case popOperandFromEmptyStack
    }

    
    //MARK: - Private properties
    
    private var stack: [Operand]   = [Operand]()
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
                stack.append(Operand(floatingPointValue: value))
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
    
        savedStack.addObjects(from: doubleArray(fromOperandArray: stack)!)
        
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
    
    //MARK: - Stack operations    
    private func pop() throws -> Operand
    {
        if let last: Operand = stack.popLast()
        {
            return last
        }
        else
        {
            throw engineError.popOperandFromEmptyStack
            
        }
    }


    
    private func updateStackAtIndex(_ index: Int, withValue: Operand)
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
    
    // MARK: - Helper functions
    // 23.7.2017: constructing an Operand from a string is now part a dedicated initializer of the Operand struct 
//    private func Operand(fromString: String, radix: Int) -> Operand?
//    {
//        switch operandType 
//        {
//        case .float:
//            // test and convert to operant type .float
//            if let d: Double = Double(fromString)
//            {
//                return Operand.float(d)
//            }
//        case .integer:
//            // test and convert to operant type .integer
//            if let i: Int = Int(fromString, radix: radix)
//            {
//                 return Operand.integer(i)
//            }
//        }
//        
//        return nil
//    }

    
    //MARK: - Core operations
    private typealias OperationsTable = [String : OperationClass]!

    // redefined for a single Operand on 23.7.2017
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
                
//        case integerUnary2array(  (Int)      -> [Operand])
//        case integerBinary2array( (Int, Int) -> [Operand])
//        case integerArray2array(  ([Int])    -> [Operand])
        
//        case floatNone2array(   () -> ([Operand]))
//        case floatUnary2array(  (Double)         ->  [Operand])
//case floatBinary2array( (Double, Double) ->  [Operand])
//case floatArray2array(([Double])          -> [Operand])      
//case floatNArray2array(([Double])         -> [Operand])      

    }
    
//  private var floatOperations: OperationsTable =
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
        Symbols.π.rawValue :        .none2array( { () -> ([Double]) in return [const_π]  }), 
        Symbols.e.rawValue :        .none2array( { () -> ([Double]) in return [const_e]  }),
        Symbols.µ0.rawValue:        .none2array( { () -> ([Double]) in return [const_µ0] }),
        Symbols.epsilon0.rawValue:  .none2array( { () -> ([Double]) in return [const_epsilon0] }),
        Symbols.c0.rawValue:        .none2array( { () -> ([Double]) in return [const_c0]  }),
        Symbols.h.rawValue:         .none2array( { () -> ([Double]) in return [const_h]  }),
        Symbols.k.rawValue:         .none2array( { () -> ([Double]) in return [ const_k]  }),
        Symbols.g.rawValue:         .none2array( { () -> ([Double]) in return [ const_g]  }),
        Symbols.G.rawValue:         .none2array( { () -> ([Double]) in return [ const_G]  }),
        
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
            [Engine.xExpY(of: b, exp: a)] }),
        
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
        
        Symbols.log10.rawValue   : .unary2array( { (a: Double) -> [Double] 
            in return [Engine.logBase10(of: a)] }),
        
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
            [a * 33.0 / 32.0] }),
        
        Symbols.multiply64divide66.rawValue : .unary2array( { (a: Double)         -> [Double] in return  
            [a * 32.0 / 33.0] }),
    
        Symbols.conv22bB.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [20.0 * log10(a / b) ]}),

        Symbols.random.rawValue : .none2array( { () -> ([Double]) in return 
            [Engine.randomNumber()] }),
    
        Symbols.rect2polar.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [Engine.absoluteValueOfVector2(x: a, y: b), Engine.angleOfVector2(x: a, y: b)] }),
        
        Symbols.polar2rect.rawValue : .binary2array({ (a: Double, b: Double) -> [Double] in return 
            [b * Engine.sinus(a), b * Engine.cosinus(a)]  }),
        
    
    // former integer Operations
        
    /*
        Symbols.plus.rawValue     : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b + a)] }),
        Symbols.minus.rawValue    : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b - a)] }),
        Symbols.multiply.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b * a)] }),
        Symbols.divide.rawValue   : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b / a)] }),
        Symbols.moduloN.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b % a)] }),
        
        Symbols.and.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b & a)] }),
        Symbols.or.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b | a)] }),
        Symbols.xor.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b ^ a)] }),
        
        Symbols.nShiftLeft.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b << a)] }),
        Symbols.nShiftRight.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b >> a)] }),
        Symbols.gcd.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(Engine.gcd(of: a, b) )] }),
        Symbols.lcm.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(Engine.lcm(of: a, b) )] }),
        
        Symbols.invertSign.rawValue : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(-a)]  }),
        "~" : .integerUnary2array( { (a: Int)  -> [Operand] in return [.integer(~a)]  }),
        
        Symbols.square.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a*a)]   }),
        "2ˣ" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(Engine.twoExpN(of: a))] }),
        Symbols.shiftLeft.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a << 1)] }),
        Symbols.shiftRight.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a >> 1)] }),
        "1 +" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a + 1)] }),
        "1 -" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a - 1)] }),
        
        Symbols.sum.rawValue  : .integerArray2array( { (s: [Int]) -> [Operand] in return [.integer(Engine.sum(of: s))]}),
        Symbols.nSum.rawValue : .integerNArray2array( { (s: [Int]) -> [Operand] in return [.integer(Engine.sum(of: s))]}),
        
        Symbols.factorial.rawValue : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(Engine.factorial(of: a) )] }),
        
        "PF" : .integerUnary2array( { (a: Int) -> [Operand]  in 
            let r: [Int] = Engine.primeFactors(of: a)  
            return r.map { (x: Int) -> Operand in return .integer(x) }
        })
     */
    ]
    
//    private var integerOperations: OperationsTable =  [
//           
//      Symbols.plus.rawValue     : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b + a)] }),
//      Symbols.minus.rawValue    : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b - a)] }),
//      Symbols.multiply.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b * a)] }),
//      Symbols.divide.rawValue   : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b / a)] }),
//      Symbols.moduloN.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b % a)] }),
//           
//      Symbols.and.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b & a)] }),
//      Symbols.or.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b | a)] }),
//      Symbols.xor.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b ^ a)] }),
//           
//      Symbols.nShiftLeft.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b << a)] }),
//      Symbols.nShiftRight.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(b >> a)] }),
//      Symbols.gcd.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(Engine.gcd(of: a, b) )] }),
//      Symbols.lcm.rawValue : .integerBinary2array({ (a: Int, b: Int) -> [Operand] in return [.integer(Engine.lcm(of: a, b) )] }),
//
//      Symbols.invertSign.rawValue : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(-a)]  }),
//           "~" : .integerUnary2array( { (a: Int)  -> [Operand] in return [.integer(~a)]  }),
//           
//      Symbols.square.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a*a)]   }),
//          "2ˣ" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(Engine.twoExpN(of: a))] }),
//      Symbols.shiftLeft.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a << 1)] }),
//      Symbols.shiftRight.rawValue : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a >> 1)] }),
//         "1 +" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a + 1)] }),
//         "1 -" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a - 1)] }),
//          
//      Symbols.sum.rawValue  : .integerArray2array( { (s: [Int]) -> [Operand] in return [.integer(Engine.sum(of: s))]}),
//      Symbols.nSum.rawValue : .integerNArray2array( { (s: [Int]) -> [Operand] in return [.integer(Engine.sum(of: s))]}),
//      
//      Symbols.factorial.rawValue : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(Engine.factorial(of: a) )] }),
//      
//      "PF" : .integerUnary2array( { (a: Int) -> [Operand]  in 
//            let r: [Int] = Engine.primeFactors(of: a)  
//            return r.map { (x: Int) -> Operand in return .integer(x) }
//      })
//        
//   */ ]
    
    private func processOperation(symbol: String) throws
    {
        // eliminated operation types on 23.7.2017
//        var typelessOperationCompleted: Bool = true
//        var integerOperationCompleted: Bool = true
//        var floatOperationCompleted: Bool = true
        
        // perform typeless operations first. If no typeless information is found,
        // the program continues to look for integer and floating point operations
        if let currentOperation = operations[symbol]
        {
            // store the current stack for potential undo-operation
            addToRedoBuffer(item: .stack(stack))

            switch currentOperation 
            {
                
            case .dropAll:
                stack.removeAll()
                
            case .nDrop:
                
                let n: Operand = try pop()
                
//                switch n 
//                {
//                case .integer(let i):
//                    //                    stack.removeLast(i)
//                    for _ in 0..<i
//                    {
//                        _ = try pop()
//                    }
//                case .float(let f):
//                    
//                    // stack.removeLast(Int(f))
//                    for _ in 0..<Int(f)
//                    {
//                        _ = try pop()
//                    }
//                }

                
            case .depth:
                let a: Int = stack.count 
                
//                switch operandType 
//                {
//                case .integer: stack.append(Operand.integer(a))
//                case .float  : stack.append(Operand.float(Double(a)))
//                }
                
            case .unary2array(let u2aFunction):
                
                // get the argument from the stack, as Double value
                let argument: Double = try pop().fValue!
                
                // apply a function to the argument and get a result back as double array 
                let fResult: [Double] = u2aFunction(argument)
                
                // convert the double array to a Operand array and store on the stack
                stack.append(contentsOf: operandArray(fromDoubleArray: fResult))
                
            case .binary2array(let b2aFunction):
                
                // get both arguments from the stack, as Double values
                let argumentA: Double = try pop().fValue!
                let argumentB: Double = try pop().fValue!
                
                // apply a function to the arguments and get a result back as double array 
                let fResult: [Double] = b2aFunction(argumentA, argumentB)
                
                // convert the double array to a Operand array and store on the stack
                stack.append(contentsOf: operandArray(fromDoubleArray: fResult))
                
            case .ternary2array(let t2aFunction):
                
                // get the three arguments from the stack, as Double values
                let argumentA: Double = try pop().fValue!
                let argumentB: Double = try pop().fValue!
                let argumentC: Double = try pop().fValue!
                
                // apply a function to the arguments and get a result back as double array 
                let fResult: [Double] = t2aFunction(argumentA, argumentB, argumentC)
                
                // convert the double array to a Operand array and store on the stack
                stack.append(contentsOf: operandArray(fromDoubleArray: fResult))
                
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
                
            case .nPick:                            /* copy the n-th element of the stack to the stack */
                                                    /* the 0th element is the top of stack value */
                let n: Double = try pop().fValue!

                let ni: Int = Int(n)
                
                //TODO: Error handling for index not in stack
                /* picking the 0th element? return the top of stack, which is value N itself */
                let result: Operand = ni > 0 
                    ? stack[stack.count - ni] 
                    : Operand(floatingPointValue: n)
                
                stack.append(contentsOf: [result])
                
                //            default:
                //                break
                //                typelessOperationCompleted = false
                //            }
                //        }
//        else
//        {
//            //typelessOperationCompleted = false
//        }
        
        
//        switch operandType
//        {
//        case .integer:
            
        //            floatOperationCompleted = false
            
//            if let currentOperation = /*integerO*/operations[symbol]
//            {
//                // store the current stack for potential undo-operation
//                addToRedoBuffer(item: .stack(stack))
//                
//                switch currentOperation 
//                {
//                case .integerUnary2array(let int2arrayFunction):
//                    let a: Int = try popInteger()
//                    
//                    let r: [Operand] = int2arrayFunction(a)
//                    
//                    stack.append(contentsOf: r)
//                    
//                case .integerBinary2array(let int2arrayFunction):
//                    let a: Int = try popInteger()
//                    let b: Int = try popInteger()
//                    
//                    let r: [Operand] = int2arrayFunction(a, b)
//                    
//                    stack.append(contentsOf: r)
//                    
//                    
//                case .integerArray2array(let arrayFunction):
//                    let s: [Int] = stack.map({ (e: Operand) -> Int in
//                        if case .integer(let i) = e { return i}
//                        return -1
//                    })
//                    
//                    let b = arrayFunction(s)
//                    
//                    stack.removeAll()
//                    stack.append(contentsOf: b)
//                    
//                    /*take N arguments from the stack */
//                case .integerNArray2array(let arrayFunction):
//                    
//                    let n: Int   = try popInteger()    // specifies the number of arguments to pop from the stack
//                    var s: [Int] = [Int]()         // the array of elements popped from the stack
//                    
//                    for _ : Int in 0 ..< n          // pop the specified number of arguments from the stack and put into array
//                    {
//                        s.append(try popInteger())
//                    }
//                    
//                    let r: [Operand] = arrayFunction(s)
//                    stack.append(contentsOf: r)
//                                        
                //                 default:
                //                    break
//                    integerOperationCompleted = false
                //                }
                //            }
//            else
//            {
////                integerOperationCompleted = false
//            }
//            
//        case .float:
            
        //            integerOperationCompleted = false
            
                    //            if let currentOperation = /*floatO*/operations[symbol]
//            {
//                // store the current stack for potential undo-operation
//                addToRedoBuffer(item: .stack(stack))
//                
//                switch currentOperation 
//                {
//                    
                //case .floatNone2array(let n2aFunction):
                case .none2array(let n2aFunction):
                    
                    // apply the function and get a result back as double array 
                    let fResult: [Double] = n2aFunction()
                    
                    // convert the double array to a Operand array and store on the stack
                    stack.append(contentsOf: operandArray(fromDoubleArray: fResult))
                    
                
                
                    

                //case .floatUnary2array(let unaryFunction):
//                case .unary2array(let unaryFunction):
//                    //let a: Double = try popFloat()
//                    let a: Operand = try pop()
//                    
//                    let s: [Operand] = unaryFunction(a)
//                    
//                    stack.append(contentsOf: s)
//                    
//                //case .floatBinary2array(let binaryFunction):
//                case .binary2array(let binaryFunction):
//                    //let a: Double = try popFloat()
//                    let a: Operand = try pop()
//                    //let b: Double = try popFloat()
//                    let b: Operand = try pop()
//                    
//                    let s: [Operand] = binaryFunction(a, b)
//                    
//                    stack.append(contentsOf: s)
                    
                //case .floatArray2array(let arrayFunction):
                case .array2array(let arrayFunction):
                    
                    // copy the entire stack into the array stackCopy
//                    let stackCopy: [Double] = stack.map({ (e: Operand) -> Double in
//                        if case .float(let d) = e { return d }
//                        return -1.0 /*should never be executed*/
//                    })
                    
                    let stackCopy: [Double] = doubleArray(fromOperandArray: stack)! 
                        //                        stack.map({ (e: Operand) -> Double in return e.fValue })

                    stack.removeAll()
                    
                    // TODO: replace if clause by error handling
                    if stackCopy.count > 0
                    {   
                        //let r: [Operand] = arrayFunction(stackCopy)
                        let result: [Double] = arrayFunction(stackCopy)
                        
                        stack.append(contentsOf: operandArray(fromDoubleArray: result)) 
                    }
                    
                    /*take N arguments from the stack */
                //case .floatNArray2array(let arrayFunction):
                case .nArray2array(let arrayFunction):

                    // take the first argument from the stack. This argument specifies the number of further argument to take from the stack
                    let countArguments: Double   = try pop().fValue!    // specifies the number of arguments to pop from the stack
                    var arguments: [Double]      = [Double]()    // the array of elements to pop from the stack
                    
                    // TODO: error handling for non-valid countArgument values
                    for _ : Int in 0 ..< Int(countArguments)          // pop the specified number of arguments from the stack and put into array
                    {
                        arguments.append(try pop().fValue!)
                    }
                    
                    let results: [Double] = arrayFunction(arguments)
                    stack.append(contentsOf: operandArray(fromDoubleArray: results))
                    
//                default: 
//                    break
                    //                    floatOperationCompleted = false
                    
                }
            }
            else
            {
//                //                floatOperationCompleted = false
                print("| engine \(#function): did not recognize operation '\(symbol)', stack not changed")                        
            }
            
//        }
        
//        if typelessOperationCompleted == false && integerOperationCompleted == false && floatOperationCompleted == false
//        {
//            //print("| engine \(#function): did not recognize operation \(operandType) '\(symbol)', stack not changed")                        
//            print("| engine \(#function): did not recognize operation '\(symbol)', stack not changed")                        
//        }
//        else
//        {
//            //print("| engine \(#function): performed operation \(operandType) '\(symbol)'")            
//            //print(description)
//        }
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
                stack = formerStack
                updateUI()
                
            case .radix(_/* let formerRadix*/):
                break

            // operandType eliminated 23.7.2017
//            case .operandType(let formerOperandType):
//                userInputOperandType(formerOperandType.rawValue, storeInUndoBuffer: false)
            }
        }
    }
    
    // MARK: - Output to user
    private func updateUI()
    {
        let updateUINote: Notification = Notification(name: GlobalNotification.newEngineResult.name, object: document, userInfo: ["OperandTypeKey": /*operandType*/ "former OperandTypeKey. TODO: fix since OperandType does not exist" ])
        NotificationCenter.default.post(updateUINote)
        
    }


//    // MARK: - Keypad controller delegate: user input
//    func userUpdatedStackTopValue(_ updatedValue: String, radix: Int)
//    {
//        if let _/*updatedInt*/: Int = Int(updatedValue, radix: radix)
//        {
//            if stack.isEmpty
//            {
//                //stack.append(updatedInt)
//            }
//            else
//            {
//                //stack[stack.count - 1] = updatedInt
//            }
//            
//            updateUI()
//        }
//    }

    /* function eliminated on 23.7.2017
    func userInputOperandType(_ type: Int, storeInUndoBuffer: Bool) 
    {
        if let newOperandType: OperandType = OperandType(rawValue: type)
        {
            // no conversion if the new operand type is equal to the current operand type
            guard newOperandType != operandType else { return }
            
            // store the current operandType for potential undo-operation
            if storeInUndoBuffer == true
            {
                addToRedoBuffer(item: .operandType(operandType))
            }
            
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
    */

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
            //TODO: replace forced unwrap by error handling
            let value: Operand = Operand(stringRepresentation: numericalValue, radix: radix)!
                                    
            // store the current stack for potential undo-operation
            addToRedoBuffer(item: .stack(stack))
            
            //print("\(self)\n| \(#function): adding '\(value)' to top of stack")
            stack.append(value)
            print(stackDescription)
            
            DispatchQueue.main.async
            {
                self.updateUI()
            }
            
        }
        
    }
    
    func userInputOperation(symbol: String)
    {
        engineProcessQueue.sync
        {
            do
            {
                // clear an error indication, if exist
                let clearErrorNote: Notification = Notification(name: GlobalNotification.newError.name, object: document, userInfo: 
                    ["errorState"   : false,
                     "errorMessage" : ""
                    ])
                NotificationCenter.default.post(clearErrorNote)
                
                try processOperation(symbol: symbol)
                                
            }
            catch
            {
                
                let updateUINote: Notification = Notification(name: GlobalNotification.newError.name, object: document, userInfo: 
                    ["errorState"   : true,
                     "errorMessage" : "Stack error"
                    ])
                NotificationCenter.default.post(updateUINote)
                
                undoLastItem()
            }
            
            DispatchQueue.main.async
            {
                    self.updateUI()
            }

            
        }

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
    
    // TODO: Error handling for an empty stack
    
    
    /// Returns the content of the specified register as formatted, human-readable String
    ///
    /// - Parameters:
    ///   - inRegisterNumber: number of the register to return, positive value
    ///   - radix: returns as binary, octal, decimal of hexadecimal number
    /// - Returns: content of the specified register, formatted as human-readable String
    func registerValue(inRegisterNumber: Int, radix: Int) -> String
    {
        var result: String = ""
        
        engineProcessQueue.sync
        {            
            // is registerNumber valid? 
            if hasValueForRegister(registerNumber: inRegisterNumber) == true
            {
                let value: Operand = stack.reversed()[inRegisterNumber]

                if let r = value.stringValueWithRadix(radix: radix)
                {
                    result = r
                }
                else
                {
                    result = value.stringValue
                }
//
//                if value.isIntegerPresentable
//                {
//                    result = value.stringValueWithRadix(radix: radix)!
//                }
//                else
//                {
//                    result = value.stringValue
//                }
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
                    let index = stack.count - forRegisterNumber - 1
                    updateStackAtIndex(index, withValue: v)
                
                    // store the current stack for potential undo-operation
                    addToRedoBuffer(item: .stack(stack))
                    
                    print(stackDescription)
                }
            } 
            
            return
        }
    }

    
//    func registerValueChanged(newValue: Int, forRegisterNumber: Int) 
//    {
//        if stack.isEmpty
//        {
//            //stack.append(newValue)
//        }
//        else
//        {
//            //stack[stack.count - forRegisterNumber - 1] = newValue            
//        }
//    }
    
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
