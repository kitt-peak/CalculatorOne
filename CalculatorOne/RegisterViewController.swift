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
    func userShouldChangeValue(_: Int, inRegister: RegisterViewController) -> Bool
}

class RegisterViewController: NSObject, DependendObjectLifeCycle, MultiDigitViewDelegate
{
    
    @IBOutlet var digitsView: MultiDigitsView!
    { didSet { digitsView.delegate = self } }
    
    var delegate: RegisterViewControllerDelegate!
    
    var acceptsValueChangesByUI: Bool = false
    { didSet { digitsView.allowsValueChangesByUI = acceptsValueChangesByUI } }
    
    var representedValue: Int? = nil
    { didSet { digitsView.value = representedValue } }
    
    var radix: Int = 10
    { didSet { digitsView.radix = radix }}
    
    
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
    
    func userEventShouldSetValue(_ value: Int) -> Bool 
    {
        guard acceptsValueChangesByUI == true else { return false }
        
        if delegate.userShouldChangeValue(value, inRegister: self) == true
        {
            return true
        }
        
        return false
    }
    
}
