//
//  DigitView.swift
//  CalculatorOne
//
//  Created by Andreas on 28/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa


protocol DigitViewDelegate
{
    func userScrollEventWillChangeDigit(_ digit: Digit, fromView: DigitView) -> Bool
    func scrollEventStarted()
    func scrollEventStopped()
}

/// Displays a single digit (0 to F, +, - and "E" for failure) in a vertical scroll view, allows the user to change the digit by scrolling
/// DigitView registers itself as observer to user scrolling of its embedded image view. This is the begin of the machinery that reports
/// user initiated scrolls into changes the displayed digits
class DigitView: BaseView 
{
    /// specifies the customization of a digit view, such as the style of the digit numbers and their visual representations. In future implementations, this can be used to define how many numbers a digit view contains etc.
    enum Kind
    {
        case courierStyleMetallic
        case courierStyleWithColor(NSColor)
        case undefined
    }

    static let constantSize: CGSize = GlobalConstants.shared.digitStrip.imageSizeInPoints // static view size, cannot be changed, requires a corresponding width of 20 point and an image height of 28 points times count digits
    
    private var embeddedScrollView: NSScrollView!             // mechanics for scrolling the digits

    private var embeddedImageBackgroundColor: NSColor = GlobalConstants.shared.digitViewBackgroundColor
    
    private var kind: Kind = .courierStyleMetallic                           // digit type and its visual characteristics
    private var digitSize: CGSize = GlobalConstants.shared.digitStrip.imageSizeInPoints         // the size of one digit
    private var countDigits: Int  = GlobalConstants.shared.digitStrip.countDigits // number of digits that can be presented
    private var scrollYOffset: CGFloat = 0.0            // correction offset, makes a digit centered in the view vertically
    
    private var viewDrawsBackground: Bool = false
        
    // this view reports
    var delegate: DigitViewDelegate?
    
    private var enableBoundsChangeNotifications: Bool = false /*true. Disabled on July 6, 2017 */ 
    { didSet 
        {  
            //Swift.print("-- setting enable bounds change notification to \(enableBoundsChangeNotifications) on \(self)")
            embeddedScrollView.contentView.postsBoundsChangedNotifications = enableBoundsChangeNotifications
            
            enableBoundsChangeNotifications == false ? delegate?.scrollEventStarted() : delegate?.scrollEventStopped()

        } 
    }
    
    //MARK: - Life cycle
                
    /// Convenience initializer. Constructs a DigitView of the specified kind at the specified origin with the fixed size of 22 x 28
    ///
    /// - Parameters:
    ///   - kind: Kind, specifies the range of digits and its appearance
    ///   - origin: CGPoint, the origin of the view in the coordinates of its superview
    convenience init(kind: Kind, origin: CGPoint)
    {
        self.init(frame: NSRect(origin: origin, size: CGSize.zero))

        let newFrame: CGRect = CGRect(origin: frame.origin, size: DigitView.constantSize)
        
        self.kind = kind
        completeInitWithRect(frameRect: newFrame, kind: kind)
    }
    
    /// Initializes a DigitView with a fixed size from code. Made private so that a convenience initializer must be used to construct a DigitView object
    ///
    /// - Parameter frameRect: specifies the where the digit view is placed in its parent view by the frameRect.origin parameter. frameRect.size is ignored, the view will always have a size of 24x32
    private override init(frame frameRect: NSRect)
    {
        let newFrame: CGRect = CGRect(origin: frameRect.origin, size: DigitView.constantSize)
        super.init(frame: newFrame)

        //completeInitWithRect(frameRect: newFrame, kind: kind)
    }
    
    /// TODO: what does this required implementation?
    required init?(coder: NSCoder)
    {
        //let frameRect = CGRect.zero
        //let newFrame: CGRect = CGRect(origin: frameRect.origin, size: DigitView.constantSize)
        super.init(coder: coder)
        
        //completeInitWithRect(frameRect: newFrame, kind: kind)
    }
    
    
    /// Second and last part of the designated initializer for this class
    ///
    /// - Parameters:
    ///   - frameRect: <#frameRect description#>
    ///   - kind: <#kind description#>
    private func completeInitWithRect(frameRect: NSRect, kind: Kind)
    {
        wantsLayer = true
        layer?.backgroundColor = CGColor.clear
        
        scrollYOffset    = 4.0    // centers the digit in a view. Necessary due to the font not centering characters vertically 
        
        // configure the scroll view to the same size as self: the scroll view is fully contained in self.
        // set the size of the view to a minimum size, making the view constant in size
        embeddedScrollView = scrollViewConfiguredWith(size: frameRect.size, kind: kind)
        
        self.addSubview(embeddedScrollView)
        
        _digit = .blank
        
        acceptsTouchEvents = true
        
    }
    
    /// Returns a fully configured scroll view. Size is e.g. 20x28. It is filled  filled vertically arranged digits (numbers=
    ///
    /// - Parameter size: <#size description#>
    /// - Returns: <#return value description#>
    private func scrollViewConfiguredWith(size: CGSize, kind: DigitView.Kind) -> NSScrollView
    {
        let view = NSScrollView(frame: NSRect(origin: CGPoint.zero, size: size)) // e.g. 20x28, the visible size
        view.hasVerticalScroller   = false
        view.hasHorizontalScroller = false
        view.horizontalScrollElasticity = .none
        view.horizontalLineScroll = 0.0
        view.horizontalPageScroll = 0.0
        view.verticalLineScroll = digitSize.height
        view.verticalPageScroll = digitSize.height
        view.verticalScrollElasticity = .none
        view.allowsMagnification = false
        view.drawsBackground = viewDrawsBackground
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.clear
        view.backgroundColor = NSColor.clear
                
        // create the view that is being scrolled. This is a long view (width: 20.0, height: 28 * #digits) where only only one digit
        // is displayed through the scroll view. Insert the image view into the scroll view as document view
        let embeddedImageView = embeddedImageViewConfiguredWith(kind: kind)        
        view.documentView = embeddedImageView

        // Make sure the watched view is sending bounds changed
        // notifications (which is probably does anyway, but calling this again won't hurt).                
        // register for those notifications on the synchronized content view
        view.contentView.postsBoundsChangedNotifications = true
        
        // the content view inside the DigitView can be scrolled by the user. The implementation allows vertical scrolls of the 
        // embedded image view. The embbeded image view is a strip image filled with numbers. When scrolling, the user scrolls thru
        // the numbers. This is reported to this DigitView classe because it is registering itself as the the observer of 
        // "Notification.Name.NSViewBoundsDidChange". DigitView will translate the scrolling into changes of the value that DigitView displays.
        NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: view.contentView, queue: nil) 
        { (notification) in
            
            // suppress the notification being effective by setting isBusyScrolling to "true". This flag is set to true if digits are set programmatically
            ////17.6.guard self.isBusyScrollingToADigit == false else { return }
            
            // this is the new y coordinate the used has scrolled the document view (digit strip image= to
            let newOriginY = self.embeddedScrollView.contentView.bounds.origin.y
        
            // report the new origin
            self.updateValueForScrollOriginY(y: newOriginY)            
        }

        
        return view
    }
    
    private func embeddedImageViewConfiguredWith(kind: DigitView.Kind) -> ConstraintScrollView
    {
        let stripImage: NSImage = GlobalConstants.shared.digitStrip.image!
        
        let view = ConstraintScrollView(frame: NSRect(origin: CGPoint.zero, size: stripImage.size))
        view.wantsLayer = true
        view.layer?.backgroundColor = embeddedImageBackgroundColor.cgColor
        
        // set scroll contraints. For now, these constraints are as big as the image and don't contraint anything
        view.minimumScrollOriginY = 0.0
        view.maximumScrollOriginY = stripImage.size.height///view.image!.size.height
        
        view.layer?.contents = stripImage
        
        return view

    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: nil)
    }
    
    /// Sets itself to a new digit as a function of the user scrolling the embedded digit image strip view to a new y coordinate
    /// The function asks the delegate of this class for permission to set itself to a new digit.
    /// If permission granted by the delegate: 
    /// If permission refused by the delegate:
    ///
    /// - Parameter y: the new y coordinate
    private func updateValueForScrollOriginY(y: CGFloat)
    {
        // return if this is called while a digit is set programmatically
        guard enableBoundsChangeNotifications == true else { return }
        
        // correct for the initial offset in showing the digit centered in the view
        var yPosition = y - scrollYOffset
        
        // make sure a new digit is detected if scrolled half way to the new digit
        let detectionYOffset = digitSize.height / 2.0 
        yPosition += detectionYOffset
       
        // calculate the digit position scrolling to as index in the strip 
        let index = Int(yPosition / self.digitSize.height) - GlobalConstants.shared.digitStrip.indexOfDigitZeroInImageStrip

        if let newDigitCandidate: Digit = Digit(rawValue: index)
        {
            guard newDigitCandidate != _digit else { return }
            
            if delegate?.userScrollEventWillChangeDigit(newDigitCandidate, fromView: self ) == true
            {
                // successfully changing a digit after the delegate approved that
                // Note: the framework will call "touchesEnded(with event: NSEvent)"
                // after the user finished scrolling: the function touchesEnded(with event: NSEvent) will
                // complete the user scrolling by moving the document view (of the scroll view) in its place to center a digit in the view.
                _digit = newDigitCandidate
                
                scrollToDigit(_digit, animated: true)
                //Swift.print("user changed digit to \(_digit)")                                
            }
            else
            {
                // Delegate refused. The framework will still call the function touchesEnded(with event: NSEvent) after the
                // user ended scrolling. This will case the view to scroll-back to the original digit                
                Swift.print("delegate refused to change digit to \(newDigitCandidate), staying with \(_digit)")                                                
            }
        }
    }
    
    //MARK: - Configuration
    /// Constraints to view to only show digits valid for the specified radix.
    /// For instance, a radix of 10 only allows digits 0 to 9. 
    /// The class implements this by constraining the scroll region of the image representing the digits in the view 
    ///
    /// - Parameter radix: Int, radix that view can display
    func configureForRadix(_ radix: Int)
    {
        // set constraints
        //  radix = 10: digits go from 0 to 9
        //  radix = 10: digits go from 0 to 15 (F)
        // the scrollable image view has digits at these Y positions:
        // - . at 0x digit.size.height
        // - 0 at 1x digit.size.height
        // ...
        // - 9 at 10x digit.size.height
        // ...
        // - E at 15x digit.size.heigt 
        // - F at 16x digit.size.heigt
        // - - at 17x digit.size.height
        
        /*embeddedImageView*/(embeddedScrollView.documentView as! ConstraintScrollView).minimumScrollOriginY = CGFloat(GlobalConstants.shared.digitStrip.indexOfDigitZeroInImageStrip) * digitSize.height + scrollYOffset
        /*embeddedImageView*/(embeddedScrollView.documentView as! ConstraintScrollView).maximumScrollOriginY = CGFloat(radix + 1) * digitSize.height + scrollYOffset
        
        // 3x digitSize.height constraints scrolling to not show the digit at position 0 and 1
        //embeddedImageView.maximumScrollOriginY = CGFloat(radix + 1) * digitSize.height + scrollYOffset
    }
    
    //MARK: - Digit representation
    private var _digit: Digit = .d0                  // private var is equivalent to public digit and is set by the setDigit(...) methods
    
    var digit: Digit //= .d0
    {
        get { return _digit }
    }    
    
    /// Sets the main property of the class to the specified digit. The view will scroll to the new digit.
    ///
    /// - Parameters:
    ///   - digit: Digit: specifies the digit to display
    ///   - animated: if true, setting a new digit is visibly scrolled, if false the view jumps to the digit immediately
    func setDigit(_ digit: Digit, animated: Bool)
    {
        guard _digit != digit else { return }
        
        // surpress scroll notifications while programmatically updating digits
        /////disableNotificationEchoOnDigitChange = true

        scrollToDigit(digit, animated: true)
        _digit = digit

        // re-enable scroll notifications after programmatically updating digits is done
        // in the function scrollToDigit
        ////disableNotificationEchoOnDigitChange = false

    }
    
    /// Sets the main property of the class to the specified digit. The view will scroll to the new digit.
    ///
    /// - Parameters:
    ///   - digit: Integer: specifies the digit to display
    ///   - animated: if true, setting a new digit is visibly scrolled, if flase the view jumps to the digit immediately
    func setDigit(value: Int, animated: Bool)
    {
        guard _digit != digit else { return }
        
        // surpress scroll notifications while programmatically updating digits
        ///////disableNotificationEchoOnDigitChange = true
        
        if let digit: Digit = Digit(rawValue: value)
        {
            self.setDigit(digit, animated: animated)
        }
        else
        {
            self.setDigit(.minus, animated: animated)
        }
        
        // re-enable scroll notifications after programmatically updating digits is done
        // in the function scrollToDigit
        // disableNotificationEchoOnDigitChange = false

        return
    }

    
    private func scrollToDigit(_ digit: Digit, animated: Bool)
    {
        ////17.6.guard disableNotificationEchoOnDigitChange == false else { return }
        //let semaphore : DispatchSemaphore = DispatchSemaphore(value: 1)
                
        enableBoundsChangeNotifications = false
        
        var scrollYValue: CGFloat = 0.0
                
        scrollYValue = CGFloat(digit.rawValue + GlobalConstants.shared.digitStrip.indexOfDigitZeroInImageStrip) * digitSize.height + scrollYOffset
        
        if animated == false
        {
            embeddedScrollView.documentView?.scroll(CGPoint(x: 0.0, y: scrollYValue))
        }
        else
        {
            let deltaDigitToScroll: Int = abs(self._digit.rawValue - digit.rawValue)
            let pointsToScroll: Double = Double(deltaDigitToScroll) * Double(digitSize.height)
            
            let scrollVelocity: Double = 600.0 // (points per second)
            
            ////17.6.isBusyScrollingToADigit = true
            
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = pointsToScroll / scrollVelocity
            NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            NSAnimationContext.current.completionHandler = 
            { 
                () -> () in 
                    ////17.6.self.isBusyScrollingToADigit = false 
                    self.enableBoundsChangeNotifications = true
                //semaphore.signal()
            }
            
            let clip:NSClipView = embeddedScrollView.contentView
            
            var newOrigin : NSPoint = clip.bounds.origin
            newOrigin.y = CGFloat(scrollYValue)
            
            clip.animator().setBoundsOrigin(newOrigin)
            
            embeddedScrollView.reflectScrolledClipView(embeddedScrollView.contentView)
            
            NSAnimationContext.endGrouping()
            
        }        
        
        //semaphore.wait()

    }
    
    
    override func wantsScrollEventsForSwipeTracking(on axis: NSEvent.GestureAxis) -> Bool 
    {
        return axis == .vertical
    }
    
    override func swipe(with event: NSEvent) 
    {
        Swift.print(event)
    }
    
    override func scrollWheel(with event: NSEvent) 
    {
        Swift.print(event)
    }

    override func touchesBegan(with event: NSEvent) 
    {
        Swift.print("touches began with \(event.allTouches())")
        
        ////17.6.disableNotificationEchoOnDigitChange = true
    }
    
    /// touches ended is called by the framework after the user finished scrolling a digit view to change (tweak) a digit
    /// This implementation will call "scrollToDigit" to scroll the embedded document view to the digit that the class represents
    /// The result of this method is that any user scroll events will cause the digitView to accurately show the represented digit
    /// in the center of the view. This is helpful to center the view's document correctly in the digit view
    ///
    /// - Parameter event: the touchesEnded event composed by the framework
    override func touchesEnded(with event: NSEvent) 
    {        
        //Swift.print("touches ended with \(event.allTouches())")
        
        scrollToDigit(_digit, animated: true)
        
        ////17.6.disableNotificationEchoOnDigitChange = false
    }
}
