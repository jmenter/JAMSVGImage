/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

@class JAMSVGGradient;

/** The JAMStyledBezierPath class encapsulates a UIBezierPath object and styling information (fill, stroke, gradient, affine transforms, and opacity.) */
@interface JAMStyledBezierPath : NSObject <NSCoding>

/** Styled path creation */
+ (instancetype)styledPathWithPath:(UIBezierPath *)path
                         fillColor:(UIColor *)fillColor
                       strokeColor:(UIColor *)strokeColor
                          gradient:(JAMSVGGradient *)gradient
                  affineTransforms:(NSArray *)transforms
                           opacity:(NSNumber *)opacity;

/** Draws the styled path in the current graphics context. */
- (void)drawStyledPathInContext:(CGContextRef)context;

/** Returns a Boolean value indicating whether the area enclosed by the path contains the specified point. */
- (BOOL)containsPoint:(CGPoint)point;

@end
