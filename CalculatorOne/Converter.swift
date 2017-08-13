//
//  Converter.swift
//  CalculatorOne
//
//  Created by Andreas on 12.08.17.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Foundation

extension String
{
    func convertToDouble(radix: Int) -> Double?
    {
        // handle radix of 10 first by trying to directly convert to floating point
        switch radix 
        {
        case 10:  return Double(self)
            
        case 2, 8, 16:    
            
            // try to convert to an integer first using the specified radix, then convert to floating point
            if let integerValue: Int = Int(self, radix: radix)
            {
                return Double(exactly: integerValue)
            }
            
        default:
            return nil
        }
        
        return nil
    }
}
 
extension Int
{
    var exactlyConvertedToDouble: Double?
    {
        var convertedToFloatingPoint: Double? = nil
        var convertedBackToInteger: Int? = nil
        
        do
        {                
            convertedToFloatingPoint = try convertIntegerToFloatingPoint(integer: self)
            
            if let convertedToFloatingPoint = convertedToFloatingPoint
            {
                do 
                {
                    convertedBackToInteger = try convertFloatingPointToInteger(floatingPoint: convertedToFloatingPoint)
                    
                    if let convertedBackToInteger = convertedBackToInteger
                    {
                        // final comparison: if equal, integer can be represented as Floating point
                        return (convertedBackToInteger == self ? convertedToFloatingPoint : nil) 
                    }
                } 
                catch 
                {
                    return nil
                }
            }
        } 
        catch 
        {
            // initializer successful in create the Operand struct with an integer, but no floating point value
            return nil
        }
        
        return nil
    }

}


func convertIntegerToFloatingPoint(integer: Int) throws -> Double?
{
    return Double(exactly: integer)
}

func convertFloatingPointToInteger(floatingPoint: Double) throws -> Int?
{
    return Int(exactly: floatingPoint)
}


