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

    var digitKind = DigitView.Kind.courierStyleWithColor(NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.2, alpha: 1.0))
    var digitViewBackgroundColor = NSColor(calibratedRed: 0.0, green: 0.1, blue: 0.0, alpha: 1.0)
    
    // MARK: Digit parameters.
    let digitImageSizeInPoints = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view
    let digitSize              = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view
    
    // specifies the number of digits the digit image strip holds (0 to F, ".", "-"). This variable must match the 
    // number of glyph codes in the computer drawn strip image and also match the number of digits in the asset image
    // "Courier19DigitStrip"
    let countDigitsInImageStrip: Int = 19                               
    
    var digitStripImage: NSImage!
    
    // computer drawn digit strip image: the are digits described as glyph codes in the font courier
    private let glyphCodes: [UInt] = 
        [ 1/*   */, 17/* . */, 
         19/* 0 */, 20/* 1 */, 21/* 2 */, 22/* 3 */, 23/* 4 */, 24/* 5 */, 25/* 6 */, 26/* 7 */, 
         27/* 8 */, 28/* 9 */, 36/* A */, 37/* B */, 38/* C */, 39/* D */, 40/* E */, 41/* F */,
         16/* - */]
    
    func digitStripImageForKind(_ kind: DigitView.Kind) -> NSImage
    {
        var image: NSImage!
        switch kind 
        {
        case .courierStyleMetallic: image = NSImage(named: "Courier19DigitStrip")
        case .undefined:            image = NSImage(named: "Courier19DigitStrip")
        case .courierStyleWithColor(let color): 
            if digitStripImage == nil
            {
                digitStripImage = computedDigitStripImageWithColor(color)   
            }
            
            image = digitStripImage
        }
        
        guard image != nil else { abort() }
        
        return image!
    }
    
    private func computedDigitStripImageWithColor(_ color: NSColor) -> NSImage
    {
        // create image to draw a strip of digits into. This strip image has the size of one digit image,
        // multiplied by the number of digits so that it forms a vertical band 
        let size = CGSize(width: digitImageSizeInPoints.width, height: digitImageSizeInPoints.height * CGFloat(countDigitsInImageStrip))

        let digitStripImage = NSImage(size: size)

        // start drawing by locking to draw focus to it.
        digitStripImage.lockFocus()
        
        // make a transparent background
        NSColor.clear.setFill()
        NSRectFill(NSRect(origin: NSPoint.zero, size: size))
        
        // the digits drawn shape and body in this color. 
        // NSColor.green.setStroke()
        color.setFill()
        
        // our strokes are landing in this path
        let digitsPath: NSBezierPath = NSBezierPath()
        
        // setting the font for the digits
        let font = NSFont(name: "Courier", size: digitImageSizeInPoints.height)
        
        // our digits descriped as glyph codes in the font courier
        /*
        let glyphCodes: [UInt] = [1/*   */, 17/* . */, 
                                  19/* 0 */, 20/* 1 */, 21/* 2 */, 22/* 3 */, 23/* 4 */, 24/* 5 */, 25/* 6 */, 26/* 7 */, 
         ∝                        27/* 8 */, 28/* 9 */, 36/* A */, 37/* B */, 38/* C */, 39/* D */, 40/* E */, 41/* F */,
                                  16/* - */]
        */
        // iterate over all digits (by glyph code for each digit) and add their bezierpaths into the drawing
        for digitIndex: Int in 0 ..< glyphCodes.count
        {
            /* x = 2.0 is an offset to center the digit horizontally */
            /* y = 9.0 is an offset to center the digit vertically */            
            let digitStart = NSPoint(x: 2.0, y: 9.0 + CGFloat(digitIndex) * digitImageSizeInPoints.height)
            digitsPath.move(to: digitStart)
            
            digitsPath.appendGlyph(NSGlyph(glyphCodes[digitIndex]), in: font!)
        }

        digitsPath.fill()
        //digitsPath.stroke()
                
        // finish drawing by unlocking the focus        
        digitStripImage.unlockFocus()
        
        return digitStripImage
    }
    
}


enum GlobalNotification: String
{
    case newEngineResult = "newEngineResult"
    case newKeypadEntry  = "newKeypadEntry"
    
    var notificationName: Notification.Name { return Notification.Name(self.rawValue) }
}

enum Symbols: String
{
    case plus    = "+",         minus = "−",            multiply  = "×",        divide     = "÷"
    case moduloN = "%",         and   = "&",            or        = "||",       xor        = "⊕"
    case nShiftLeft = "N ≪",    nShiftRight = "N ≫",    shiftLeft = "≪",       shiftRight  = "≫"
    case gcd = "gcd",           lcm = "lcm"
    
    case swap = "2↑↓",          rotateUp = "3R↑",        rotateDown = "3R↓"
    case drop = "Drop",         dropAll  = "Drop All"
    case dup  = "dup",          dup2     = "dup2",       depth = "depth"
    
    case factorial = "n!"
    
    case π = "π", e = "e"
    case epsilon0 = "ε₀", µ0 = "μ₀", c0 = "c₀",  e0 = "e₀", G = "G", g = "g", h = "h", k = "k"
    //case Λ = "Λ", k0 = "k₀"
}

/*
 
 Boltzmannsche Konstante kB
 1.380658·10-23 J/K        ( = 8.617385·10-5 eV/K )
 
 Elementarladung e
 1.60217733·10-19 C
 
 Avogadrosche Zahl NA
 6.0221367·1023 Teilchen/mol
 

 Feinstrukturkonstante .alpha.
 1 / 137.0359895
 
 Gaskonstante R
 R = NA kB
 8.31451 m2·kg/s2·K·mol
 
 Molvolumen Vmol
 22.41383 m3/kmol
 
 Faradaysche Konstante F
 F = NA e
 9.64846·104 C/mol
 
 g-Faktor des Protons (Landé-Faktor) gH
 5.585
 
 Gravitationskonstante G
 (6.673 +- 0.010)·10-11 m3/kg·s2 (CODATA)
 6.67390·10-11 m3/kg·s2 +- 0.0014 % (Jens Gundlach, Univ. of Washington; aus: Der Tagesspiegel 2000-05-08)
 (6.6873 +- 0.0094)·10-11 m3/kg·s2 (Schwarz et al., Science 282, 2230 (1998))
 
 Erdbeschleunigung g
 9.80665 m/s2
 
 Compton-Wellenlänge des Elektrons .lambda.c
 .lambda.c = h / (me c)
 2.42631·10-12 m
 
 Weitere Nützliche Konstanten
 atomare Energieeinheit Hartree
 1 Hartree = e2 / (4 .pi. .epsilon.0 a0)
 1 Hartree = 2.625501·106 J/mol (ca. 627.5 kcal/mol)
 
 Nützliche Umrechnungsfaktoren
 NMR (Kernmagnetische Resonanz)
 Protonen-Larmor-Frequenz
 .nu.p = .gamma.p / (2 .pi.) B
 .nu.p = 42.5764 MHz/T (H2O) 
 
 
 
 */
/*
 

 "+⇔-" : .integerUnary2array( { (a: Int)   -> [OperandValue] in return [.integer(-a)]  }),
 "~" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return [.integer(~a)]  }),
 
 "X²" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a*a)]   }),
 "2ˣ" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(Engine.twoExpN(of: a))] }),
 "1 +" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a + 1)] }),
 "1 -" : .integerUnary2array( { (a: Int)  -> [OperandValue] in return  [.integer(a - 1)] }),
 
 "∑" : .integerArray2array( { (s: [Int]) -> [OperandValue] in return [.integer( s.reduce(0) { (x, y) -> Int in return x + y })]}),
 
 "N!" : .integerUnary2array( { (a: Int)   -> [OperandValue] in return [.integer(Engine.factorial(of: a) )] })

 
 */


/*
 // draws an image used as content image for the digit views
 // the image consists of a number of bands. Each band prints
 // the digits (empty), 1, 2, ... 9 in a given font
 - (NSImage*)drawMultiDigitImage
 {
 int bands = [self fontLines];  // number of bands
 NSSize imageSize = NSMakeSize([self widthOfDigitImage], (float)bands * [self sizeOfDigitView]);
 
 // create an image to draw several bands of digits on it.
 // horizontal dimension: number of digits (10) times size of a digit
 // vertical dimension: number of digit bands (fonts) times size of a digit
 multiFontBandDigitImage = [[NSImage alloc] initWithSize: imageSize];
 
 [multiFontBandDigitImage lockFocus];
 
 NSRect r; r.origin = NSMakePoint(0.0, 0.0); r.size = imageSize;
 
 [[NSColor clearColor] setFill];
 NSRectFill(r);
 
 [[NSColor blackColor] setFill];
 
 float fontSize = digitFontSize;
 float glyphWidth = [self sizeOfDigitView];
 float glyphHeight = glyphWidth;
 
 // create a font for each band
 NSMutableArray* fonts = [[NSMutableArray alloc] initWithCapacity: bands];
 
 // array of glyph codes for the digit "1". The index of this array corresponds with the
 // index of the font array.
 NSArray* glyphCodesForGlyphOne = @[@(25), @(24), @(20), @(21),   /*@"American Typewriter", @"Snell Roundhand Black", @"Synchro LET", @"Chalkduster"*/
 @(25), @(20), @(25), @(20),   /*@"HeadLineA", @"Helvetica", @"Herculanum", @"Impact",*/
 @(17), @(25), @(20), @(17),   /*@"Jazz LET", @"Marker Felt", @"Mona Lisa Solid ITC TT", @"Party LET"*/
 @(20), @(20), /*@(560),*/ @(14),   /*@"PortagoITC TT", @"Princetown LET", @"Source Code Pro", @"Type Embellishments"*/
 @(25), @(20), @(20), @(53)];  /*@"Wingdings", @"Stone Sans ITC TT", @"Apple Braille", @"Zapf Dingbats"*/
 
 NSBezierPath* digitGlyphPath = [NSBezierPath bezierPath];
 
 // iterate over all bands (fonts)
 for (int band = 0;  band < bands; band++)
 {
 [fonts addObject: [NSFont fontWithName: namesOfDigitFonts[band] size: fontSize]];
 
 // iterate over all digits (by glyph code for each digit)
 for (int glyphCode = 0 ; glyphCode < 10 ; glyphCode++)
 {
 [digitGlyphPath moveToPoint: NSMakePoint((glyphCode+1)*glyphWidth+6.0, band*glyphHeight + 6.0)];
 [digitGlyphPath appendBezierPathWithGlyph: [glyphCodesForGlyphOne[band] intValue] + glyphCode inFont: fonts[band]];
 }
 }
 
 [digitGlyphPath fill];
 
 
 [multiFontBandDigitImage unlockFocus];
 
 
 return multiFontBandDigitImage;
 }

 */
