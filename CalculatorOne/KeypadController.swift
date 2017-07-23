//
//  KeypadController.swift
//  CalculatorOne
//
//  Created by Andreas on 30/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa
import Carbon

// delegate receives user input: composed digits, enter, operations, radix and operand type changes
@objc protocol KeypadControllerDelegate 
{
    //func userUpdatedStackTopValue(_ updatedValue: String, radix: Int)
    func userWillInputEnter(numericalValue: String, radix: Int) -> Bool
    func userInputEnter(numericalValue: String, radix: Int)
    func userInputOperation(symbol: String)
    func userInputOperandType(_ type: Int, storeInUndoBuffer: Bool)
    func undo()
    func redo()
}

@objc protocol KeypadDataSource
{
    func numberOfRegistersWithContent() -> Int
    func isMemoryAEmpty() -> Bool
    func isMemoryBEmpty() -> Bool
    func canUndo() -> Bool
    func canRedo() -> Bool
}

enum OperationModifier
{
    case takeStackAsArgument, topOfStackContainsArgumentCount
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
    @IBOutlet weak var stackButton: NSButton!
    
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
    @IBOutlet weak var exponentPlusButton: NSButton!
    @IBOutlet weak var exponentMinusButton: NSButton!
    
    @IBOutlet weak var deleteDigitButton: NSButton!
    @IBOutlet weak var deleteAllDigitsButton: NSButton!
    
    @IBOutlet weak var enterButton: NSButton!
    
    @IBOutlet weak var operationPlusButton: NSButton!
    @IBOutlet weak var operationMinusButton: NSButton!
    @IBOutlet weak var operationMultiplicationButton: NSButton!
    @IBOutlet weak var operationDivisionButton: NSButton!
    
    @IBOutlet weak var operationModuloNButton: NSButton!
    @IBOutlet weak var operationPrimeFactorsButton: NSButton!
    
    @IBOutlet weak var operationSquareButton: NSButton!
    @IBOutlet weak var operationCubicButton: NSButton!
    @IBOutlet weak var operationReciprocalButton: NSButton!
    @IBOutlet weak var operationReciprocalSquareButton: NSButton!
    @IBOutlet weak var operationSineButton: NSButton!
    @IBOutlet weak var operationCosineButton: NSButton!
    @IBOutlet weak var operationTangentButton: NSButton!
    @IBOutlet weak var operationCotangentButton: NSButton!
    @IBOutlet weak var operationASineButton: NSButton!
    @IBOutlet weak var operationACosineButton: NSButton!
    @IBOutlet weak var operationATangentButton: NSButton!
    @IBOutlet weak var operationACotangentButton: NSButton!
    @IBOutlet weak var operationConvert2Value2dBButton: NSButton!

    @IBOutlet weak var operationYPowerXButton: NSButton!
    @IBOutlet weak var operationEPowerXButton: NSButton!
    @IBOutlet weak var operation10PowerXButton: NSButton!
    @IBOutlet weak var operation2PowerXButton: NSButton!
    @IBOutlet weak var operationlog10Button: NSButton!
    @IBOutlet weak var operationlog2Button: NSButton!
    @IBOutlet weak var operationlogButton: NSButton!
    @IBOutlet weak var operationlogXYButton: NSButton!
    @IBOutlet weak var operationSquareRootButton: NSButton!
    @IBOutlet weak var operationThirdRootButton: NSButton!
    @IBOutlet weak var operationNthRootButton: NSButton!
    
    @IBOutlet weak var operationAverageButton: NSButton!
    @IBOutlet weak var operationProductButton: NSButton!
    @IBOutlet weak var operationGeoMeanButton: NSButton!
    @IBOutlet weak var operationSigmaButton: NSButton!
    @IBOutlet weak var operationVarianceButton: NSButton!

    @IBOutlet weak var operationBitwiseLogicNot: NSButton!
    @IBOutlet weak var operationLogicAndButton: NSButton!
    @IBOutlet weak var operationLogicOrButton: NSButton!
    @IBOutlet weak var operationLogicXorButton: NSButton!

    @IBOutlet weak var operationGCDButton: NSButton!
    @IBOutlet weak var operationLCMButton: NSButton!

    @IBOutlet weak var operationShiftLeftButton: NSButton!
    @IBOutlet weak var operationShiftRightButton: NSButton!
    @IBOutlet weak var operationNShiftLeftButton: NSButton!
    @IBOutlet weak var operationNShiftRightButton: NSButton!
    @IBOutlet weak var operationIncrementButton: NSButton!
    @IBOutlet weak var operationDecrementButton: NSButton!
    @IBOutlet weak var operationFactorialButton: NSButton!

    @IBOutlet weak var operationSignChangeButton: NSButton!
    
    @IBOutlet weak var operationπButton: NSButton!
    @IBOutlet weak var operationeButton: NSButton!

    @IBOutlet weak var operationc0Button: NSButton!
    @IBOutlet weak var operatione0Button: NSButton!
    @IBOutlet weak var operationµ0Button: NSButton!
    @IBOutlet weak var operationhButton: NSButton!
    @IBOutlet weak var operationkButton: NSButton!
    @IBOutlet weak var operationGButton: NSButton!
    @IBOutlet weak var operationgButton: NSButton!

    @IBOutlet weak var operation7M68Button: NSButton!
    @IBOutlet weak var operation30M72Button: NSButton!
    @IBOutlet weak var operation122M88Button: NSButton!
    @IBOutlet weak var operation153M6Button: NSButton!
    @IBOutlet weak var operation245M76Button: NSButton!
    //@IBOutlet weak var operation368M64Button: NSButton!
    @IBOutlet weak var operation1966M08Button: NSButton!
    @IBOutlet weak var operation2457M6Button: NSButton!
    @IBOutlet weak var operation2949M12Button: NSButton!
    @IBOutlet weak var operation4915M2Button: NSButton!
    @IBOutlet weak var operation5898M24Button: NSButton!
    //@IBOutlet weak var operation3939M16Button: NSButton!
    @IBOutlet weak var operation25M0Button: NSButton!
    @IBOutlet weak var operation100M0Button: NSButton!
    @IBOutlet weak var operation125M0Button: NSButton!
    @IBOutlet weak var operation156M25Button: NSButton!

    @IBOutlet weak var operationM66D64Button: NSButton!
    @IBOutlet weak var operationM64D66Button: NSButton!

    @IBOutlet weak var operationSumButton: NSButton!

    @IBOutlet weak var operationCopyStackToMemoryA: NSButton!
    @IBOutlet weak var operationCopyMemoryAToStack: NSButton!
    @IBOutlet weak var operationCopyStackToRegisterB: NSButton!
    @IBOutlet weak var operationCopyMemoryBToStack: NSButton!
    
    @IBOutlet weak var operationCardesian2polar: NSButton!
    @IBOutlet weak var operationPolar2cardesian: NSButton!
        
    @IBOutlet weak var rotUpButton: NSButton!
    @IBOutlet weak var rotDownButton: NSButton!
    @IBOutlet weak var dupButton: NSButton!
    @IBOutlet weak var dup2Button: NSButton!
    @IBOutlet weak var swapButton: NSButton!
    @IBOutlet weak var operationDropButton: NSButton!
    @IBOutlet weak var operationDropNButton: NSButton!
    @IBOutlet weak var operationOverButton: NSButton!
    @IBOutlet weak var depthButton: NSButton!
    @IBOutlet weak var operationNPickButton: NSButton!
    
    @IBOutlet weak var undoButton: NSButton!
    @IBOutlet weak var redoButton: NSButton!
        
    @IBOutlet weak var extraOperationsView: NSScrollView!
    @IBOutlet weak var extraOperationsInnerView: NSView!

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
            
            // set a flag is digits are being composed. This flag will supress is sent to other controllers in order to
            // to supress that the UI does changes to the digits, e.g. by scrolling
            // the flag is reset when the user pressed enter (this will set digitsComposing to ""
            userIsBusyComposingANewValue = !(digitsComposing.characters.count == 0)
        }
    }
    
    private var userIsBusyComposingANewValue : Bool = false
    { didSet 
        {
            // propagate down the info that the user composes a new value or finished composing it
            // if the composing a value is finished, delay that info to allow the rotating digits to settle its animation first
            if userIsBusyComposingANewValue == false
            {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) 
                { 
                    self.displayController.acceptValueChangesByUI = !self.userIsBusyComposingANewValue
                }                
            }
            else
            {
                displayController.acceptValueChangesByUI = !userIsBusyComposingANewValue                
            }
            
        }
    }
    
    // a monitor routine to detect pressing and releasing ALT key events
    private var altkeyEventMonitor: Any?
        
    @IBOutlet weak var radixSelector: NSSegmentedControl!
    
    // read the radix directly from the UI control.
    var radix: Radix 
    { return Radix(rawValue: radixSelector.selectedSegment)! } 

    // read the operand type directly from the UI control
    var operandType: Engine.OperandType
    { return typeSelector.selectedSegment == 1 ? .float : .integer }
    
    var operationModifier: OperationModifier = .takeStackAsArgument
        { didSet { stackButton.state = (operationModifier == .topOfStackContainsArgumentCount ? NSOnState : NSOffState)
                   assignButtonTitlesForOperationModifier(operationModifier) } }
    
    // an label to indicate an error condition. It is initially not visible
    @IBOutlet weak var errorIndicator: NSTextField!
        { didSet { errorIndicator.textColor = NSColor.clear }}
    
    //MARK: - Lifecycle
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        assignButtonTitlesForOperationModifier(.takeStackAsArgument)
              
        digitButtons = [ digitButton0, digitButton1, digitButton2, digitButton3, 
                         digitButton4, digitButton5, digitButton6, digitButton7, 
                         digitButton8, digitButton9, digitButtonA, digitButtonB, 
                         digitButtonC, digitButtonD, digitButtonE, digitButtonF]
        
        // forces button enable/disable 
        digitsComposing = ""
        
        typeSelector.setSelected(true, forSegment: Engine.OperandType.float.rawValue)
        radixSelector.setSelected(true, forSegment: Radix.decimal.rawValue)
        
        extraOperationsView.documentView = extraOperationsInnerView
        extraOperationsView.contentView.postsFrameChangedNotifications = true
        extraOperationsView.contentView.scroll(to: NSPoint(x: 0.0, y: extraOperationsInnerView.frame.size.height - extraOperationsView.frame.size.height))
        
        
    }
    
    
    func documentDidOpen()
    {
        /// Receive a notification from the engine posting new results
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.name, object: nil, queue: nil) 
        { /*[unowned self]*/ (note) in
            guard self.document != nil else { return }
            
            guard note.object as? Document == self.document else { return }
            
            if let userInfo = note.userInfo
            {
                if let opType = userInfo["OperandTypeKey"] as? Engine.OperandType
                {
                    self.typeSelector.setSelected(true, forSegment: opType.rawValue)
                }
            }
            
            self.updateOperationKeyStatus()
        }
        

        /// Receive error notifications
        NotificationCenter.default.addObserver(forName: GlobalNotification.newError.name, object: nil, queue: nil) 
        { (note) in
            guard self.document != nil else { return }
            guard note.object as? Document == self.document else { return }
            
            if let userInfo = note.userInfo
            {
                if let errorState: Bool =       userInfo["errorState"] as? Bool,
                   let errorMessage: String =  userInfo["errorMessage"] as? String
                {
                    if errorState == true
                    {
                        self.errorIndicator.toolTip = errorMessage
                        self.errorIndicator.textColor = NSColor.white
                    }
                    else
                    {
                        self.errorIndicator.toolTip = ""
                        self.errorIndicator.textColor = NSColor.clear                        
                    }
                }
            }
            
            
        }
        
        
        // Make sure the watched view is sending bounds changed
        // notifications (which is probably does anyway, but calling this again won't hurt).                
        // register for those notifications on the synchronized content view        
        NotificationCenter.default.addObserver(forName: Notification.Name.NSViewBoundsDidChange, object: extraOperationsView.contentView, queue: nil) 
        { (notification) in
            
            // supress new digit setting. This flag is set true if digits are set programmatically
            guard self.document != nil else { return }            
            
            self.document.currentSaveDataSet[Document.ConfigurationKey.extraOperationsViewYPosition.rawValue] = self.extraOperationsView.contentView.bounds.origin.y
            
        }


        if let selectedOperandTypeSegment: Int = document.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue] as? Int
        {
            typeSelector.setSelected(true, forSegment: selectedOperandTypeSegment)            
        }
        
        userChangedOperandType(sender: typeSelector)        
        
        if let selectedRadixSegment: Int = document.currentSaveDataSet[Document.ConfigurationKey.radix.rawValue] as? Int
        {   
            radixSelector.setSelected(true, forSegment: selectedRadixSegment)
        }

        userChangedRadix(sender: radixSelector)

        if let yPos = document.currentSaveDataSet[Document.ConfigurationKey.extraOperationsViewYPosition.rawValue] as? CGFloat
        {
            extraOperationsView.contentView.bounds.origin.y = yPos
            
        }
        
        /// add a event monitor. Gives a notification if the ALT key was pressed and released
        /// the filter does not remove any events, it does not work as filter 
        altkeyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.flagsChanged) 
        { (changedFlagsEvent) -> NSEvent? in
           
            if changedFlagsEvent.keyCode == UInt16(kVK_Option) || changedFlagsEvent.keyCode == UInt16(kVK_RightOption)
            {
                if changedFlagsEvent.modifierFlags.contains(.option)
                {
                    //print("pressed ALT")
                    self.operationModifier = .topOfStackContainsArgumentCount
                }
                else
                {
                    // print("released ALT")
                    self.operationModifier = .takeStackAsArgument
                }
            }
            
            return changedFlagsEvent
        }
        
//        if let selectedExtraOperationsTabIndex: Int = document.currentSaveDataSet[Document.ConfigurationKey.extraOperationsTabIndex.rawValue] as? Int
//        {
//            extraOperationsSelector.setSelected(true, forSegment: selectedExtraOperationsTabIndex)
//            ///extraOperationsTabView.selectTabViewItem(at: selectedExtraOperationsTabIndex)
//        }

        //userSelectedExtraOperations(sender: extraOperationsSelector)
        
        updateOperationKeyStatus()
    }
    
    func documentWillClose() 
    {
        NotificationCenter.default.removeObserver(self)
        
        if let monitor = altkeyEventMonitor { NSEvent.removeMonitor(monitor) }
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Controller logic
    
    /// Inner logic of Changing the radix of the calculator display and keypad. It causes "enter" on any digits beings composed by the user, will enable/disable digit buttons according to the new radix and update the display to show registers in the new radix. Available radix values are: .binary, .octal, .decimal and .hexadecimal
    ///
    /// - Parameter newRadix: the radix can be .binary, .octal, .decimal or .hex
    private func changeRadix(newRadix: Radix)
    {

        displayController.acceptValueChangesByUI = false
        
        radixSelector.isEnabled = false
        typeSelector.isEnabled  = false

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) 
        { 
            self.displayController.acceptValueChangesByUI = true
            self.updateOperationKeyStatus()
        }                        
        
        // complete any ongoing user input
        self.userPressedEnterKey(sender: enterButton)
        
        for (index, button) in digitButtons.enumerated()
        {
            button.isEnabled = (index < newRadix.value ? true : false)
        }
        
        radixSelector.setSelected(true, forSegment: newRadix.rawValue)
        
        
        displayController.changeRadix(newRadix)            
        
        document.currentSaveDataSet[Document.ConfigurationKey.radix.rawValue] = newRadix.rawValue
    }
    
    /// Inner logic of changing the calculator's operand type. Available are .integer and .float.
    /// This function will update the engine and the enable/disable status of the keys
    ///
    /// - Parameter newType: the new operand type
    private func changeOperandType(_ newType: Engine.OperandType)
    {
        print("\(self) \(#function): sending new operation type'\(newType)' to engine")
        
        displayController.acceptValueChangesByUI = false
                
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) 
        { 
            self.displayController.acceptValueChangesByUI = true
        }                        

        
        if newType == .float
        {
            changeRadix(newRadix: .decimal)
        }
        
        delegate.userInputOperandType(newType.rawValue, storeInUndoBuffer: true)  
        document.currentSaveDataSet[Document.ConfigurationKey.operandType.rawValue] = newType.rawValue
        
        updateOperationKeyStatus()        
    }
    
    var canInputEnter: Bool 
    {
        return digitsComposing.characters.count > 0 && delegate.userWillInputEnter(numericalValue: digitsComposing, radix: radix.value)
    }
    
    var canInputPeriodCharacter: Bool
    {
        return digitsComposing.characters.contains(".") == false && operandType == .float
    }
    
    var canInputExponent: Bool
    {
        return digitsComposing.characters.contains("e") == false && operandType == .float && digitsComposing.characters.count > 0
    }
    
    private func assignButtonTitlesForOperationModifier(_ modifier: OperationModifier)
    {
        if modifier == .takeStackAsArgument
        {
            operationSumButton.title        = Symbols.sum.rawValue
            operationAverageButton.title    = Symbols.avg.rawValue
            operationProductButton.title    = Symbols.product.rawValue
            operationGeoMeanButton.title    = Symbols.geoMean.rawValue
            operationSigmaButton.title      = Symbols.sigma.rawValue
            operationVarianceButton.title   = Symbols.variance.rawValue
            operationDropNButton.title      = Symbols.dropAll.rawValue
                        
        }
        else if modifier == .topOfStackContainsArgumentCount
        {
            operationSumButton.title        = "n " + Symbols.sum.rawValue
            operationAverageButton.title    = "n " + Symbols.avg.rawValue
            operationProductButton.title    = "n " + Symbols.product.rawValue
            operationGeoMeanButton.title    = "n " + Symbols.geoMean.rawValue
            operationSigmaButton.title      = "n " + Symbols.sigma.rawValue
            operationVarianceButton.title   = "n " + Symbols.variance.rawValue
            operationDropNButton.title      = "n " + Symbols.drop.rawValue
        }

        operationPlusButton.title           = Symbols.plus.rawValue
        operationMinusButton.title          = Symbols.minus.rawValue
        operationMultiplicationButton.title = Symbols.multiply.rawValue
        operationDivisionButton.title       = Symbols.divide.rawValue
        
        operationModuloNButton.title        = Symbols.moduloN.rawValue
        operationLogicOrButton.title        = Symbols.and.rawValue
        operationLogicOrButton.title        = Symbols.or.rawValue
        operationLogicXorButton.title       = Symbols.xor.rawValue
        
        operationShiftLeftButton.title      = Symbols.shiftLeft.rawValue
        operationShiftRightButton.title     = Symbols.shiftRight.rawValue
        operationNShiftLeftButton.title     = Symbols.nShiftLeft.rawValue
        operationNShiftRightButton.title    = Symbols.nShiftRight.rawValue
        
        operationGCDButton.title            = Symbols.gcd.rawValue
        operationLCMButton.title            = Symbols.lcm.rawValue
        
        swapButton.title                    = Symbols.swap.rawValue
        rotUpButton.title                   = Symbols.rotateUp.rawValue
        rotDownButton.title                 = Symbols.rotateDown.rawValue
        operationNPickButton.title          = Symbols.nPick.rawValue
        
        dupButton.title                     = Symbols.dup.rawValue
        dup2Button.title                    = Symbols.dup2.rawValue
        depthButton.title                   = Symbols.depth.rawValue
        
        operationFactorialButton.title      = Symbols.factorial.rawValue
        operationPrimeFactorsButton.title   = Symbols.primes.rawValue
        
        operationπButton.title              = Symbols.π.rawValue
        operationeButton.title              = Symbols.e.rawValue
        operationc0Button.title             = Symbols.c0.rawValue
        operationhButton.title              = Symbols.h.rawValue
        operationkButton.title              = Symbols.k.rawValue
        operationgButton.title              = Symbols.g.rawValue
        operationGButton.title              = Symbols.G.rawValue
        
        operationYPowerXButton.title        = Symbols.yExpX.rawValue
        operationlogXYButton.title          = Symbols.logYX.rawValue
        operation10PowerXButton.title       = Symbols.tenExpX.rawValue
        operation2PowerXButton.title        = Symbols.twoExpX.rawValue
        operationlog2Button.title           = Symbols.log2.rawValue
        operationlogButton.title            = Symbols.logE.rawValue
        operationlog10Button.title          = Symbols.log10.rawValue
        
        operationNthRootButton.title        = Symbols.nRoot.rawValue
        operationSquareRootButton.title     = Symbols.root.rawValue
        operationThirdRootButton.title      = Symbols.thridRoot.rawValue
        
        operationReciprocalButton.title     = Symbols.reciprocal.rawValue
        operationReciprocalSquareButton.title = Symbols.reciprocalSquare.rawValue
        operationSquareButton.title         = Symbols.square.rawValue
        operationCubicButton.title          = Symbols.cubic.rawValue
        
        operationSineButton.title            = Symbols.sinus.rawValue
        operationASineButton.title           = Symbols.asinus.rawValue
        operationCosineButton.title          = Symbols.cosinus.rawValue
        operationACosineButton.title         = Symbols.acosinus.rawValue
        operationTangentButton.title         = Symbols.tangens.rawValue
        operationATangentButton.title        = Symbols.atangens.rawValue
        operationCotangentButton.title       = Symbols.cotangens.rawValue
        operationACotangentButton.title      = Symbols.acotangens.rawValue
        operationConvert2Value2dBButton.title = Symbols.conv22bB.rawValue
        
        
        operation7M68Button.title           = Symbols.const7M68.rawValue
        operation30M72Button.title          = Symbols.const30M72.rawValue
        operation122M88Button.title         = Symbols.const122M88.rawValue
        operation153M6Button.title          = Symbols.const153M6.rawValue
        operation245M76Button.title         = Symbols.const245M76.rawValue
        //operation368M64Button.title       
        operation1966M08Button.title        = Symbols.const1966M08.rawValue
        operation2457M6Button.title         = Symbols.const2457M6.rawValue
        operation2949M12Button.title        = Symbols.const2949M12.rawValue
        //operation3939M16Button.title    
        operation4915M2Button.title         = Symbols.const4915M2.rawValue
        operation5898M24Button.title        = Symbols.const5898M24.rawValue
        operation25M0Button.title           = Symbols.const25M0.rawValue
        operation100M0Button.title          = Symbols.const100M0.rawValue
        operation125M0Button.title          = Symbols.const125M0.rawValue
        operation156M25Button.title         = Symbols.const156M25.rawValue

        operationSignChangeButton.title     = Symbols.invertSign.rawValue
        operationDropButton.title           = Symbols.drop.rawValue
        operationOverButton.title           = Symbols.over.rawValue
        
        operationCardesian2polar.title      = Symbols.rect2polar.rawValue
        operationPolar2cardesian.title      = Symbols.polar2rect.rawValue
        
        undoButton.title                    = Symbols.undo.rawValue
        redoButton.title                    = Symbols.redo.rawValue
        
        exponentPlusButton.title            = Symbols.posExp.rawValue
        exponentMinusButton.title           = Symbols.negExp.rawValue
        enterButton.title                   = Symbols.enter.rawValue
        
        updateOperationKeyStatus()
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

        var newOperandType: Engine.OperandType = .integer
        
        switch sender.selectedSegment 
        {
        case 0:     newOperandType = .integer
        case 1:     newOperandType = .float
        default:    break
        }
                
        changeOperandType(newOperandType)
    }
    
    @IBAction func userChangedRadix(sender: NSSegmentedControl)
    {
        guard sender == radixSelector else { return }
        
        if let newRadix = Radix(rawValue: radixSelector.selectedSegment)
        {
            // ask the keypad controller to deal with the new radix: will cause to press "enter(value_in_display)
            // and also update the display
            changeRadix(newRadix: newRadix)            
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
        let enableTernaryFloatOperations:  Bool = operandType == .float && ((availableOperandsCount > 2) || (enableEnter && availableOperandsCount > 1))
        
        enterButton.isEnabled = enableEnter
        periodButton.isEnabled = canInputPeriodCharacter
        exponentPlusButton.isEnabled = canInputExponent
        exponentMinusButton.isEnabled = canInputExponent

        typeSelector.isEnabled  = true
        radixSelector.isEnabled = operandType == .integer

        if operationModifier == .takeStackAsArgument
        {
            operationSumButton.isEnabled       = enableUnaryIntegerOperations || enableUnaryFloatOperations
            operationAverageButton.isEnabled   = enableUnaryFloatOperations
            operationProductButton.isEnabled   = enableUnaryFloatOperations
            operationGeoMeanButton.isEnabled   = enableUnaryFloatOperations
            operationSigmaButton.isEnabled     = enableBinaryFloatOperations
            operationVarianceButton.isEnabled  = enableBinaryFloatOperations

        }
        else if operationModifier == .topOfStackContainsArgumentCount
        {
            operationSumButton.isEnabled       = enableBinaryIntegerOperations  || enableBinaryFloatOperations                        
            operationAverageButton.isEnabled   = enableBinaryFloatOperations
            operationProductButton.isEnabled   = enableBinaryIntegerOperations  || enableBinaryFloatOperations
            operationGeoMeanButton.isEnabled   = enableTernaryFloatOperations
            operationSigmaButton.isEnabled     = enableTernaryFloatOperations
            
        }
        
        operationCopyMemoryAToStack.isEnabled  = !dataSource.isMemoryAEmpty()
        operationCopyMemoryBToStack.isEnabled  = !dataSource.isMemoryBEmpty()
        
        undoButton.isEnabled = dataSource.canUndo()
        redoButton.isEnabled = dataSource.canRedo()
        
        operationSignChangeButton.isEnabled = enableUnaryIntegerOperations || enableUnaryFloatOperations
        operationSquareButton.isEnabled     = enableUnaryIntegerOperations || enableUnaryFloatOperations
        operationSquareRootButton.isEnabled = enableUnaryFloatOperations
        dupButton.isEnabled                 = enableUnaryTypeLessOperation
        operationDropButton.isEnabled       = enableUnaryTypeLessOperation
        operationDropNButton.isEnabled      = enableUnaryTypeLessOperation
        swapButton.isEnabled                = enableBinaryTypeLessOperation
        operationOverButton.isEnabled       = enableBinaryTypeLessOperation
        
        operationBitwiseLogicNot.isEnabled   = enableUnaryIntegerOperations
        operationPrimeFactorsButton.isEnabled = enableUnaryIntegerOperations
        
        operationPlusButton.isEnabled       = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationMinusButton.isEnabled      = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationDivisionButton.isEnabled   = enableBinaryIntegerOperations     || enableBinaryFloatOperations
        operationMultiplicationButton.isEnabled = enableBinaryIntegerOperations || enableBinaryFloatOperations
        operationYPowerXButton.isEnabled   = enableBinaryFloatOperations
        operationlogXYButton.isEnabled     = enableBinaryFloatOperations
        operationConvert2Value2dBButton.isEnabled = enableBinaryFloatOperations
        
        operationShiftLeftButton.isEnabled = enableUnaryIntegerOperations
        operationShiftRightButton.isEnabled = enableUnaryIntegerOperations
        operationNShiftLeftButton.isEnabled = enableBinaryIntegerOperations
        operationNShiftRightButton.isEnabled = enableBinaryIntegerOperations
        operationIncrementButton.isEnabled = enableUnaryIntegerOperations
        operationDecrementButton.isEnabled = enableUnaryIntegerOperations
        operationFactorialButton.isEnabled = enableUnaryIntegerOperations
        operationGCDButton.isEnabled       = enableBinaryIntegerOperations
        operationLCMButton.isEnabled       = enableBinaryIntegerOperations
        
        operationReciprocalButton.isEnabled = enableUnaryFloatOperations
        operationReciprocalSquareButton.isEnabled = enableUnaryFloatOperations
        operationSineButton.isEnabled      = enableUnaryFloatOperations
        operationASineButton.isEnabled     = enableUnaryFloatOperations
        operationCosineButton.isEnabled    = enableUnaryFloatOperations
        operationACosineButton.isEnabled   = enableUnaryFloatOperations
        operationTangentButton.isEnabled   = enableUnaryFloatOperations
        operationATangentButton.isEnabled  = enableUnaryFloatOperations
        operationCotangentButton.isEnabled = enableUnaryFloatOperations
        operationACotangentButton.isEnabled = enableUnaryFloatOperations
        operationEPowerXButton.isEnabled   = enableUnaryFloatOperations
        operation10PowerXButton.isEnabled  = enableUnaryFloatOperations
        operation2PowerXButton.isEnabled   = enableUnaryIntegerOperations || enableUnaryFloatOperations
        operationlogButton.isEnabled       = enableUnaryFloatOperations
        operationlog2Button.isEnabled      = enableUnaryFloatOperations
        operationlog10Button.isEnabled     = enableUnaryFloatOperations
        operationCubicButton.isEnabled     = enableUnaryFloatOperations
        operationThirdRootButton.isEnabled = enableUnaryFloatOperations
        
        operationM66D64Button.isEnabled     = enableUnaryFloatOperations
        operationM64D66Button.isEnabled     = enableUnaryFloatOperations
        
        operationNthRootButton.isEnabled   = enableBinaryFloatOperations        
        operationModuloNButton.isEnabled    = enableBinaryIntegerOperations
        
        operationCardesian2polar.isEnabled  = enableBinaryFloatOperations
        operationPolar2cardesian.isEnabled  = enableBinaryFloatOperations
                
        operationLogicXorButton.isEnabled   = enableBinaryIntegerOperations
        operationLogicOrButton.isEnabled    = enableBinaryIntegerOperations
        operationLogicAndButton.isEnabled   = enableBinaryIntegerOperations
        
        dup2Button.isEnabled                = enableBinaryTypeLessOperation
        operationNPickButton.isEnabled      = enableUnaryTypeLessOperation

        operationπButton.isEnabled          = operandType == .float
        operationeButton.isEnabled          = operandType == .float
        operationhButton.isEnabled          = operandType == .float
        operationkButton.isEnabled          = operandType == .float
        operationµ0Button.isEnabled         = operandType == .float
        operatione0Button.isEnabled         = operandType == .float
        operationc0Button.isEnabled         = operandType == .float
        operationgButton.isEnabled          = operandType == .float
        operationGButton.isEnabled          = operandType == .float
        
        operation7M68Button.isEnabled       = operandType == .float
        operation30M72Button.isEnabled       = operandType == .float
        operation122M88Button.isEnabled       = operandType == .float
        operation153M6Button.isEnabled       = operandType == .float
        operation245M76Button.isEnabled       = operandType == .float
        //operation368M64Button.isEnabled       = operandType == .float
        operation1966M08Button.isEnabled       = operandType == .float
        operation2457M6Button.isEnabled       = operandType == .float
        operation2949M12Button.isEnabled       = operandType == .float
        //operation3939M16Button.isEnabled       = operandType == .float
        operation4915M2Button.isEnabled       = operandType == .float
        operation5898M24Button.isEnabled       = operandType == .float
        operation25M0Button.isEnabled       = operandType == .float
        operation100M0Button.isEnabled       = operandType == .float
        operation125M0Button.isEnabled       = operandType == .float
        operation156M25Button.isEnabled       = operandType == .float

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
        var newDigit = sender.title
        
        print("| \(#function): input new digit '\(newDigit)'")

        switch newDigit 
        {
        case Symbols.posExp.rawValue: newDigit = "e"
        case Symbols.negExp.rawValue: newDigit = "e-"
        default: break
        }
                
        // concatenate the new user input digit
        digitsComposing = digitsComposing + newDigit

        print(self)
                
        // display the composed user input as string
        let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.name, object: document, userInfo: [GlobalKey.numbericString.name : digitsComposing])
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
            let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.name, object: document, 
                                                          userInfo: [GlobalKey.numbericString.name : digitsComposing])
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
            let updateUINote: Notification = Notification(name: GlobalNotification.newKeypadEntry.name, object: document, 
                                                          userInfo: [GlobalKey.numbericString.name : digitsComposing])
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
    
    @IBAction func userPressedOperationModifierButton(sender: NSButton)
    {
        guard sender == stackButton else { return }
        
        operationModifier = stackButton.state == NSOnState ? .topOfStackContainsArgumentCount : .takeStackAsArgument
    }
    
    @IBAction func userPressedUndoOrRedoButton(sender: NSButton)
    {
        guard sender == undoButton || sender == redoButton else { return }
        
        if sender == undoButton
        {
            delegate.undo()
        }
        
        //TODO: implement a redo function.
        
        print("| \(#function): user pressed <'\(sender.title)'> button, sending to engine")
    }

        
    // MARK: - Support
    
    override var description: String
    {
        let addressStr = "KeypadController [\(Unmanaged.passUnretained(self).toOpaque())]"
        let contentStr = "composing: <\(digitsComposing)> [valid number: \(canInputEnter)]"
        return addressStr + " " + contentStr
    }
}

