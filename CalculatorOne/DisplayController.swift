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
    func registerValue(registerNumber: Int, radix: Int) -> String
    func registerValueWillChange(newValue: String, forRegisterNumber: Int) -> Bool
    func registerValueDidChange(newValue: String, forRegisterNumber: Int)
}

enum DataSource
{
    case engine
    case keypad(String)
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

    @IBOutlet weak var dataSource: DisplayDataSource!/*AnyObject!*/

    private var registerViewControllers: [RegisterViewController]!
        
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        registerViewControllers = [registerViewController0, registerViewController1, 
                                   registerViewController2, registerViewController3]
        
        for reg in registerViewControllers
        {
            reg.delegate = self
        }
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func documentDidOpen()
    {
        for controller in registerViewControllers
        {
            controller.acceptsValueChangesByUI = true
            controller.documentDidOpen()
        }
        
        // allow the top register view to update its value by the user through the UI
        // registerViewController0.acceptsValueChangesByUI = true
        
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.name, object: nil, queue: nil) 
        { [unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            let radix = self.keypadController.radix
            // updates from the engine could involve all register displays
            self.updateRegisterDisplay(source: DataSource.engine, radix: radix)
        }
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newKeypadEntry.name, object: nil, queue: nil) 
        { [ unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            if let stringValue: String = notification.userInfo?["StringValue"] as? String
            {
                let radix = self.keypadController.radix

                // updates from the keypad are displayed in register 0.
                self.updateRegisterDisplay(source: DataSource.keypad(stringValue), radix: radix)
            }
            
        }
    }
    
    
    
    func documentWillClose() 
    {
        for controller in registerViewControllers
        {
            controller.documentWillClose()
        }
    }
    
    
    /// Causes the register views to update themselves
    ///
    /// - Parameter source: Datasource. When .engine, the register views ask take data from the engine data source for updating themselves. When .keypad(value: String), the top register copies "value" left-aligned into the top register. All other registers are updated from the engine data source (since the top register contains "value", register 1 will contain top engine stack, register 2: engine stack top + 1 etc.
    func updateRegisterDisplay(source: DataSource, radix: Radix)
    {
        switch source 
        {
        case .engine:
            
            // update all registers taking data from the engine stack. Iterate over all register views and ask if the data source has content for it
            for (index, controller) in registerViewControllers.enumerated()
            {
                controller.representedValue = dataSource.hasValueForRegister(registerNumber: index) 
                    ?   .stringRightAligned(dataSource.registerValue(registerNumber: index, radix: radix.value))
                    :   .stringRightAligned("")
            }
            
        case .keypad(let value): 

            // The value from the keypad will be displayed in the top register, left aligned
            // update registers excluding the top register by taking data from the engine stack. Iterate over these register views and ask if the data source has content for it
            for (index, controller) in registerViewControllers.dropFirst().enumerated()
            {
                controller.representedValue = dataSource.hasValueForRegister(registerNumber: index) 
                    ?   .stringRightAligned(dataSource.registerValue(registerNumber: index, radix: radix.value)) 
                    :   .stringRightAligned("")                    
            }

            // then, update the top of stack register with the supplied value.
            registerViewController0.representedValue = .stringLeftAligned(value)        
        }        
    }
    
    
    func changeRadix(_ radix: Radix)
    {
        for controller in registerViewControllers
        { controller.radix = radix.value }
                
        updateRegisterDisplay(source: .engine, radix: radix)
    }
    

    
    
    func userShouldChangeValue(_ value: Int, inRegister: RegisterViewController) -> Bool 
    {

        for (_/*index*/, register) in registerViewControllers.enumerated()
        {
            if register == inRegister
            {
                //dataSource.registerValueChanged(newValue: value, forRegisterNumber: index)
            }
        }
        return false
    }
    
    private func registerNumberForController(_ viewController: RegisterViewController) -> Int?
    {
        for (index, vC) in registerViewControllers.enumerated()
        {
            if viewController == vC { return index }
        }
        
        return nil
    }
    
    
    //MARK: - RegisterViewController protocoll
    func userWillTweakValue(_ valueStr: String, inRegister: RegisterViewController) -> Bool
    {
        if let registerNumber = registerNumberForController(inRegister)
        {
            // Can valueStr be represented as a numerical Value? If yes, return true, otherwise, false
            if dataSource.registerValueWillChange(newValue: valueStr, forRegisterNumber: registerNumber) == true
            {
                return true
            }
            
        }

        return false
    }
    
    func userDidTweakValue(_ valueStr: String, inRegister: RegisterViewController)
    {
        // convert valueStr to a numerical value and enter into the specified register
        if let registerNumber = registerNumberForController(inRegister)
        {
            dataSource.registerValueDidChange(newValue: valueStr, forRegisterNumber: registerNumber)
            
            //updateRegisterDisplay(source: DataSource.engine, radix: keypadController.radix)
            inRegister.representedValue = RegisterValueRepresentation.stringRightAligned(valueStr)
            
            //dataSource.registerValue(registerNumber: registerNumber, radix: keypadController.radix.value)
        }        
    }

    
    
}
