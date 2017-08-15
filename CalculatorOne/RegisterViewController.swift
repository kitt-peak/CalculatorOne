
//
//  RegisterViewController.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

extension String 
{
    func trimLeftCharacter(_ character: String) -> String 
    {
        var str = self

        while str.hasPrefix(character) 
        {
            str.remove(at: str.startIndex)
        }
        
        return str
    }
}


protocol RegisterViewControllerDelegate 
{
    func userWillTweakRepresentedValue(_: RegisterViewController.RepresentedValue, inRegister: RegisterViewController) -> Bool
    func userDidTweakRepresentedValue(_ : RegisterViewController.RepresentedValue, inRegister: RegisterViewController)
    func getDocument() -> Document
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
    
    // defines the value that the controller shows thru its multi digit view
    struct RepresentedValue 
    {
        var content: String           // the content, as string
        var radix: Radix              // number radix (bin, dec, oct or hex)
        var alignment: Alignment      // left or right
    }
    
    // one digit view is managed by this class. This class becomes the delegate of the view for reporting changes on the view by the user
    @IBOutlet var digitsView: MultiDigitsView!
    { didSet { digitsView.delegate = self } }
    
    // for reporting digits changes coming from the multi digit view
    var delegate: RegisterViewControllerDelegate!
    
    // blocking digit changes by the UI (user scrolls a digit). This state is passed down to the multi digits view
    var acceptsValueChangesByUI: Bool = false
    { didSet { digitsView.acceptsValueChangesByUI = acceptsValueChangesByUI } }

    // the value that the multi digit view shows. The value is a string, either left or right aligned in its digits view
    // value changes are pushed down to the view 
    var representedValue: RepresentedValue = RepresentedValue(content: "", radix: Radix.decimal, alignment: .right)
    { didSet 
        {   
            digitsView.radix = representedValue.radix.value
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
        // generates right aligned digit arrays. 
        case .right:    
            
            // filter for error values NaN and inf
            if value.content == "inf"
            {
                digits[0] = .inf
                digits[1] = .plus
            }
            else if value.content == "-inf"
            {
                digits[0] = .inf
                digits[1] = .minus                
            }
            // TODO: find better symbols for NAN  
            else if value.content == "nan"
            {
                digits[0] = .dot
                digits[1] = .dot               
                digits[2] = .dot                
            }
            else 
            {
                
                // iterate thru each character of the string from right to left
                // display the string right-aligned
                for (index, character) in value.content.characters.reversed().enumerated()
                {
                    if index < digits.count
                    {
                        digits[index] = digitForCharacter(character, radix: value.radix) ?? Digit.blank
                    }
                    else
                    {
                        // error: the value has too many digits to fit the view controller's number of digits
                        let updateUINote: Notification = Notification(name: GlobalNotification.newError.name, object: delegate.getDocument(), userInfo: 
                            ["errorState"   : true,
                             "errorMessage" : "Result is truncated"
                            ])
                        NotificationCenter.default.post(updateUINote)
                        // error: the value has too many digits to fit the view controller's number of digits
                    }
                }
            }

        case .left:
            // iterate thru each character of the string from left to right
            // display the string left-aligned
            for (index, character) in value.content.characters.enumerated()
            {
                if index < digits.count
                {                
                    digits[digitsView.countViews - index - 1] = digitForCharacter(character, radix: value.radix) ?? Digit.blank
                }
                else
                {
                    // error: the value has too many digits to fit the view controller's number of digits
                    let updateUINote: Notification = Notification(name: GlobalNotification.newError.name, object: delegate.getDocument(), userInfo: 
                        ["errorState"   : true,
                         "errorMessage" : "Result is truncated"
                        ])
                    NotificationCenter.default.post(updateUINote)
                }
            }
        }
        
        return digits
    }
    
    
    
    private func digitForCharacter(_ c: Character, radix: Radix) -> Digit?
    {
        switch c 
        {
        case ".": return .dot
        case "-": return .minus
        case "+": return nil
        case "e", "E": return .dE
        default:
            // convert character to digit
            let v = Int(String(c), radix: radix.value)
        
            if let v = v,
               let d = Digit(rawValue: v)
            {
                return d
            }
            else
            {
                return .blank
            }
        }
    }
    
    
    //MARK: - MultiDigitViewDelegate
    
    /// Asks the delegate if the digit with the specified digit index can be replace by a new digit value
    ///
    /// - Parameters:
    ///   - index: the index of the digit being replaced.
    ///   - byDigitValue: the new digit by value such as 0...16
    /// - Returns: true if the delegate agrees with the replacement, otherwise false
    func userWillReplaceDigitWithIndex(_ index: Int, byDigitValue: Int) -> Bool
    {
        guard acceptsValueChangesByUI == true else { return false }

        // build the new value of the register, starting from a "0000000000" string
        let leadingZeros: String = String(repeating: "0", count: digitsView.countViews - representedValue.content.characters.count)
        
        // the start value has leading zeros and contains the original value, the number of digits equals the max. count of digits in a register
        var buildingNewValue: String = leadingZeros + representedValue.content
        
        // replacing strings in Swift is more complicated than it should be        
        let newDigit = String(byDigitValue, radix: representedValue.radix.value)
                
        let from: String.Index = buildingNewValue.index(buildingNewValue.startIndex, offsetBy: buildingNewValue.characters.count - index - 1)
        let range: ClosedRange<String.Index> = from...from

        buildingNewValue.replaceSubrange(range, with: newDigit)
        
        buildingNewValue = buildingNewValue.trimLeftCharacter("0")

        // overtrimmed? Happens if "000...0" was trimmed to "". For the conversion to a numeric value,
        // the string is set to "0" which will accurately convert to 0
        if buildingNewValue == ""
        {
            buildingNewValue = "0"
            
        // another overtrim? 
        } 
        else if buildingNewValue.hasPrefix(".") == true
        {
            buildingNewValue = "0" + buildingNewValue
        }
        
        
        
        let value: RepresentedValue = RepresentedValue(content: buildingNewValue, radix: representedValue.radix, alignment: .right)
        
        if delegate.userWillTweakRepresentedValue(value, inRegister: self) == true
        {
            delegate.userDidTweakRepresentedValue(value, inRegister: self)
            
            //print(newRegisterContent)
            return true
        }
        
        print("\(self): delegate refused to accept <\(buildingNewValue)>")
        
        return false
    }

}
