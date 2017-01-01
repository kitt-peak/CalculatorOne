//
//  DisplayController.swift
//  CalculatorOne
//
//  Created by Andreas on 30/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Foundation

@objc protocol DisplayDataSource
{
    func hasContentForRegister(registerNumber: Int) -> Bool
    func registerContent(registerNumber: Int) -> Int
}


class DisplayController: NSObject, DependendObjectLifeCycle 
{

    @IBOutlet weak var document: Document!
    
    @IBOutlet weak var registerViewController3: RegisterViewController!
    @IBOutlet weak var registerViewController2: RegisterViewController!
    @IBOutlet weak var registerViewController1: RegisterViewController!
    @IBOutlet weak var registerViewController0: RegisterViewController!

    @IBOutlet weak var dataSource: DisplayDataSource!/*AnyObject!*/

    
    private var registerViewControllers: [(index: Int, controller: RegisterViewController)]!
    
    var radix: Int = 10
    { didSet { for c in registerViewControllers { c.controller.radix = radix }}} 
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        registerViewControllers = [(0, registerViewController0), (1, registerViewController1), 
                                   (2, registerViewController2), (3, registerViewController3)]
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func documentDidOpen()
    {
        for (_, controller) in registerViewControllers
        {
            controller.documentDidOpen()
        }
        
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
            if dataSource.hasContentForRegister(registerNumber: index)
            {
                let content = dataSource.registerContent(registerNumber: index)
                controller.representedValue = content
            }
            else
            {
                controller.representedValue = 0
            }
        }
    }
    
}
