//
//  Operand.swift
//  CalculatorOne
//
//  Created by Andreas on 12.08.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Foundation



struct Operand : CustomStringConvertible
{
    // by default, an operand is stored as floating point number and as integer number. Because some numbers
    // do not allow storage as integer and floating point, both variables are optional tpyes
    private var _fValue: Double? = nil
    private var _iValue: Int? = nil
    
    var isIntegerPresentable:       Bool { return _iValue != nil }
    var isFloatingPointPresentable: Bool { return _fValue != nil }
    
    var fValue: Double? { return _fValue }
    var iValue: Int?    { return _iValue }
    
    // Initializer from a floating point value
    init(floatingPointValue: Double)
    {
        _fValue = floatingPointValue        
        _iValue = Int(exactly: floatingPointValue)
    }
    
    // Initializer from an integer value
    init(integerValue: Int)
    {
        _iValue = integerValue        
        _fValue = Double(exactly: integerValue)
    }
    
    
    // Initializer from a String representing a number (failable)
    init?(stringRepresentation: String, radix: Int)
    {
        // conversion to integer is first priority
        if let integerValue = Int(stringRepresentation, radix: radix)
        {
            _iValue = integerValue  
            
            // test if the integer value has a floating point representation 
            _fValue = integerValue.exactlyConvertedToDouble
            
            return
        }
        else if let floatingPointValue = stringRepresentation.convertToDouble(radix: radix)
        {
            // accept as floating point, but not as integer value because the integer conversion failed
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
