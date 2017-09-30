//
//  EngineCore.swift
//  CalculatorOne
//
//  Created by Andreas on 02/04/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Foundation

extension Double
{
    // MARK: - Mathematical class variables
    static var c0:   Double { return 299792458.0}      /* speed of light in m/s, exact */
    static var µ0:   Double { return 1.256637061E-6 }  /* magnetic constant */
    static var epsilon0: Double { return 8.854187817E-12 } /* electrical constant */
    static var h:    Double { return 6.62607004081E-34 }    /* Planck's constant in J*s */
    static var k:    Double { return 1.3806485279E-23 }    /* Boltzmann constant */
    static var g:    Double { return 9.80665 }           /* earth acceleration */
    static var G:    Double { return 6.6740831E-11 }     /* gravitational constant */    
    static var e:    Double  { return 2.71828182845904523536028747135266249775724709369995 }
    static var π:    Double { return 3.14159265358979323846264338327950288419716939937510 }

}

extension Engine
{
    //case epsilon0 = "ε₀", µ0 = "μ₀", c0 = "c₀", k0 = "k₀", e0 = "e₀", G = "G", g = "g"

    class var const_7M68:    Double { return const_30M72 / 4.0 }
    class var const_30M72:   Double { return 30.72E6 }
    class var const_122M88:  Double { return const_30M72  * 4.0 }
    class var const_153M6:   Double { return const_30M72  * 5.0 }
    class var const_245M76:  Double { return const_30M72  * 8.0 }
    class var const_368M64:  Double { return const_30M72  * 12.0 }
    class var const_1966M08: Double { return const_122M88 * 16.0 }
    class var const_2457M6:  Double { return const_122M88 * 20.0 }
    class var const_2949M12: Double { return const_122M88 * 24.0 }
    class var const_3072M0:  Double { return const_122M88 * 25.0 }
    class var const_3686M4:  Double { return const_122M88 * 30.0 }
    class var const_3932M16: Double { return const_122M88 * 32.0 }
    class var const_4915M2:  Double { return const_122M88 * 40.0 }
    class var const_5898M24: Double { return const_122M88 * 48.0 }
    
    class var const_25M0: Double { return 25.0E6 }
    class var const_100M0: Double { return const_25M0 * 4.0 }
    class var const_125M0: Double { return const_25M0 * 5.0 }
    class var const_156M25: Double { return const_25M0 * 25.0 / 4.0 }
    
    // MARK: - Integer class functions
    class func sum(of a: [Int]) -> Int 
    { 
        return a.reduce(0) { (x, y) -> Int in return x + y } 
    }
    
    class func factorial(of a: Int) -> Int 
    { 
        if a < 0 { return 0 }
        if a < 1 { return 1 }
        return a * Engine.factorial(of: a-1)
    }
    
    
    /* EUCLID algorithm for GCD */
    class func gcd(of a: Int, _ b: Int) -> Int 
    { 
        if b == 0   { return a } 
        else        { return gcd(of: b, a % b) } 
    }  
    
    class func lcm(of a: Int, _ b: Int) throws -> Int
    { 
        if (abs(a) > Int.max / abs(b))
        {
            throw EngineError.overflowDuringIntegerMultiplication
        }
        else
        {
            return abs(abs(a * b) / gcd(of: a, b)) 
        }
    }  
    
    class func primeFactors(of n: Int) -> [Int]
    {
        guard n>1 else { return [n] }
        
        var factors: [Int] = [Int]()
        var z: Int = n
        var i: Int = 0
        var p: Int = 0
        var foundPrime: Bool = false
        
        while z > 1 
        {
            // bestimme den kleinsten Primfaktor p von z
            i = 2
            foundPrime = false
            while i * i <= z && foundPrime == false 
            {
                if z % i == 0 { foundPrime = true; p = i }
                else
                { i += 1 }
            }
            if foundPrime == false { p = z }
            // füge p in die Liste der Faktoren ein
            factors.append(p)
            z = z / p
        }
        return factors
    }

    // MARK: - Double class functions
    class func add(_ a: Double, _ b: Double) -> Double
    {
        return a + b
    }
    
    class func multiply(_ a: Double, _ b: Double) -> Double
    {
        return a * b
    }
    
    class func subtract(_ a: Double, _ b: Double) -> Double
    {
        return a - b
    }
    
    class func divide(_ a: Double, _ b: Double) -> Double
    {
        return a / b
    }
    
    class func sinus(_ a: Double) -> Double
    {
        return sin(a)
    }
    
    class func arcSinus(_ a: Double) -> Double
    {
        return asin(a)
    }
    
    class func cosinus(_ a: Double) -> Double
    {
        return cos(a)
    }
    
    class func arcCosine(_ a: Double) -> Double
    {
        return acos(a)
    }

    class func tangens(_ a: Double) -> Double
    {
        return tan(a)
    }
    
    class func arcTangens(_ a: Double) -> Double
    {
        return atan(a)
    }
    
    class func cotangens(_ a: Double) -> Double
    {
        return 1.0 / tan(a)
    }
    
    class func arcCotangens(_ a: Double) -> Double
    {
        if a > 1.0 
        {
            return atan(1.0/a)
        } 
        else if a < -1.0
        {
            return Double.pi + atan(1.0/a)
        } 
        
        return Double.pi / 2.0 - atan(a)
    }


    class func absoluteValueOfVector2(x: Double, y: Double) -> Double
    {
        return squareRoot(of: square(of: x) + square(of: y))
    }
    
    class func angleOfVector2(x: Double, y: Double) -> Double
    {
        return atan2(y, x)
    }

    
    class func sum(of a: [Double]) -> Double 
    { 
        return a.reduce(0.0) { (x, y) -> Double in return x + y } 
    }
    
    class func avg(of a: [Double]) -> Double 
    { 
        return a.reduce(0.0) { (x, y) -> Double in return x + y } / Double(a.count)
    
    }
    class func product(of a: [Double]) -> Double 
    { 
        return a.reduce(1.0) { (x, y) -> Double in return x * y } 
    }
    
    class func nRoot(of a: Double, _ b: Double) -> Double 
    { 
        return pow(Double.e, log(a)/b)
    }
    
    class func geometricalMean(of a: [Double]) -> Double 
    { 
        return Engine.nRoot(of: product(of: a),  Double(a.count) ) 
    }
        
    class func variance(of a: [Double]) -> Double 
    { 
        let average: Double = Engine.avg(of: a)
        let squaredDifference = a.reduce(0.0) { (x, y) -> Double in x + ((y - average) * (y - average))}
        return squaredDifference / (Double(a.count) - 1)
    }
    
    class func standardDeviation(of a: [Double]) -> Double 
    { 
        return sqrt(Engine.variance(of: a))
    }
    
    class func xExpY(of x: Double, exp y: Double) -> Double
    {
        return pow(x, y)
    }

    class func logXBaseY(_ x: Double, base: Double) -> Double
    {
        return log(x) / log(base)
    }

    class func eExpX(of x: Double) -> Double
    {
        return pow(Double.e, x)
    }

    class func logBaseE(of x: Double) -> Double
    {
        return log(x)
    }

    class func logBase10(of x: Double) -> Double
    {
        return log10(x)
    }

    class func logBase2(of x: Double) -> Double
    {
        return log2(x)
    }
    
    class func square(of x: Double) -> Double
    {
        return x * x
    }

    class func squareRoot(of x: Double) -> Double
    {
        return sqrt(x)
    }

    class func cubic(of x: Double) -> Double
    {
        return square(of: x) * x
    }
    
    class func cubicRoot(of a: Double) -> Double
    { 
        return a<0.0 ? -Engine.nRoot(of: abs(a), 3.0) : Engine.nRoot(of: a, 3.0) 
    }

    class func reciprocal(of x: Double) -> Double
    {
        return 1.0 / x
    }

    class func reciprocalSquare(of x: Double) -> Double
    {
        return 1.0 / square(of: x)
    }

    class func convertRad2Deg(rad x: Double) -> Double
    {
        return x / Double.pi * 180.0
    }
    
    class func convertDeg2Rad(deg x: Double) -> Double
    {
        return x / 180.0 * Double.pi
    }

    class func invertSign(of x: Double) -> Double
    {
        return -x
    }
    
    class func randomNumber() -> Double
    {
        let n1: UInt64 = UInt64(arc4random())
        let n2: UInt64 = UInt64(arc4random())
        
        var n: UInt64 = n1 << 32
        n = n | n2
        
        let r: Double = Double(n) / Double (UInt64.max)
        
        return r
    }
    
    class func m33d32(of x: Double) -> Double
    {
        return divide(multiply(x, 33.0), 32.0)   
    }
    
    class func m32d33(of x: Double) -> Double
    {
        return divide(multiply(x, 32.0), 33.0)   
    }
    
    class func convertRatioToDB(x: Double, y: Double) -> Double
    {
        return multiply(20.0, logBase10(of : divide(y, x)))
    }
    
    class func integerModulo(x: Int, y: Int) -> Int
    {
        return x % y
    }

    class func integerBinaryAnd(x: Int, y: Int) -> Int
    {
        return x & y
    }

    class func integerBinaryOr(x: Int, y: Int) -> Int
    {
        return x | y
    }
    
    class func integerBinaryXor(x: Int, y: Int) -> Int
    {
        return x ^ y
    }
    
    class func integerBinaryShiftLeft(x: Int, numberOfBits: Int) throws -> Int
    {
        let numberOfAllowedBitsToShift: Int = MemoryLayout<Int>.size * 8 - 1 /* max number of shifts = number of bytes times number of bits minus one (the signature bit) */
           
        guard numberOfBits >= 0 && numberOfBits <= numberOfAllowedBitsToShift else 
        {
            throw EngineError.invalidNumberOfBitsForShitIntegerValueOperation(invalidShiftCount: numberOfBits) 
        }
        
        return x << numberOfBits            

    }

    class func integerBinaryShiftRight(x: Int, numberOfBits: Int) throws -> Int
    {
        let numberOfAllowedBitsToShift: Int = MemoryLayout<Int>.size * 8 - 1 /* max number of shifts = number of bytes times number of bits minus one (the signature bit) */
        
        guard numberOfBits >= 0 && numberOfBits <= numberOfAllowedBitsToShift else 
        {
            throw EngineError.invalidNumberOfBitsForShitIntegerValueOperation(invalidShiftCount: numberOfBits) 
        }
        
        return x >> numberOfBits
    }

    
 }
