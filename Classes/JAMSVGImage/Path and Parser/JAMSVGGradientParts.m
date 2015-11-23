/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGGradientParts.h"

@implementation JAMSVGGradient

#pragma mark - NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super init])) { return nil; }
    
    self.identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
    self.colorStops = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(colorStops))];
    self.gradientTransform = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(gradientTransform))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.colorStops forKey:NSStringFromSelector(@selector(colorStops))];
    [aCoder encodeObject:self.gradientTransform forKey:NSStringFromSelector(@selector(gradientTransform))];
}

#pragma mark - Initializers

- (id)init;
{
    if (!(self = [super init])) return nil;
    
    self.colorStops = NSMutableArray.new;
    return self;
}

- (JAMSVGGradientType)gradientType;
{
    if ([self isKindOfClass:JAMSVGLinearGradient.class]) {
        return JAMSVGGradientTypeLinear;
    }
    if ([self isKindOfClass:JAMSVGRadialGradient.class]) {
        return JAMSVGGradientTypeRadial;
    }
    return JAMSVGGradientTypeUnknown;
}

- (void)drawInContext:(CGContextRef)context
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = NSMutableArray.new;
    CGFloat locations[self.colorStops.count];
    for (JAMSVGGradientColorStop *stop in self.colorStops) {
        [colors addObject:(id)stop.color.CGColor];
        CGFloat location = ((JAMSVGGradientColorStop *)self.colorStops[[self.colorStops indexOfObject:stop]]).position;
        locations[[self.colorStops indexOfObject:stop]] = location;
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFMutableArrayRef)colors, locations);
    
    if (self.gradientTransform) {
        CGContextConcatCTM(context, self.gradientTransform.CGAffineTransformValue);
    }
    
    if (self.gradientType == JAMSVGGradientTypeRadial) {
        JAMSVGRadialGradient *radialGradient = (JAMSVGRadialGradient *)self;
        CGContextDrawRadialGradient(context, gradient, radialGradient.position, 0.f, radialGradient.position, radialGradient.radius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    } else if (self.gradientType == JAMSVGGradientTypeLinear) {
        JAMSVGLinearGradient *linearGradient = (JAMSVGLinearGradient *)self;
        CGContextDrawLinearGradient(context, gradient, linearGradient.startPosition, linearGradient.endPosition, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

@end

@implementation JAMSVGLinearGradient
@end

@implementation JAMSVGRadialGradient
@end

@implementation JAMSVGGradientColorStop

#pragma mark - NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super init])) { return nil; }
    
    self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
    self.position = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(position))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
    [aCoder encodeFloat:self.position forKey:NSStringFromSelector(@selector(position))];
}


- (id)initWithColor:(UIColor *)color position:(CGFloat)position;
{
    if (!(self = [super init])) return nil;
    
    self.color = color;
    self.position = position;
    return self;
}

@end
