//
//  KeypadController.swift
//  CalculatorOne
//
//  Created by Andreas on 30/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

@objc protocol KeypadControllerDelegate 
{
    func userInputNewValue(_ newValue: String, radix: Int)
    func userInputEnter()
    func userInputOperand(operandSymbol: String)
}

class KeypadController: NSObject, DependendObjectLifeCycle 
{
    @IBOutlet weak var radixPop: NSPopUpButton!
    @IBOutlet weak var displayController: DisplayController!
    /*From the Xcode release notes:
     
     Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol.
     
     Workaround: Declare the outlet's type as AnyObject or NSObject, connect objects to the outlet using Interface Builder, then change the outlet's type back to the protocol.
     */
    @IBOutlet weak var delegate: KeypadControllerDelegate!/*NSObject!*/

    @IBOutlet weak var digitButton0: NSButton!
    @IBOutlet weak var digitButton1: NSButton!
    @IBOutlet weak var digitButton2: NSButton!
    @IBOutlet weak var digitButton3: NSButton!
    @IBOutlet weak var digitButton4: NSButton!
    @IBOutlet weak var digitButton5: NSButton!
    @IBOutlet weak var digitButton6: NSButton!
    @IBOutlet weak var digitButton7: NSButton!
    @IBOutlet weak var digitButton8: NSButton!
    @IBOutlet weak var digitButton9: NSButton!
    @IBOutlet weak var digitButtonA: NSButton!
    @IBOutlet weak var digitButtonB: NSButton!
    @IBOutlet weak var digitButtonC: NSButton!
    @IBOutlet weak var digitButtonD: NSButton!
    @IBOutlet weak var digitButtonE: NSButton!
    @IBOutlet weak var digitButtonF: NSButton!
    
    private var digitButtons: [(digit: Int, button: NSButton)]!

    var digitsComposing: String = ""
    
    var radix: Int
    { return Int(radixPop.titleOfSelectedItem!)! }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        radixPop.removeAllItems()
        radixPop.addItems(withTitles: ["2", "4", "8", "10", "16"])

        radixPop.selectItem(withTitle: "10")
        
        digitButtons = [( 0, digitButton0), ( 1, digitButton1), ( 2, digitButton2), ( 3, digitButton3), 
                        ( 4, digitButton4), ( 5, digitButton5), ( 6, digitButton6), ( 7, digitButton7), 
                        ( 8, digitButton8), ( 9, digitButton9), (10, digitButtonA), (11, digitButtonB), 
                        (12, digitButtonC), (13, digitButtonD), (14, digitButtonE), (15, digitButtonF)]
    
    }
    

    
    func documentDidOpen()
    {
        userChangedRadix(sender: radixPop)
    }
    
    func documentWillClose() 
    {
        
    }
    
    
    @IBAction func userPressedDigitKey(sender: NSButton)
    {
        
        digitsComposing = digitsComposing + sender.title
    
        delegate.userInputNewValue(digitsComposing, radix: radix)
    }
    
    @IBAction func userPressedOperandKey(sender: NSButton)
    {
        digitsComposing = ""
        delegate.userInputOperand(operandSymbol: sender.title)
    }
    
    @IBAction func userPressedEnterKey(sender: NSButton)
    {
        digitsComposing = ""
        delegate.userInputEnter()
    }
    
    @IBAction func userChangedRadix(sender: NSPopUpButton)
    {
        displayController.radix = self.radix
        digitsComposing = ""
        
        // disable all button representing digits equal to or larger than the radix
        
        for (representedDigit, button) in digitButtons
        {
            button.isEnabled = (representedDigit < self.radix ? true : false)
        }
            
    }
    
        
    
}

