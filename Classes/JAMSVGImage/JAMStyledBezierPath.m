/*
 
 Copyright (c) 2013 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMStyledBezierPath.h"

@interface JAMStyledBezierPath ()
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@end

@implementation JAMStyledBezierPath

+ (JAMStyledBezierPath *)styledPathWithBezierPath:(UIBezierPath *)bezierPath
                                        fillColor:(UIColor *)fillColor
                                      strokeColor:(UIColor *)strokeColor
                                     strokeWeight:(CGFloat)strokeWeight
                                        dashArray:(NSArray *)dashArray
                                       miterLimit:(CGFloat)miterLimit
                                     lineCapStyle:(CGLineCap)lineCapStyle
                                    lineJoinStyle:(CGLineJoin)lineJoinStyle;
{
    JAMStyledBezierPath *styledBezierPath = JAMStyledBezierPath.new;
    styledBezierPath.fillColor = fillColor;
    styledBezierPath.strokeColor = strokeColor;
    
    styledBezierPath.path = bezierPath;
    styledBezierPath.path.lineWidth = strokeWeight;
    styledBezierPath.path.miterLimit = miterLimit;
    styledBezierPath.path.lineJoinStyle = lineJoinStyle;
    styledBezierPath.path.lineCapStyle = lineCapStyle;
    if (dashArray) {
        CGFloat values[dashArray.count];
        for (int i = 0; i < dashArray.count; i++) {
            values[i] = [dashArray[i] floatValue];
        }
        [styledBezierPath.path setLineDash:values count:dashArray.count phase:0.f];
    }
    return styledBezierPath;
}

- (void)drawStyledPath;
{
    if (self.fillColor) {
        [self.fillColor setFill];
        [self.path fill];
    }
    if (self.strokeColor && self.path.lineWidth > 0.f) {
        [self.strokeColor setStroke];
        [self.path stroke];
    }
}

@end
