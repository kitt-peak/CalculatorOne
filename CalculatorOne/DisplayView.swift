//
//  DisplayView.swift
//  CalculatorOne
//
//  Created by Andreas on 07/01/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Cocoa

class DisplayView: BaseView
{

    //MARK - Properties
    @IBInspectable var backgroundColor: NSColor = NSColor.clear
    
    //MARK - Life cycle
    override func awakeFromNib() 
    {
        super.awakeFromNib()
        
        wantsLayer = true
    
        self.layer?.borderColor = NSColor.gray.cgColor
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 5.0
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    

}
