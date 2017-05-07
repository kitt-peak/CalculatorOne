
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
    func userWillTweakRepresentedValue(_: RegisterViewController.RepresentedValue, inRegister: RegisterViewController) -> Bool
    func userDidTweakRepresentedValue(_ : RegisterViewController.RepresentedValue, inRegister: RegisterViewController)
}


/// Manages one Multidigit view.
///
/// Base class: NSObject for object creation and outlets in Interface builder
/// Conforms to: 
/// - DependendObjectLifeCyle: to get life cycle notifications from Document
/// - MultiDigitViewDelegate: user can change digits by scrolling a digit (UI)
/// 
/// This class wants another object to comply to RegisterViewControllerDelegate for 
/// forwarding user changes of digits by scrolling
/// 
/// This class is the delegate of its multi digit view
class RegisterViewController: NSObject, DependendObjectLifeCycle, MultiDigitViewDelegate
{
    // defines the alignment of a value in a multi digit display
    enum Alignment 
    {
        case left           // first digit at the left hand side, used during value entry by the user
        case right          // last digit at the right hand side. This is the normal alignment of values in a multi digit view
    }
    
    // the value that the controller represents and shows thru its multi digit view
    struct RepresentedValue 
    {
        var content: String           // the content, as string
        var radix: Radix              // number radix (bin, dec, oct or hex)
        var alignment: Alignment      // left or right
    }
    
    // one digit view is managed by this class. For this purpose, this class becomes the delegate if the multi digit view
    @IBOutlet var digitsView: MultiDigitsView!
    { didSet { digitsView.delegate = self } }
    
    // for reporting digits changes coming from the multi digit view
    var delegate: RegisterViewControllerDelegate!
    
    // blocking digit changes in the UI. This state is passed down to the multi digits view
    var acceptsValueChangesByUI: Bool = false
    { didSet { digitsView.acceptsValueChangesByUI = acceptsValueChangesByUI } }

    // the value that the multi digit view shows. The value is a string, either left or right aligned in its digits view
    var representedValue: RepresentedValue = RepresentedValue(content: "", radix: Radix.decimal, alignment: .right)
    { didSet 
        {   digitsView.radix = representedValue.radix.value
            digitsView.value = digitsForRepresentedValue(representedValue) 
        } 
    }
        
    //MARK: - Life cycle
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
    
    // MARK: - Class logic
    /// Generates an array of digits from a RepresentedValue with the digits correctly
    /// set according to radix and alignment
    ///
    /// - Parameter value: the value to convert to digits
    /// - Returns: the array of digits
    private func digitsForRepresentedValue(_ value: RepresentedValue) -> [Digit]
    {
        // convert a the value to an array of digits
        var digits: [Digit] = [Digit](repeating: .blank, count: digitsView.countViews)
        
        switch value.alignment 
        {
        /*case .integer(let value):
            
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
*/
        // generate the digit array right aligned. 
        case .right:    
            
            // filter for error values NaN and inf
            if value.content == "nan" || value.content == "inf" || value.content == "-inf"
            {
                digits[0] = .dE
                digits[1] = .dE
                digits[2] = .dE
            }
            else
            {
                
                // iterate thru each character of the string from right to left
                // display the string right-aligned
                for (index, character) in value.content.characters.reversed().enumerated()
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
                        let v = Int(s, radix: value.radix.value)
                        
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
            
            
            
        //case .stringLeftAligned(let str):
        case .left:
            // iterate thru each character of the string from left to right
            // display the string left-aligned
            for (index, character) in value.content.characters.enumerated()
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
                    let v = Int(s, radix: value.radix.value)
                
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
    
    
    
    //MARK: - MultiDigitViewDelegate
    
    func userWillChangeDigitWithIndex(_ index: Int, toDigitValue: Int) -> Bool
    {
        guard acceptsValueChangesByUI == true else { return false }

        // get the current value of the register as string
        var newValueStr: String = ""

        switch representedValue.alignment
        {
        case .right:
            for i in (0..<digitsView.countViews)
            {
                if i == index
                {
                    let c: String = String(toDigitValue, radix: representedValue.radix.value)
                    newValueStr = c.appending(newValueStr)
                }
                else if i < representedValue.content.characters.count
                {
                    let c: String = String(Array(representedValue.content.characters)[representedValue.content.characters.count - i - 1])
                    newValueStr = c.appending(newValueStr)
                }
                else
                {
                    newValueStr = (" ").appending(newValueStr)
                }
            }
            
        default:
            //TODO: implement changes of left-aligned string values
            break
        }
        
        newValueStr = newValueStr.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let newValue: RepresentedValue = RepresentedValue(content: newValueStr, radix: representedValue.radix, alignment: .right)
        
        if delegate.userWillTweakRepresentedValue(newValue, inRegister: self) == true
        {
            delegate.userDidTweakRepresentedValue(newValue, inRegister: self)
            
            //print(newRegisterContent)
            return true
        }
        
        return false
    }

}
