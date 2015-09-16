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
@property (nonatomic) NSArray *affineTransforms;
@property (nonatomic) NSNumber *opacity;
@end

@implementation JAMStyledBezierPath


#pragma mark - NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super init])) { return nil; }
    
    self.path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))];
    self.fillColor = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fillColor))];
    self.strokeColor = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(strokeColor))];
    self.gradient = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(gradient))];
    self.affineTransforms = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(affineTransforms))];
    self.opacity = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(opacity))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.path forKey:NSStringFromSelector(@selector(path))];
    [aCoder encodeObject:self.fillColor forKey:NSStringFromSelector(@selector(fillColor))];
    [aCoder encodeObject:self.strokeColor forKey:NSStringFromSelector(@selector(strokeColor))];
    [aCoder encodeObject:self.gradient forKey:NSStringFromSelector(@selector(gradient))];
    [aCoder encodeObject:self.affineTransforms forKey:NSStringFromSelector(@selector(affineTransforms))];
    [aCoder encodeObject:self.opacity forKey:NSStringFromSelector(@selector(opacity))];
}

#pragma mark - Initializers

+ (instancetype)styledPathWithPath:(UIBezierPath *)path
                         fillColor:(UIColor *)fillColor
                       strokeColor:(UIColor *)strokeColor
                          gradient:(JAMSVGGradient *)gradient
                  affineTransforms:(NSArray *)transforms
                           opacity:(NSNumber *)opacity;
{
    JAMStyledBezierPath *styledPath = JAMStyledBezierPath.new;
    
    styledPath.path = path;
    styledPath.fillColor = fillColor;
    styledPath.strokeColor = strokeColor;
    styledPath.gradient = gradient;
    styledPath.affineTransforms = transforms;
    styledPath.opacity = opacity;
    
    return styledPath;
}

- (void)drawStyledPathInContext:(CGContextRef)context
{
    if (!context) return;

    CGContextSaveGState(context);
    for (NSValue *transform in self.affineTransforms) {
        CGContextConcatCTM(context, transform.CGAffineTransformValue);
    }
    if (self.opacity) {
        CGContextSetAlpha(context, self.opacity.floatValue);
    }
    if (self.gradient) {
        CGContextAddPath(context, self.path.CGPath);
        CGContextClip(context);
        [self.gradient drawInContext:context];
        CGContextRestoreGState(context);
    } else if (self.fillColor) {
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
        CGContextAddPath(context, self.path.CGPath);
        CGContextFillPath(context);
    }
    if (self.strokeColor && self.path.lineWidth > 0.f) {
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
        CGContextAddPath(context, self.path.CGPath);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

- (BOOL)containsPoint:(CGPoint)point;
{
    return [self.path containsPoint:point];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"    styledPath:%p\n    path: %@\n    fill: %@\n    stroke: %@\n    gradient: %@\n    transform: %@\n    opacity: %@", self, self.path, self.fillColor, self.strokeColor, self.gradient, self.affineTransforms, self.opacity];
}

@end
