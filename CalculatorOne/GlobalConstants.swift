//
//  GlobalConstants.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

class GlobalConstants
{
    // make this a singleton
    static let shared: GlobalConstants = GlobalConstants()

    private init() { }
    
    /// View Appearance
    struct ViewAppearanceParameter 
    {
        let appearance   = NSAppearance(named: NSAppearanceNameAqua)
        let blendingMode = NSVisualEffectBlendingMode.behindWindow
        let material     = NSVisualEffectMaterial.dark
    }
    
    var viewAppearanceParameter: ViewAppearanceParameter { return ViewAppearanceParameter() }

    
    // MARK: Digit parameters.
    let digitImageSizeInPoints = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view
    let digitSize              = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view
    let countDigitsInImageStrip: Int = 19                               // specifies the number of digits the digit image strip holds (0 to F, ".", "-")
    
    func digitStripImageForKind(_ kind: DigitView.Kind) -> NSImage
    {
        var name = ""
        switch kind 
        {
        case .courierStyle: name = "Courier19DigitStrip"
        case .undefined:    name = "Courier19DigitStrip"
        }
        
        let image = NSImage(named: name)
        
        guard image != nil else { abort() }
        
        return image!
    }
    
}


enum GlobalNotification: String
{
    case newEngineResult = "newEngineResult"
    
    var notificationName: Notification.Name
    {
        switch self 
        {
        case .newEngineResult: return Notification.Name(self.rawValue)
        }
    }
}

