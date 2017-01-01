//
//  DigitView.swift
//  CalculatorOne
//
//  Created by Andreas on 28/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

/// Displays a single digit (0 to F and failure) in a vertical scroll view, allows the user to change the digit by scrolling
class SixteenDigitsView: BaseView
{
    private var digitViews: [DigitView]!

    static let countViews: Int = 16
    let xDigitSpacing: CGFloat = 1.0
    static let constantSize: CGSize = CGSize(width:  16 * (DigitView.constantSize.width + 1.0), 
                                             height:      DigitView.constantSize.height)
    

    
    // represents the digit shown in the view
    var value: Int = 0
    { didSet 
        { 
            updateViews(value: value)
        }
    }
    
    var radix: Int = 10
    { didSet 
        { 
            updateViews(value: value)
        }
    }
            
    var digitValue: Int? { return nil }
    
    convenience init(kind: DigitView.Kind, origin: CGPoint)
    {
        self.init(frame: NSRect(origin: origin, size: CGSize.zero))
    }
    
    private override init(frame frameRect: NSRect)
    {
        let newFrame: CGRect = CGRect(origin: frameRect.origin, size: SixteenDigitsView.constantSize)
        super.init(frame: newFrame)
        
        completeInitWithRect(frameRect: newFrame)
    }
    
    required init?(coder: NSCoder)
    {
        let frameRect = CGRect.zero
        let newFrame: CGRect = CGRect(origin: frameRect.origin, size: DigitView.constantSize)
        super.init(coder: coder)
        
        completeInitWithRect(frameRect: newFrame)
    }
    
    private func completeInitWithRect(frameRect: NSRect, kind: DigitView.Kind = DigitView.Kind.hexAndFailureTypeWriterFont)
    {

        wantsLayer = true
        layer?.backgroundColor = CGColor.clear
        
        digitViews = [DigitView]()
        
        for viewIndex: Int in 0 ..< SixteenDigitsView.countViews
        {
            let origin: CGPoint = CGPoint(x: CGFloat(SixteenDigitsView.countViews - viewIndex - 1) * (DigitView.constantSize.width + xDigitSpacing), 
                                          y: 0.0)
            let digitView = DigitView(kind: kind, origin: origin)
            
            digitViews.append(digitView)
    
            self.addSubview(digitView)
        }        
    }
    
    
    
//    override func draw(_ dirtyRect: NSRect) 
//    {
//        super.draw(dirtyRect)
//
//        // Drawing code here.        
//    }  
    
    func resetToZero()
    {
        value = 0
    }
    
    func updateViews(value: Int) 
    {
        var digitValue: Int = value
        for i: Int in 0 ..< SixteenDigitsView.countViews
        {
            self.setDigit(value: digitValue % radix, index: i, animated: true)
            digitValue = digitValue / radix
        }
    }
    
    private func scrollToDigit(_ digit: Digit, animated: Bool)
    {
        
    }
    
    func setDigit(_ digit: Digit, index: Int, animated: Bool)
    {
        digitViews[index].setDigit(digit, animated: animated)
    }
    
    func setDigit(value: Int, index: Int, animated: Bool)
    {
        digitViews[index].setDigit(value: value, animated: animated)
    }
    
}
