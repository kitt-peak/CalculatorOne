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
    func userUpdatedStackTopValue(_ updatedValue: String, radix: Int)
    func userInputEnter()
    func userInputOperand(operandSymbol: String)
}

@objc protocol KeypadDataSource
{
    func numberOfRegistersWithContent() -> Int
}


class KeypadController: NSObject, DependendObjectLifeCycle 
{
    
    @IBOutlet weak var document: Document!
    
    @IBOutlet weak var displayController: DisplayController!
    /*From the Xcode release notes:
     
     Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol.
     
     Workaround: Declare the outlet's type as AnyObject or NSObject, connect objects to the outlet using Interface Builder, then change the outlet's type back to the protocol.
     */
    @IBOutlet weak var delegate: KeypadControllerDelegate!/*NSObject!*/
    
    @IBOutlet weak var dataSource: KeypadDataSource!/*AnyObject!*/

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
    
    @IBOutlet weak var operandPlusButton: NSButton!
    @IBOutlet weak var operandMinusButton: NSButton!
    @IBOutlet weak var operandMultiplicationButton: NSButton!
    @IBOutlet weak var operandDivisionButton: NSButton!

    @IBOutlet weak var operandLogicNotButton: NSButton!
    @IBOutlet weak var operandLogicAndButton: NSButton!
    @IBOutlet weak var operandLogicOrButton: NSButton!
    @IBOutlet weak var operandLogicXorButton: NSButton!

    @IBOutlet weak var signChangeButton: NSButton!
    @IBOutlet weak var piButton: NSButton!
    @IBOutlet weak var squareRootButton: NSButton!

    @IBOutlet weak var rotButton: NSButton!
    @IBOutlet weak var dupButton: NSButton!
    @IBOutlet weak var swapButton: NSButton!
    @IBOutlet weak var dropButton: NSButton!

    
    private var digitButtons: [(digit: Int, button: NSButton)]!
    private var unaryOperandButtons: [NSButton]!
    private var binaryOperandButtons: [NSButton]!
    private var ternaryOperandButtons: [NSButton]!

    var digitsComposing: String = ""
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
                
        digitButtons = [( 0, digitButton0), ( 1, digitButton1), ( 2, digitButton2), ( 3, digitButton3), 
                        ( 4, digitButton4), ( 5, digitButton5), ( 6, digitButton6), ( 7, digitButton7), 
                        ( 8, digitButton8), ( 9, digitButton9), (10, digitButtonA), (11, digitButtonB), 
                        (12, digitButtonC), (13, digitButtonD), (14, digitButtonE), (15, digitButtonF)]
        
        unaryOperandButtons  = [signChangeButton, squareRootButton,
                                dupButton, dropButton, operandLogicNotButton]
        
        binaryOperandButtons = [operandPlusButton, operandMinusButton, operandDivisionButton, operandMultiplicationButton,
                                swapButton, operandLogicXorButton, operandLogicOrButton, operandLogicAndButton]
    
        ternaryOperandButtons = [rotButton]
    
    }
    

    
    func documentDidOpen()
    {
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.notificationName, object: nil, queue: nil) 
        { [unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            self.updateOperandKeyStatus()
        }
        
        
        updateOperandKeyStatus()


    }
    
    func documentWillClose() 
    {
        
    }
    
    
    func changeRadix(newRadix: Radix)
    {
        for (representedDigit, button) in digitButtons
        {
            button.isEnabled = (representedDigit < newRadix.value ? true : false)
        }
    
        digitsComposing = ""
    }
    
    func updateOperandKeyStatus()
    {
    
        let availableOperandsCount = dataSource.numberOfRegistersWithContent()
        
        for button in unaryOperandButtons
        {
            button.isEnabled = (availableOperandsCount > 0)
        }

        for button in binaryOperandButtons
        {
            button.isEnabled = (availableOperandsCount > 1)
        }
        
        for button in ternaryOperandButtons
        {
            button.isEnabled = (availableOperandsCount > 2)
        }
        


    
    }
    
    
    @IBAction func userPressedDigitKey(sender: NSButton)
    {
        
        digitsComposing = digitsComposing + sender.title
    
        let radixValue: Int = displayController.radix.value
        
        print("composed digit string = \(digitsComposing)")
        
        delegate.userUpdatedStackTopValue(digitsComposing, radix: radixValue)
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
    
    
        
    
}

