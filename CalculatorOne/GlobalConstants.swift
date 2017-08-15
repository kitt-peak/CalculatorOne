//
//  GlobalConstants.swift
//  CalculatorOne
//
//  Created by Andreas on 31/12/2016.
//  Copyright © 2016 Kitt Peak. All rights reserved.
//

import Cocoa

/// Represents a digit shown in a digit view. Range from d0 (0x0) to dF (0xF) and digits for the decimal point and the minus sign
/// The strip image in the view should show the digits in the same order: "." at the bottom of the view, followed by 0, 1, 2 etc going up (positive y)
enum Digit: Int
{
    case blank = -2, dot = -1
    case d0 = 0, d1 = 1, d2 = 2,  d3 = 3,  d4 = 4,  d5 = 5,  d6 = 6,  d7 = 7
    case d8 = 8, d9 = 9, dA = 10, dB = 11, dC = 12, dD = 13, dE = 14, dF = 15
    case minus = 16, plus = 17, inf = 18

    // number of cases and digits. 
    static var count: Int { return sortedDigits.count }
    
    static var sortedDigits: [Digit] = [.blank, .dot,
                                        .d0, .d1, .d2, .d3, .d4, .d5, .d6, .d7, 
                                        .d8, .d9, .dA, .dB, .dC, .dD, .dE, .dF,
                                        .minus,   .plus,    .inf]
    
    // computer drawn digit strip image: the are digits described as glyph codes in the font courier
    func glyphCode() -> UInt
    {        
        switch self 
        {
        case .blank:  return 1
        case .dot:    return 17
        case .d0:     return 19
        case .d1:     return 20
        case .d2:     return 21
        case .d3:     return 22
        case .d4:     return 23
        case .d5:     return 24
        case .d6:     return 25
        case .d7:     return 26
        case .d8:     return 27
        case .d9:     return 28
        case .dA:     return 36
        case .dB:     return 37
        case .dC:     return 38
        case .dD:     return 39
        case .dE:     return 40
        case .dF:     return 41
        case .minus:  return 16
        case .plus:   return 14
        case .inf:    return 1318
        }
    }
    
//    private let glyphCodes: [UInt] = 
//        [ 1/*   */, 17/* . */, 
//            19/* 0 */, 20/* 1 */, 21/* 2 */, 22/* 3 */, 23/* 4 */, 24/* 5 */, 25/* 6 */, 26/* 7 */, 
//            27/* 8 */, 28/* 9 */, 36/* A */, 37/* B */, 38/* C */, 39/* D */, 40/* E */, 41/* F */,
//            16/* - */, 14/* + */, 1318 /* ∞ */]

}

class GlobalConstants
{
    // make this a singleton
    static let shared: GlobalConstants = GlobalConstants()

    private init() 
    { 
        digitStrip = DigitStrip()
        digitStrip.setImageForKind(digitKind)
    }
    
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
    
    let digitSize              = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view
    
    // specifies the number of digits the digit image strip holds (0 to F, ".", "-"). This variable must match the 
    // number of glyph codes in the computer drawn strip image and also match the number of digits in the asset image
    // "Courier19DigitStrip"
    // var countDigitsInImageStrip: Int { return Digit.count/*glyphCodes.count*/ }
    
    var digitStrip: DigitStrip!
    
    struct DigitStrip
    {
        // MARK: Digit parameters.
        let imageSizeInPoints = CGSize(width: 20.0, height: 28.0)      // corresponds to the size of a digit view

        var image: NSImage!
        
        var indexOfDigitZeroInImageStrip: Int = 2

        
        // specifies the number of digits the digit image strip holds (0 to F, ".", "-"). This variable must match the 
        // number of glyph codes in the computer drawn strip image and also match the number of digits in the asset image
        // "Courier19DigitStrip"
        var countDigits: Int { return Digit.count/*glyphCodes.count*/ }
        
        mutating func setImageForKind(_ kind: DigitView.Kind)
        {
            switch kind 
            {
            case .courierStyleMetallic: image = NSImage(named: "Courier19DigitStrip")
            case .undefined:            image = NSImage(named: "Courier19DigitStrip")
            case .courierStyleWithColor(let color): 
                if image == nil
                {
                    image = computedDigitStripImageWithColor(color)   
                }
            }

            guard image != nil else { abort() }
        }
    
        private func computedDigitStripImageWithColor(_ color: NSColor) -> NSImage
        {
            // create image to draw a strip of digits into. This strip image has the size of one digit image,
            // multiplied by the number of digits so that it forms a vertical band 
            let size = CGSize(width: imageSizeInPoints.width, height: imageSizeInPoints.height * CGFloat(countDigits))
            
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
            let font = NSFont(name: "Courier", size: imageSizeInPoints.height)
            
            // iterate over all digits (by glyph code for each digit) and add their bezierpaths into the drawing
            //for digitIndex: Int in 0 ..< Digit.count/*glyphCodes.count*/
            for (digitIndex, digit) in Digit.sortedDigits.enumerated()
            {
                /* x = 2.0 is an offset to center the digit horizontally */
                /* y = 9.0 is an offset to center the digit vertically */            
                let digitStart = NSPoint(x: 2.0, y: 9.0 + CGFloat(digitIndex) * imageSizeInPoints.height)
                digitsPath.move(to: digitStart)
                
                digitsPath.appendGlyph(NSGlyph(digit.glyphCode()/*glyphCodes[digitIndex]*/), in: font!)
            }
            
            digitsPath.fill()
            //digitsPath.stroke()
            
            // finish drawing by unlocking the focus        
            digitStripImage.unlockFocus()
            
            return digitStripImage
        }
    
    }
}


enum GlobalNotification: String
{
    case newEngineResult     = "newEngineResult"
    case newKeypadEntry      = "newKeypadEntry"
    case newOperandType      = "newOperandType"
    case newError            = "newError"

    var name: Notification.Name { return Notification.Name(self.rawValue) }
}

enum GlobalKey: String
{
    case numbericString = "numericString"
    
    var name: String { return self.rawValue }
}

enum Symbols: String
{
    case plus    = "+",         minus = "−",            multiply  = "×",        divide     = "÷"
    case moduloN = "%",         and   = "&",            or        = "||",       xor        = "⊕"
    case nShiftLeft = "N ≪",    nShiftRight = "N ≫",    shiftLeft = "≪",       shiftRight  = "≫"
    case gcd = "gcd",           lcm = "lcm"
    case increment = "1 +",     decrement = "1 -"
    
    case sum = "∑",             nSum = "n ∑"
    
    case swap = "2↑↓",          rotateUp  = "3R↑",        rotateDown = "3R↓"
    case drop = "drop",         dropAll   = "䷀ drop",     nDrop      = "n drop"
    case dup  = "dup",          dup2      = "dup2",       depth      = "depth"
    case avg  = "∅",            product   = "∏",          geoMean    = "∏ ᴺ√"
    case nAvg = "n ∅",          nProduct  = "N ∏",        nGeoMean   = "n ∏ ᴺ√"
    case nPick = "n pick",      over      = "over"
    
    case factorial = "n!",      primes    = "PF"
    case yExpX     = "Yˣ",      logYX     = "logY x"
    case eExpX     = "eˣ",      tenExpX   = "10ˣ",         twoExpX    = "2ˣ"
    case logE      = "ln",      log10     = "log",         log2       = "lb"
    case root      = "√",       thridRoot = "∛",           nRoot      = "ᴺ√"
    case square    = "x²",      cubic     = "x³"
    case reciprocal = "⅟x",     reciprocalSquare = "⅟x²"
    
    case sinus  = "sin",        cosinus   = "cos",          tangens   = "tan",      cotangens = "cot"
    case asinus = "asin",       acosinus  = "acos",         atangens  = "atan",     acotangens = "acot"
    
    case conv22bB = "2→dB"
    case sigma     = "σ",       nSigma    = "n σ"
    case variance  = "var",     nVariance = "n var"
    
    case deg2rad = "→ rad",     rad2deg = "→ deg"
    
    case π = "π", e = "e"
    case epsilon0 = "ε₀", µ0 = "μ₀", c0 = "c₀",  e0 = "e₀", G = "G", g = "g", h = "h", k = "k"
    
    case copyStackToA = "䷀ → A", copyStackToB = "䷀ → B", copyAToStack = "䷀ ← A", copyBToStack = "䷀ ← B" 
    
    case invertSign = "±",      invertBits = "~"
    case random = "rnd"
    
    case const7M68 = "7m68",        const30M72 = "30m72",       const122M88 = "122m88"
    case const153M6 = "153m6",      const245M76 = "245m76",     const368M64 = "368m64"
    case const1966M08 = "1966m08",  const2457M6 = "2457m6",     const2949M12 = "2949m12"
    case const3072M0  = "3072m0",   const3868M4 = "3686m4"
    case const3932M16 = "3932m16",  const4915M2 = "4915m2",     const5898M24 = "5898m24"
    case const25M0 = "25m0",        const100M0 = "100m0",       const125M0 = "125m0"
    case const156M25 = "156m25"
    
    case multiply66divide64 = "66 × 64 ÷",                      multiply64divide66 = "64 × 66 ÷"
    case undo = "↩︎",  redo = "↪︎"

    case posExp = "+exp",           negExp = "-exp"
    case enter  = "enter"
    
    case rect2polar = "2 c→p",      polar2rect = "2 p→c"
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
 

 "+⇔-" : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(-a)]  }),
 "~" : .integerUnary2array( { (a: Int)  -> [Operand] in return [.integer(~a)]  }),
 
 "X²" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a*a)]   }),
 "2ˣ" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(Engine.twoExpN(of: a))] }),
 "1 +" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a + 1)] }),
 "1 -" : .integerUnary2array( { (a: Int)  -> [Operand] in return  [.integer(a - 1)] }),
 
 "∑" : .integerArray2array( { (s: [Int]) -> [Operand] in return [.integer( s.reduce(0) { (x, y) -> Int in return x + y })]}),
 
 "N!" : .integerUnary2array( { (a: Int)   -> [Operand] in return [.integer(Engine.factorial(of: a) )] })

 
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
