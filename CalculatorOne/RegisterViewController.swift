//
//  RegisterViewController.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

class RegisterViewController: NSObject, DependendObjectLifeCycle
{
    
    @IBOutlet var digitsView: SixteenDigitsView!
    
    var representedValue: Int = 0
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
    
    
    
}
