//
//  DisplayController.swift
//  CalculatorOne
//
//  Created by Andreas on 30/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

@objc protocol DisplayDataSource
{
    func numberOfRegistersWithContent() -> Int
    func hasValueForRegister(registerNumber: Int) -> Bool
    func registerValue(registerNumber: Int) -> Int
    func registerValueChanged(newValue: Int, forRegisterNumber: Int)
}




class DisplayController: NSObject, DependendObjectLifeCycle, RegisterViewControllerDelegate 
{

    @IBOutlet weak var document: Document!
    
    @IBOutlet weak var displayView: DisplayView!
    @IBOutlet weak var keypadController: KeypadController!
    
    @IBOutlet weak var registerViewController3: RegisterViewController!
    @IBOutlet weak var registerViewController2: RegisterViewController!
    @IBOutlet weak var registerViewController1: RegisterViewController!
    @IBOutlet weak var registerViewController0: RegisterViewController!
    { didSet { registerViewController0.delegate = self } }
    

    @IBOutlet weak var calculatorModeSelector: NSSegmentedControl!
    @IBOutlet weak var radixSelector: NSSegmentedControl!
    
    @IBOutlet weak var dataSource: DisplayDataSource!/*AnyObject!*/

    private var registerViewControllers: [(index: Int, controller: RegisterViewController)]!
    
    
    var radix: Radix 
    { return Radix(rawValue: radixSelector.selectedSegment)! } 

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        registerViewControllers = [(0, registerViewController0), (1, registerViewController1), 
                                   (2, registerViewController2), (3, registerViewController3)]
        
        radixSelector.setSelected(true, forSegment: 2)
        
        calculatorModeSelector.setSelected(true, forSegment: 0)
        
        
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func documentDidOpen()
    {
        for (_, controller) in registerViewControllers
        {
            controller.acceptsValueChangesByUI = false
            controller.documentDidOpen()
        }
        
        // allow the top register view to update its value by the user through the UI
        registerViewController0.acceptsValueChangesByUI = true
        
        userChangedRadix(sender: radixSelector)

        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.notificationName, object: nil, queue: nil) 
        { [unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            self.updateRegisterDisplay()
        }
    }
    
    
    
    func documentWillClose() 
    {
        for (_, controller) in registerViewControllers
        {
            controller.documentWillClose()
        }
    }
    
    
    func updateRegisterDisplay()
    {

        for (index, controller) in registerViewControllers
        {
            if dataSource.hasValueForRegister(registerNumber: index)
            {
                let content = dataSource.registerValue(registerNumber: index)
                controller.representedValue = content
            }
            else
            {
                controller.representedValue = nil
            }
        }
    }
    
    
    //displayController.radix = self.radix
    // digitsComposing = ""
    
    // disable all button representing digits equal to or larger than the radix
//    func changeRadix(newRadix: Radix)
//    {
//        for (representedDigit, button) in keypadController  digitButtons
//        {
//            button.isEnabled = (representedDigit < self.radix ? true : false)
//        }
//        
//    }
    
    
    
    
    @IBAction func userChangedRadix(sender: NSSegmentedControl)
    {
        guard sender == radixSelector else { return }
        
        if let newRadix = Radix(rawValue: radixSelector.selectedSegment)
        {
            keypadController.changeRadix(newRadix: newRadix)
            
            for c in registerViewControllers
            { c.controller.radix = newRadix.value}
        }
    }
    
    func userShouldChangeValue(_ value: Int, inRegister: RegisterViewController) -> Bool 
    {

        for (i, register) in registerViewControllers
        {
            if register == inRegister
            {
                dataSource.registerValueChanged(newValue: value, forRegisterNumber: i)
            }
            
        }
        
        
        return false
    }
    
    
}
