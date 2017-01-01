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
        let blendingMode = NSVisualEffectBlendingMode.withinWindow
        let material     = NSVisualEffectMaterial.dark
    }
    
    var viewAppearanceParameter: ViewAppearanceParameter { return ViewAppearanceParameter() }

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

