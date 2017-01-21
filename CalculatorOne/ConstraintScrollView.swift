//
//  ConstraintScrollImageView.swift
//  CalculatorOne
//
//  Created by Andreas on 10/01/2017.
//  Copyright © 2017 Kitt Peak. All rights reserved.
//

import Cocoa

/*
 Constraining Scrolling
 
 Subclasses of NSView override the adjustScroll: method to provide a view fine-grained control of its position during scrolling. A custom view subclass can quantize scrolling into regular units—to the edges of a spreadsheet’s cells, for example—or simply limit scrolling to a specific region of the view. The adjustScroll: method provides the proposed rectangle that the scrolling mechanism will make visible and expects the subclass to return the passed rectangle or an altered rectangle that will constrain the scrolling.
 
 Listing 4 shows an implementation of adjustScroll: that constrains scrolling of the view to 72 pixel increments, even when dragging the scroll knob.
 
 Listing 4  Constraining scrolling with adjustScroll:
 - (NSRect)adjustScroll:(NSRect)proposedVisibleRect
 {
 NSRect modifiedRect=proposedVisibleRect;
 
 // snap to 72 pixel increments
 modifiedRect.origin.x = (int)(modifiedRect.origin.x/72.0) * 72.0;
 modifiedRect.origin.y = (int)(modifiedRect.origin.y/72.0) * 72.0;
 
 // return the modified rectangle
 return modifiedRect;
 }
 The adjustScroll: method is not used when scrolling is initiated by lower-level scrolling methods provided by NSClipView (scrollToPoint:) and NSScrollView (scrollRectToVisible:).
 
 
 */

class ConstraintScrollView: NSView
{
    var minimumScrollOriginY: CGFloat = 0.0
    var maximumScrollOriginY: CGFloat = 100000.0
    
    override func adjustScroll(_ newVisible: NSRect) -> NSRect 
    {
        var modifiedRect = newVisible
        
        modifiedRect.origin.y = newVisible.origin.y < minimumScrollOriginY ? minimumScrollOriginY : modifiedRect.origin.y
        modifiedRect.origin.y = newVisible.origin.y > maximumScrollOriginY ? maximumScrollOriginY : modifiedRect.origin.y
            
        return modifiedRect
    }

    
}
