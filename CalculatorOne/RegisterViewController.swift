
//
//  RegisterViewController.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

protocol RegisterViewControllerDelegate 
{
    func userShouldChangeValue(_: Int, inRegister: RegisterViewController) -> Bool
}

enum RegisterValueRepresentation
{
    case integer(Int)
    case stringLeftAligned(String)
    case stringRightAligned(String)
}

class RegisterViewController: NSObject, DependendObjectLifeCycle, MultiDigitViewDelegate
{
    
    @IBOutlet var digitsView: MultiDigitsView!
    { didSet { digitsView.delegate = self } }
    
    var delegate: RegisterViewControllerDelegate!
    
    var acceptsValueChangesByUI: Bool = false
    { didSet { digitsView.allowsValueChangesByUI = acceptsValueChangesByUI } }
    
    var representedValue: RegisterValueRepresentation = .stringRightAligned("")
    { didSet 
        { 
            digitsView.value = digitsForRegisterValue(representedValue)            
        } 
    }
    
    var radix: Int = 10
    { didSet 
        { 
            digitsView.radix = radix 
            //digitsView.value = digitsForRegisterValue(representedValue)            
        }
    }
    
    
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
    
    
    private func digitsForRegisterValue(_ representation: RegisterValueRepresentation) -> [Digit]
    {
        // convert a the register value to an array of digits
        var digits: [Digit] = [Digit](repeating: .blank, count: digitsView.countViews)
        
        switch representation 
        {
        case .integer(let value):
            
            // convert integer to digit array
            var digitValue: Int = abs(value)
            var index: Int = 0
            
            if digitValue == 0
            {
                digits[0] = .d0
                
                index += 1
            }
            
            while digitValue > 0 
            {
                digits[index] = Digit(rawValue: digitValue % radix)!                 
                digitValue = digitValue / radix  
                index += 1
            }
            
            if value < 0
            {
                digits[index] = .minus
                index += 1
            }
            
            for i in index ..< digitsView.countViews
            {
                digits[i] = .blank                    
            }
            
            digitsView.value = [.minus, .d0, .d1, .minus]

        case .stringRightAligned(let str):
            
            // filter for error values NaN and inf
            if str == "nan" || str == "inf" || str == "-inf"
            {
                digits[0] = .dE
                digits[1] = .dE
                digits[2] = .dE
            }
            else
            {
                
                // iterate thru each character of the string from right to left
                // display the string right-aligned
                for (index, character) in str.characters.reversed().enumerated()
                {
                    switch character 
                    {
                    case ".":
                        digits[index] = .dot
                    case "-":
                        digits[index] = .minus
                    case "+": break
                    case "e", "E": 
                        digits[index] = .dE
                    default:
                        // convert character to digit
                        let s = String(character)
                        let v = Int(s, radix: radix)
                        
                        if let d: Digit = Digit(rawValue: v!)
                        {
                            digits[index] = d
                        }
                        else
                        {
                            digits[index] = .blank
                        }
                    }
                }
            }
            
            
            
        case .stringLeftAligned(let str):
            // iterate thru each character of the string from left to right
            // display the string left-aligned
            for (index, character) in str.characters.enumerated()
            {
                switch character 
                {
                case ".":
                    digits[digitsView.countViews - index - 1] = .dot
                case "-":
                    digits[digitsView.countViews - index - 1] = .minus
                case "+": break
                case "e", "E": 
                    digits[digitsView.countViews - index - 1] = .dE

                default:

                    // convert character to digit
                    let s = String(character)
                    let v = Int(s, radix: radix)
                
                    if let d: Digit = Digit(rawValue: v!)
                    {
                        digits[digitsView.countViews - index - 1] = d
                    }
                    else
                    {
                        digits[digitsView.countViews - index - 1] = .blank
                    }
                }
            }
        }
        
        return digits
    }
    
    
    
    func userEventShouldSetValue(_ value: Int) -> Bool 
    {
        guard acceptsValueChangesByUI == true else { return false }
        
        if delegate.userShouldChangeValue(value, inRegister: self) == true
        {
            return true
        }
        
        return false
    }
    
}
