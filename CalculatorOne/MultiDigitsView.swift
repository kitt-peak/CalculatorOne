//
//  MultiDigitView.swift
//  CalculatorOne
//
//  Created by Andreas on 28/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

protocol MultiDigitViewDelegate
{
    //func userEventShouldSetValue(_ value: Int) -> Bool
    func userWillChangeDigitWithIndex(_ index: Int, toDigitValue: Int) -> Bool
}

/// Displays multiple digits (0 to F, point, minus) in a vertical scroll view, allows the user to change the digit by scrolling
class MultiDigitsView: BaseView, DigitViewDelegate
{
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    private var digitViews: [DigitView]!

    // Appearance
    @IBInspectable var countViews: Int = 20
    //private let kind: = DigitView.Kind.courierStyleMetallic
    private let kind = GlobalConstants.shared.digitKind
    
    private let xDigitSpacing: CGFloat = 1.0
    var constantSize: CGSize   = CGSize(width: 0, height: 0)
    
    var delegate: MultiDigitViewDelegate?
    
    var acceptsValueChangesByUI: Bool = false
    
    // represents the digit shown in the view
    var value: [Digit] = [Digit]()
    { didSet 
        { 
            updateViews(digits: value)
        }
    }
    
    
    var radix: Int = 10
    { didSet 
        { 
            configureViewForRadix(radix)
            updateViews(digits: value)
        }
    }
            
    
    convenience init(countDigits: Int, kind: DigitView.Kind, origin: CGPoint)
    {
        
        self.init(frame: NSRect(origin: origin, size: CGSize.zero))
        
        countViews = countDigits
    }
    
    private override init(frame frameRect: NSRect)
    {
        let newFrame: CGRect = CGRect(origin: frameRect.origin, size: constantSize)
        super.init(frame: newFrame)
        
        completeInitWithRect(frameRect: newFrame, kind: kind)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)        
    }
    
    override func awakeFromNib() 
    {
        super.awakeFromNib()
        
        constantSize.width = CGFloat(countViews) * (xDigitSpacing + DigitView.constantSize.width)
        constantSize.height = DigitView.constantSize.height
        
        widthConstraint.constant = constantSize.width

        let newFrame: CGRect = CGRect(origin: self.frame.origin, size: DigitView.constantSize)

        completeInitWithRect(frameRect: newFrame, kind: kind)
    }
    
    private func completeInitWithRect(frameRect: NSRect, kind: DigitView.Kind)
    {
        constantSize.width = CGFloat(countViews) * (xDigitSpacing + DigitView.constantSize.width)
        constantSize.height = DigitView.constantSize.height

        wantsLayer = true
        layer?.backgroundColor = CGColor.clear
        
        digitViews = [DigitView]()
        
        for viewIndex: Int in 0 ..< countViews
        {
            let origin: CGPoint = CGPoint(x: CGFloat(countViews - viewIndex - 1) * (DigitView.constantSize.width + xDigitSpacing), 
                                          y: 0.0)
            let digitView = DigitView(kind: kind, origin: origin)
        
            // allow the digit view to delegate events up to this class
            digitView.delegate = self
            
            digitViews.append(digitView)
    
            self.addSubview(digitView)
        }  
    }
    
    func configureViewForRadix(_ radix: Int)
    {
        for digitView in digitViews
        {
            digitView.configureForRadix(radix)
        }
        
    }
    
    func updateViews(digits: [Digit]) 
    {
        if digits.count == 0
        {
            // blank all digits
            for digitView in digitViews
            {
                digitView.setDigit(.blank, animated: true)
            }
            
            return 
        }
        
        // insert the value into the individual digits from right to left
        var index: Int = 0

        for _ in digitViews
        {
            if index < digits.count
            {
                setDigit(digits[index], index: index, animated: true)                
            }
            else
            {
                setDigit(.blank, index: index, animated: true)
            }
            
            index += 1
        }
    }
    
    func setDigit(_ digit: Digit, index: Int, animated: Bool)
    {
        digitViews[index].setDigit(digit, animated: animated)
    }
    
    func setDigit(value: Int, index: Int, animated: Bool)
    {
        digitViews[index].setDigit(value: value, animated: animated)
    }
    
    
    func userScrollEventWillChangeDigit(_ digit: Digit, fromView: DigitView) -> Bool 
    {
        guard acceptsValueChangesByUI == true else { return false }
        
        // the user tries to tweak one digit by scrolling in a multi-digit view. 
        // the index of that digit is: tweakedDigitIndex
        if let tweakedDigitIndex: Int = digitViews.index(of: fromView)
        {
            // ask the controller if a digit tweak is permissible
            return delegate?.userWillChangeDigitWithIndex(tweakedDigitIndex, toDigitValue: digit.rawValue) ?? false
        }
        else
        {
            assertionFailure("! Failure: digit view \(fromView) was not found in the digitview array of \(self)")
        }
        
        return false
    }

}
