/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMStyledBezierPath.h"
#import "JAMSVGGradientParts.h"

@interface JAMStyledBezierPath ()
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) JAMSVGGradient *gradient;
@end

@implementation JAMStyledBezierPath


- (void)drawStyledPath;
{
    if (self.gradient) {
        [self fillWithGradient];
    } else if (self.fillColor) {
        [self.fillColor setFill];
        [self.path fill];
    }
    if (self.strokeColor && self.path.lineWidth > 0.f) {
        [self.strokeColor setStroke];
        [self.path stroke];
    }
}

- (void)fillWithGradient;
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = NSMutableArray.new;
    for (JAMSVGGradientColorStop *stop in self.gradient.colorStops) {
        [colors addObject:(id)stop.color.CGColor];
    }
    CGFloat locations[self.gradient.colorStops.count];
    for (int i = 0; i < self.gradient.colorStops.count; i++) {
        locations[i] = ((JAMSVGGradientColorStop *)self.gradient.colorStops[i]).position;
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFMutableArrayRef)colors, locations);
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [self.path addClip];
    
    if ([self.gradient isKindOfClass:JAMSVGRadialGradient.class]) {
        JAMSVGRadialGradient *radialGradient = (JAMSVGRadialGradient *)self.gradient;
        CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), gradient, radialGradient.position, 0.f, radialGradient.position, radialGradient.radius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    } else if ([self.gradient isKindOfClass:JAMSVGLinearGradient.class]) {
        JAMSVGLinearGradient *linearGradient = (JAMSVGLinearGradient *)self.gradient;
        CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, linearGradient.startPosition, linearGradient.endPosition, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    CGColorSpaceRelease(colorSpace);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"path: %@, fill: %@, stroke: %@, grad: %@", self.path, self.fillColor, self.strokeColor, self.gradient];
}

@end
