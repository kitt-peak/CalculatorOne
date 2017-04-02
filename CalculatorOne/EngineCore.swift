//
//  EngineCore.swift
//  CalculatorOne
//
//  Created by Andreas on 02/04/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Foundation

extension Engine
{
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
    @nonobjc class func gcd(of a: Int, _ b: Int) -> Int 
    { 
        if b == 0 { return a } else { return gcd(of: b, a % b)} 
    }  
    
    @nonobjc class func lcm(of a: Int, _ b: Int) -> Int 
    { 
        return abs(abs(a * b) / gcd(of: a, b)) 
    }  
    
    // MARK: - Double class functions
    @nonobjc class func add(_ a: Double, _ b: Double) -> Double
    {
        return a + b
    }
    
    @nonobjc class func multiply(_ a: Double, _ b: Double) -> Double
    {
        return a * b
    }
    
    @nonobjc class func subtract(_ a: Double, _ b: Double) -> Double
    {
        return a - b
    }
    
    @nonobjc class func divide(_ a: Double, _ b: Double) -> Double
    {
        return a / b
    }
    
    @nonobjc class func sinus(_ a: Double) -> Double
    {
        return sin(a)
    }
    
    @nonobjc class func arcSinus(_ a: Double) -> Double
    {
        return asin(a)
    }
    
    @nonobjc class func cosinus(_ a: Double) -> Double
    {
        return cos(a)
    }
    
    @nonobjc class func arcCosine(_ a: Double) -> Double
    {
        return acos(a)
    }

    @nonobjc class func tangens(_ a: Double) -> Double
    {
        return tan(a)
    }
    
    @nonobjc class func arcTangens(_ a: Double) -> Double
    {
        return atan(a)
    }
    
    @nonobjc class func cotangens(_ a: Double) -> Double
    {
        return 1.0 / tan(a)
    }
    
    @nonobjc class func arcCotangens(_ a: Double) -> Double
    {
        if a > 1.0 
        {
            return atan(1.0/a)
        } 
        else if a < -1.0
        {
            return Double.pi + atan(1.0/a)
        } 
        else
        {
            return Double.pi / 2.0 - atan(a)
        }
    }


    
    @nonobjc class func sum(of a: [Double]) -> Double 
    { 
        return a.reduce(0.0) { (x, y) -> Double in return x + y } 
    }
    
    @nonobjc class func avg(of a: [Double]) -> Double 
    { 
        return a.reduce(0.0) { (x, y) -> Double in return x + y } / Double(a.count)
    
    }
    @nonobjc class func product(of a: [Double]) -> Double 
    { 
        return a.reduce(1.0) { (x, y) -> Double in return x * y } 
    }
    
    @nonobjc class func nRoot(of a: Double, _ b: Double) -> Double 
    { 
        return pow(const_e, log(a)/b)
    }
    
    @nonobjc class func geometricalMean(of a: [Double]) -> Double 
    { 
        return Engine.nRoot(of: a.reduce(1.0) { (x, y) -> Double in return x * y },  Double(a.count) ) 
    }
    
    @nonobjc class func thirdRoot(of a: Double) -> Double 
    { 
        return a<0.0 ? -Engine.nRoot(of: abs(a), 3.0) : Engine.nRoot(of: a, 3.0) 
    }
    
    @nonobjc class func variance(of a: [Double]) -> Double 
    { 
        let average: Double = Engine.avg(of: a)
        let squaredDifference = a.reduce(0.0) { (x, y) -> Double in x + ((y - average) * (y - average))}
        return squaredDifference / (Double(a.count) - 1)
    }
    
    @nonobjc class func standardDeviation(of a: [Double]) -> Double 
    { 
        return sqrt(Engine.variance(of: a))
    }

    
    
}
