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
    //func registerValueChanged(newValue: Int, forRegisterNumber: Int)
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
    { didSet { registerViewController0.delegate = self } }
    

    @IBOutlet weak var dataSource: DisplayDataSource!/*AnyObject!*/

    private var registerViewControllers: [RegisterViewController]!
        
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        registerViewControllers = [registerViewController0, registerViewController1, 
                                   registerViewController2, registerViewController3]
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func documentDidOpen()
    {
        for controller in registerViewControllers
        {
            controller.acceptsValueChangesByUI = false
            controller.documentDidOpen()
        }
        
        // allow the top register view to update its value by the user through the UI
        registerViewController0.acceptsValueChangesByUI = true
        
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newEngineResult.notificationName, object: nil, queue: nil) 
        { [unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            let radix = self.keypadController.radix
            // updates from the engine could involve all register displays
            self.updateRegisterDisplay(source: DataSource.engine, radix: radix)
        }
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newKeypadEntry.notificationName, object: nil, queue: nil) 
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
                    ?   .stringRightAligned(dataSource.registerValue(registerNumber: index, radix: radix.value))   //.integer(dataSource.registerValue(registerNumber: index)) 
                    :   .stringRightAligned("")
            }
            
        case .keypad(let value): 

            // The value from the keypad will be displayed in the top register, left aligned
            // update registers excluding the top register by taking data from the engine stack. Iterate over these register views and ask if the data source has content for it
            for (index, controller) in registerViewControllers.dropFirst().enumerated()
            {
                controller.representedValue = dataSource.hasValueForRegister(registerNumber: index) 
                    ?   .stringRightAligned(dataSource.registerValue(registerNumber: index, radix: radix.value))   //.integer(dataSource.registerValue(registerNumber: index)) 
                    :   .stringRightAligned("")                    
//                    ?   .integer(dataSource.registerValue(registerNumber: index)) 
//                    :   .string("")
            }

            // then, update the top register with the supplied value.
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

        for (index, register) in registerViewControllers.enumerated()
        {
            if register == inRegister
            {
                //dataSource.registerValueChanged(newValue: value, forRegisterNumber: index)
            }
            
        }
        
        
        return false
    }
    
    
}
