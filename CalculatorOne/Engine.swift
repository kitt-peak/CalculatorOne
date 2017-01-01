//
//  Engine.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Foundation


class Engine: NSObject, DependendObjectLifeCycle, KeypadControllerDelegate, DisplayDataSource
{
    private var stack: [Int] = [Int]()
    
    @IBOutlet weak var document: Document!
    
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
    
    func pushValueOnStack(value: Int)
    {
        stack.append(value)
        
        updateUI()
    }
    
    
    private func updateUI()
    {
        print(stack)
        
        let updateUINote: Notification = Notification(name: GlobalNotification.newEngineResult.notificationName, object: document, userInfo: [:])
        NotificationCenter.default.post(updateUINote)
    }
    
    
    func userInputNewValue(_ newValue: String, radix: Int)
    {
        if let newInt: Int = Int(newValue, radix: radix)
        {
            if stack.isEmpty
            {
                stack.append(newInt)
            }
            else
            {
                stack[stack.count - 1] = newInt
            }
            
            updateUI()
        }
    }
    
    func userInputEnter()
    {
        if !stack.isEmpty
        {
            stack.append(stack.last!)
        }
        else
        {
            stack.append(0)            
        }
        
        updateUI()
    }
    
    func userInputOperand(operandSymbol: String) 
    {
        let a = stack.popLast()!
        
        switch operandSymbol 
        {
        case "+":
            let b = stack.popLast()!            
            stack.append(a + b)
        case "-":
            let b = stack.popLast()!
            stack.append(b - a)
        case "*":
            let b = stack.popLast()!
            stack.append(a * b)
        case "/":
            let b = stack.popLast()!
            stack.append(b / a)
        case "±":
            stack.append(-a)
        default:
            break
        }
        
        updateUI()
    }
    

    func hasContentForRegister(registerNumber: Int) -> Bool 
    {
        return stack.count > registerNumber
    }
    
    func registerContent(registerNumber: Int) -> Int 
    {
        return stack.reversed()[registerNumber]
    }
    
    
    
}
