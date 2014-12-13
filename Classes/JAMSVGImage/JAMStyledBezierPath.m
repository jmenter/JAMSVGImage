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
@property (nonatomic) NSArray *transforms;
@property (nonatomic) NSNumber *opacity;
@end

@implementation JAMStyledBezierPath

+ (instancetype)styledPathWithPath:(UIBezierPath *)path
                         fillColor:(UIColor *)fillColor
                       strokeColor:(UIColor *)strokeColor
                          gradient:(JAMSVGGradient *)gradient
                        transforms:(NSArray *)transforms
                           opacity:(NSNumber *)opacity;
{
    JAMStyledBezierPath *styledPath = JAMStyledBezierPath.new;
    
    styledPath.path = path;
    styledPath.fillColor = fillColor;
    styledPath.strokeColor = strokeColor;
    styledPath.gradient = gradient;
    styledPath.transforms = transforms;
    styledPath.opacity = opacity;
    
    return styledPath;
}

- (void)drawStyledPath;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;

    CGContextSaveGState(context);
    for (NSValue *transform in self.transforms) {
        CGContextConcatCTM(context, transform.CGAffineTransformValue);
    }
    if (self.opacity) {
        CGContextSetAlpha(context, self.opacity.floatValue);
    }
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
    CGContextRestoreGState(context);
}

- (void)fillWithGradient;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = NSMutableArray.new;
    CGFloat locations[self.gradient.colorStops.count];
    for (JAMSVGGradientColorStop *stop in self.gradient.colorStops) {
        [colors addObject:(id)stop.color.CGColor];
        CGFloat location = ((JAMSVGGradientColorStop *)self.gradient.colorStops[[self.gradient.colorStops indexOfObject:stop]]).position;
        locations[[self.gradient.colorStops indexOfObject:stop]] = location;
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFMutableArrayRef)colors, locations);
    
    CGContextSaveGState(context);
    [self.path addClip];
    
    if (self.gradient.gradientTransform) {
        CGContextConcatCTM(context, self.gradient.gradientTransform.CGAffineTransformValue);
    }

    if (self.gradient.gradientType == JAMSVGGradientTypeRadial) {
        JAMSVGRadialGradient *radialGradient = (JAMSVGRadialGradient *)self.gradient;
        CGContextDrawRadialGradient(context, gradient, radialGradient.position, 0.f, radialGradient.position, radialGradient.radius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    } else if (self.gradient.gradientType == JAMSVGGradientTypeLinear) {
        JAMSVGLinearGradient *linearGradient = (JAMSVGLinearGradient *)self.gradient;
        CGContextDrawLinearGradient(context, gradient, linearGradient.startPosition, linearGradient.endPosition, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"path: %@, fill: %@, stroke: %@, gradient: %@, transform: %@, opacity: %@", self.path, self.fillColor, self.strokeColor, self.gradient, self.transforms, self.opacity];
}

@end
