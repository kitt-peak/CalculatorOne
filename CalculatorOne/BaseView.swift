//
//  BaseView.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

class BaseView: NSVisualEffectView 
{
    //MARK - Properties
    @IBInspectable override var allowsVibrancy: Bool { return true }
    
    //MARK - Life cycle
    override func awakeFromNib() 
    {
        super.awakeFromNib()
        
        self.appearance   = GlobalConstants.shared.viewAppearanceParameter.appearance
        self.blendingMode = GlobalConstants.shared.viewAppearanceParameter.blendingMode
        self.material     = GlobalConstants.shared.viewAppearanceParameter.material
        self.state        = .active
        
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor.clear
    }
    
    override init(frame frameRect: NSRect) 
    {
        super.init(frame: frameRect)
        
        //NSColor.clear.setFill()
        //NSRectFill(frameRect)
    }
    
    required init?(coder: NSCoder) 
    {
        super.init(coder: coder)

        //NSColor.clear.setFill()
        //NSRectFill(self.frame)

    }
    
    override var isOpaque: Bool { return false }
}


