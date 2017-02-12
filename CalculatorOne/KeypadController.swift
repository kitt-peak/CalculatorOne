//
//  KeypadController.swift
//  CalculatorOne
//
//  Created by Andreas on 30/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

// delegate receives user input: composed digits, enter, operations, radix and operand type changes
@objc protocol KeypadControllerDelegate 
{
    func userUpdatedStackTopValue(_ updatedValue: String, radix: Int)
    func userWillInputEnter(numericalValue: String, radix: Int) -> Bool
    func userInputEnter(numericalValue: String, radix: Int)
    func userInputOperation(symbol: String)
    func userInputOperandType(_ type: Int)
}

@objc protocol KeypadDataSource
{
    func numberOfRegistersWithContent() -> Int
}



/// Processes user input: clicks on digits to compose a numerical value, clicks on operation buttons
/// are sent to a delegate (the calculator engine)
/// Uses a datasource (engine) and the radix to decide on enabling/disabling digit and operation buttons
/// Works together with a displayController and a document
class KeypadController: NSObject, DependendObjectLifeCycle 
{
    
    @IBOutlet weak var document: Document!
    
    @IBOutlet weak var displayController: DisplayController!
    /*From the Xcode release notes:
     
     Interface Builder does not support connecting to an outlet in a Swift file when the outlet’s type is a protocol.
     
     Workaround: Declare the outlet's type as AnyObject or NSObject, connect objects to the outlet using Interface Builder, then change the outlet's type back to the protocol.
     */
    // delegate receives user input: composed digits, enter, operations, radix and operand type changes
    @IBOutlet weak var delegate: KeypadControllerDelegate!/*NSObject!*/
    
    // datasource to check status information, such as the number of stack values, for enabling/disabling buttons
    @IBOutlet weak var dataSource: KeypadDataSource!/*AnyObject!*/

    @IBOutlet weak var typeSelector: NSSegmentedControl!
    
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
    @IBOutlet weak var periodButton: NSButton!
    
    @IBOutlet weak var deleteDigitButton: NSButton!
    @IBOutlet weak var deleteAllDigitsButton: NSButton!
    
    @IBOutlet weak var enterButton: NSButton!
    
    @IBOutlet weak var operationPlusButton: NSButton!
    @IBOutlet weak var operationMinusButton: NSButton!
    @IBOutlet weak var operationMultiplicationButton: NSButton!
    @IBOutlet weak var operationDivisionButton: NSButton!
    @IBOutlet weak var operationModuloNButton: NSButton!
    @IBOutlet weak var operationSquareButton: NSButton!
    @IBOutlet weak var operationReciprocalButton: NSButton!

    @IBOutlet weak var operationLogicNotButton: NSButton!
    @IBOutlet weak var operationLogicAndButton: NSButton!
    @IBOutlet weak var operationLogicOrButton: NSButton!
    @IBOutlet weak var operationLogicXorButton: NSButton!

    @IBOutlet weak var operationSignChangeButton: NSButton!
    @IBOutlet weak var operationPiButton: NSButton!
    @IBOutlet weak var operationSquareRootButton: NSButton!

    @IBOutlet weak var rotUpButton: NSButton!
    @IBOutlet weak var rotDownButton: NSButton!
    @IBOutlet weak var dupButton: NSButton!
    @IBOutlet weak var swapButton: NSButton!
    @IBOutlet weak var dropButton: NSButton!
    @IBOutlet weak var dropAllButton: NSButton!

    // array to address all digit buttons at once
    private var digitButtons: [NSButton] = [NSButton]()
    
    // stores the digits pressed by the user to compose a new number, and its current value
    // at each change, composing digits will compute its value and also enable/disable controls
    private var digitsComposing: String = ""
    { didSet 
        { 
            deleteDigitButton.isEnabled     = !digitsComposing.isEmpty
            deleteAllDigitsButton.isEnabled = (!digitsComposing.isEmpty) && digitsComposing.characters.count > 1
            
            updateOperationKeyStatus()
        }
    }
        
    @IBOutlet weak var radixSelector: NSSegmentedControl!
    
    // read the radix directly from the UI control.
    var radix: Radix 
    { return Radix(rawValue: radixSelector.selectedSegment)! } 

    // read the operand type directly from the UI control
    var operandType: OperandType
    { return typeSelector.selectedSegment == 1 ? .float : .integer }
    
    //MARK: - Lifecycle
    override func awakeFromNib()
    {
        super.awakeFromNib()
              
        digitButtons = [ digitButton0, digitButton1, digitButton2, digitButton3, 
                         digitButton4, digitButton5, digitButton6, digitButton7, 
                         digitButton8, digitButton9, digitButtonA, digitButtonB, 
                         digitButtonC, digitButtonD, digitButtonE, digitButtonF]
        
        // forces button enable/disable 
        digitsComposing = ""
        
        typeSelector.setSelected(true, forSegment: 0)
        radixSelector.setSelected(true, forSegment: 2)
    }
    
    func documentDidOpen()
    {
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.notificationName, object: nil, queue: nil) 
        { [unowned self] (notification) in
            guard notification.object as? Document == self.document else { return }
            self.updateOperationKeyStatus()
        }
        
        userChangedRadix(sender: radixSelector)
                
        updateOperationKeyStatus()

    }
    
    func documentWillClose() 
    {
        
    }
    
    // MARK: - Controller logic
    
    /// Inner logic of Changing the radix of the calculator display and keypad. It causes "enter" on any digits beings composed by the user, will enable/disable digit buttons according to the new radix and update the display to show registers in the new radix. Available radix values are: .binary, .octal, .decimal and .hexadecimal
    ///
    /// - Parameter newRadix: the radix can be .binary, .octal, .decimal or .hex
    private func changeRadix(newRadix: Radix)
    {
        // complete any ongoing user input
        self.userPressedEnterKey(sender: enterButton)
        
        for (index, button) in digitButtons.enumerated()
        {
            button.isEnabled = (index < newRadix.value ? true : false)
        }
        
        radixSelector.setSelected(true, forSegment: newRadix.rawValue)
    }
    
    /// Inner logic of changing the calculator's operand type. Available are .integer and .float.
    /// This function will update the engine and the enable/disable status of the keys
    ///
    /// - Parameter newType: the new operand type
    private func changeOperandType(_ newType: OperandType)
    {
        print("\(self) \(#function): sending new operation type'\(newType)' to engine")
        
        updateOperationKeyStatus()        
        
        delegate.userInputOperandType(newType.rawValue)        
    }
    
    var canInputEnter: Bool 
    {
        return digitsComposing.characters.count > 0 && delegate.userWillInputEnter(numericalValue: digitsComposing, radix: radix.value)
    }
    
    var canInputPeriodCharacter: Bool
    {
        return digitsComposing.characters.contains(".") == false && operandType == .float
    }
    
    // MARK: - Action methods
    
    /// Action method from a user to change the calculators operand type
    /// Available operand types are 'Integer' and 'Float'. Causes the "enter" command to finish digit composition and will change the
    /// the operation type of the engine.
    ///
    /// - Parameter sender: NSSegmentedControl with to segments, the first segment is labeled 'INTEGER', the second 'FLOAT'
    @IBAction func userChangedOperandType(sender: NSSegmentedControl)
    {
        guard sender == typeSelector else { return }
        
        // complete any ongoing user input
        self.userPressedEnterKey(sender: enterButton)

        var newOperandType: OperandType = .integer
        
        switch sender.selectedSegment 
        {
        case 0:     newOperandType = .integer
        case 1:     newOperandType = .float
        default:    break
        }
        
        if newOperandType == .float
        {
            changeRadix(newRadix: .decimal)
        }
        
        changeOperandType(newOperandType)
    }
    
    @IBAction func userChangedRadix(sender: NSSegmentedControl)
    {
        guard sender == radixSelector else { return }
        
        if let newRadix = Radix(rawValue: radixSelector.selectedSegment)
        {
            // ask the keypad controller to deal with the new radix: will cause to press "enter(value_in_display)
            changeRadix(newRadix: newRadix)
            
            displayController.changeRadix(newRadix)            
        }
    }

    
    /// Enables or disables the operation buttons such as +, - etc according to
    /// the status of the engine, operand type and the digits being composed
    private func updateOperationKeyStatus()
    {
    
        let availableOperandsCount = dataSource.numberOfRegistersWithContent()

        let enableEnter: Bool = canInputEnter
        
        let enableUnaryTypeLessOperation:   Bool = availableOperandsCount > 0 || enableEnter
        let enableBinaryTypeLessOperation:  Bool = availableOperandsCount > 1 || (enableEnter && availableOperandsCount > 0)
        let enableTernaryTypeLessOperation: Bool = availableOperandsCount > 2 || (enableEnter && availableOperandsCount > 1)

        
        let enableUnaryIntegerOperations:  Bool = operandType == .integer && ((availableOperandsCount > 0) || enableEnter)
        let enableBinaryIntegerOperations: Bool = operandType == .integer && ((availableOperandsCount > 1) || (enableEnter && availableOperandsCount > 0))

        let enableUnaryFloatOperations:    Bool = operandType == .float && ((availableOperandsCount > 0) || enableEnter)
        let enableBinaryFloatOperations:   Bool = operandType == .float && ((availableOperandsCount > 1) || (enableEnter && availableOperandsCount > 0))
        
        enterButton.isEnabled = enableEnter
        periodButton.isEnabled = canInputPeriodCharacter

        typeSelector.isEnabled  = true
        radixSelector.isEnabled = operandType == .integer
        
        operationSignChangeButton.isEnabled = enableUnaryIntegerOperations || enableUnaryFloatOperations
        operationSquareButton.isEnabled     = enableUnaryIntegerOperations || enableUnaryFloatOperations
        operationSquareRootButton.isEnabled = enableUnaryFloatOperations
        dupButton.isEnabled                 = enableUnaryTypeLessOperation
        dropButton.isEnabled                = enableUnaryTypeLessOperation
        dropAllButton.isEnabled             = enableUnaryTypeLessOperation
        swapButton.isEnabled                = enableBinaryTypeLessOperation
        
        operationLogicNotButton.isEnabled   = enableUnaryIntegerOperations
        
        operationPlusButton.isEnabled       = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationMinusButton.isEnabled      = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationDivisionButton.isEnabled   = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationMultiplicationButton.isEnabled = enableBinaryIntegerOperations || enableBinaryFloatOperations
        
        operationReciprocalButton.isEnabled = enableUnaryFloatOperations

        operationModuloNButton.isEnabled    = enableBinaryIntegerOperations
        
        operationLogicXorButton.isEnabled   = enableBinaryIntegerOperations
        operationLogicOrButton.isEnabled    = enableBinaryIntegerOperations
        operationLogicAndButton.isEnabled   = enableBinaryIntegerOperations
        
        rotUpButton.isEnabled               = enableTernaryTypeLessOperation
        rotDownButton.isEnabled             = enableTernaryTypeLessOperation
    }
    
    
    /// Action method sent by digit buttons
    /// Takes the title of the sending button as digits, adds it to previous 
    /// digits to compose a numerical value
    ///
    /// - Parameter sender: a NSButton with a title such as 0, 1, ... , A, F
    @IBAction func userPressedDigitKey(sender: NSButton)
    {
        print("| \(#function): input new digit '\(sender.title)'")
                
        // concatenate the new user input digit
        digitsComposing = digitsComposing + sender.title

        print(self)
                
        // display the composed user input as string
        let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.notificationName, object: document, userInfo: ["StringValue" : digitsComposing])
        NotificationCenter.default.post(updateUINote)
    }
    
    @IBAction func userPressedDeleteDigitKey(sender: NSButton)
    {
        // delete the last character 
        if digitsComposing.isEmpty == false
        {
            digitsComposing.remove(at: digitsComposing.index(before: digitsComposing.endIndex))
            
            print("| \(#function): removed last digit")
            print(self)

            // display the string 
            let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.notificationName, object: document, 
                                                          userInfo: ["StringValue" : digitsComposing])
            NotificationCenter.default.post(updateUINote)
        }
    }
    
    @IBAction func userPressedDeleteAllDigitKey(sender: NSButton)
    {
        // delete all typed characters 
        if digitsComposing.isEmpty == false
        {
            digitsComposing = ""
            
            print("| \(#function): removed all digits")
            print(self)
            
            // display the string 
            let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.notificationName, object: document, 
                                                          userInfo: ["StringValue" : digitsComposing])
            NotificationCenter.default.post(updateUINote)
        }
    }

        
    
    @IBAction func userPressedOperationKey(sender: NSButton)
    {
        // operation key pressed. If digits are being composed, enter these on the stack first
        if digitsComposing.characters.count > 0
        {
            userPressedEnterKey(sender: sender)
        }
        
        // reset user entry after an operand key was pressed
        digitsComposing = ""

        print("| \(#function): sending operation '\(sender.title)' to engine")
        delegate.userInputOperation(symbol: sender.title)
    }
    
    
    @IBAction func userPressedEnterKey(sender: NSButton)
    {
        // try to convert the accumlated user digits to a valid numerical value
        if delegate.userWillInputEnter(numericalValue: digitsComposing, radix: radix.value) == true
        {
            // successful conversion
            print("| \(#function): enter with value <'\(digitsComposing)'> sending to engine")

            delegate.userInputEnter(numericalValue: digitsComposing, radix: radix.value)
            digitsComposing = ""
        }  
        else
        {
            //print("\(self) \(#function): enter failed, composed digits '\(digitsComposing)' could not be converted to a numerical value")            
        }
                
    }
    
    // MARK: - Support
    
    override var description: String
    {
        let addressStr = "KeypadController [\(Unmanaged.passUnretained(self).toOpaque())]"
        let contentStr = "composing: <\(digitsComposing)> [valid number: \(canInputEnter)]"
        return addressStr + " " + contentStr
    }
}

