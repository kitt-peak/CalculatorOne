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
    func registerValueWillChange(newValue: String, radix: Int, forRegisterNumber: Int) -> Bool
    func registerValueDidChange(newValue: String, radix: Int, forRegisterNumber: Int)
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
    
    @IBOutlet weak var registerViewControllerFourth: RegisterViewController!
    @IBOutlet weak var registerViewControllerThird:  RegisterViewController!
    @IBOutlet weak var registerViewControllerSecond: RegisterViewController!
    @IBOutlet weak var registerViewControllerTop:    RegisterViewController!  /* Top of stack is index 0 */

    @IBOutlet weak var dataSource: DisplayDataSource!/*AnyObject!*/

    private var registerViewControllers: [RegisterViewController]!
    
    var acceptValueChangesByUI : Bool = true
    { didSet 
        {
            guard registerViewControllers != nil else { return }
            
            for controller in registerViewControllers
            {
                controller.acceptsValueChangesByUI = acceptValueChangesByUI
            }
        }
    }
        
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // put all controllers into a container for easy access. The top of stack controller has the index 0.
        registerViewControllers = [registerViewControllerTop, registerViewControllerSecond, 
                                   registerViewControllerThird, registerViewControllerFourth]
        
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
            self.updateRegisterDisplay(fromSource: DataSource.engine, radix: radix)
        }
        
        NotificationCenter.default.addObserver(forName: GlobalNotification.newKeypadEntry.name, object: nil, queue: nil) 
        { [ unowned self] (notification) in
            
            guard notification.object as? Document == self.document else { return }
            
            if let stringValue: String = notification.userInfo?[GlobalKey.numbericString.name] as? String
            {
                let radix = self.keypadController.radix

                // updates from the keypad are displayed in register 0.
                self.updateRegisterDisplay(fromSource: DataSource.keypad(stringValue), radix: radix)
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
    /// - Parameter source: Datasource. When .engine, all register views are displayed right-aligned. The data to update is taken from the controllers datasource.
    ///   When .keypad, the top register is taken from the associated value of the method argument and is displayed left-aligned.
    ///   All other register values are taken from the datasource and are displayed right-aligned at one register view position higher. That is, register 0
    ///   from the data source (the top of stack) is displayed in register view 1, data source reg. 1 in register view 2 etc.
    //    The register view controllers asks their data source for updating themselves. When .keypad(value: String), the top register copies "value" left-aligned into the top register. All other registers are updated from the engine data source (since the top register contains "value", register 1 will contain top engine stack, register 2: engine stack top + 1 etc.
    func updateRegisterDisplay(fromSource: DataSource, radix: Radix)
    {
        guard registerViewControllers != nil else { return }
        
        var registerViewControllersToShowRightAligned : [RegisterViewController] = registerViewControllers!
    
        switch fromSource 
        {
        case .engine:
            break
            
        case .keypad(let str):
            registerViewControllersToShowRightAligned.removeFirst()
                        
            // then, update the top of stack register with the supplied value.
            registerViewControllerTop.representedValue = RegisterViewController.RepresentedValue(
                content: str, 
                radix: radix, 
                alignment: .left)
        }
        
        // update all registers taking data from the engine stack. Iterate over all register views and ask if the data source has content for it
        for (index, controller) in registerViewControllersToShowRightAligned.enumerated()
        {
            if dataSource.hasValueForRegister(registerNumber: index) == true
            {
                let v = RegisterViewController.RepresentedValue(content: dataSource.registerValue(registerNumber: index, radix: radix.value), 
                                                                radix: radix, 
                                                                alignment: RegisterViewController.Alignment.right)
                controller.representedValue = v
            }
            else
            {
                controller.representedValue = RegisterViewController.RepresentedValue(content: "", radix: .decimal, alignment: .right)
            }                
        }

    }
    
    
    func changeRadix(_ radix: Radix)
    {
        // the update will set the new radix
        updateRegisterDisplay(fromSource: .engine, radix: radix)
    }
    

    
    
//    func userShouldChangeValue(_ value: Int, inRegister: RegisterViewController) -> Bool 
//    {
//
//        for (_/*index*/, register) in registerViewControllers.enumerated()
//        {
//            if register == inRegister
//            {
//                //dataSource.registerValueChanged(newValue: value, forRegisterNumber: index)
//            }
//        }
//        return false
//    }
    

    /// Converts a register view controller to a register number. This number can be used in the engine to query or change register values.
    /// The top of the stack is always in register 0. In the user interface, the top of stack (register 0) may be the bottom view in the display
    ///
    /// - Parameter viewController: the view controller to convert to a register number
    /// - Returns: the register number (index) that the engine understands
    private func registerNumberForController(_ viewController: RegisterViewController) -> Int?
    {
        for (index, vC) in registerViewControllers.enumerated()
        {
            if viewController == vC { return index }
        }
        
        return nil
    }
    
    
    //MARK: - RegisterViewController protocoll
    
    /// Tests for acceptance of changing a register to the specified value
    ///
    /// The method will ask its datasource (engine) if the value hosted by the register view controller can be changed
    /// - Parameters:
    ///   - valueStr: the new value to be tested, as String
    ///   - inRegister: the register view controller hosting the value to be changed
    /// - Returns: true if a change is permitted, otherwise false.
    func userWillTweakRepresentedValue(_ value: RegisterViewController.RepresentedValue, inRegister: RegisterViewController) -> Bool
    {
        guard acceptValueChangesByUI == true else { return false }
        
        // try to convert the register view controller to a register number (number 0 is the top of stack view controller)  
        if let registerNumber = registerNumberForController(inRegister)
        {
            // Can valueStr be represented as a numerical Value? If yes, return true, otherwise, false
            return dataSource.registerValueWillChange(newValue: value.content, radix: value.radix.value, forRegisterNumber: registerNumber)
        }

        return false
    }
    
    
    /// Changes a register to the specified value. Call userWillTweakValue(_ valueStr: String, inRegister: RegisterViewController) first
    /// to test for acceptance of changing a register value
    ///
    /// The method will ask its datasource (engine) to change the value hosted by the register view controller
    /// - Parameters:
    ///   - valueStr: the new value as String
    ///   - inRegister: the register view controller hosting the value to be changed
    func userDidTweakRepresentedValue(_ value: RegisterViewController.RepresentedValue, inRegister: RegisterViewController)
    {
        guard acceptValueChangesByUI == true else { return }

        // try to convert the register view controller to a register number (number 0 is the top of stack view controller)  
        if let registerNumber = registerNumberForController(inRegister)
        {
            dataSource.registerValueDidChange(newValue: value.content, radix: value.radix.value, forRegisterNumber: registerNumber)
            
            inRegister.representedValue = value
        }        
    }

    
    
}
