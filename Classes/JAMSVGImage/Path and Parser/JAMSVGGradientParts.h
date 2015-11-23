/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JAMSVGGradientType) {
    JAMSVGGradientTypeUnknown = -1,
    JAMSVGGradientTypeLinear,
    JAMSVGGradientTypeRadial
};

/** The SVG Gradient object and its two subtypes */
@interface JAMSVGGradient : NSObject <NSCoding>
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *colorStops;
@property (nonatomic) NSValue *gradientTransform;

- (JAMSVGGradientType)gradientType;
- (void)drawInContext:(CGContextRef)context;

@end

@interface JAMSVGLinearGradient : JAMSVGGradient
@property CGPoint startPosition;
@property CGPoint endPosition;
@end

@interface JAMSVGRadialGradient : JAMSVGGradient
@property CGPoint position;
@property CGFloat radius;
@end

/** ColorStop wraps up a color and position. */
@interface JAMSVGGradientColorStop : NSObject <NSCoding>
- (id)initWithColor:(UIColor *)color position:(CGFloat)position;
@property (nonatomic) UIColor *color;
@property CGFloat position;
@end
