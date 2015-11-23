/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

/** JAMSVGImage class is used for drawing resolution-independent vector graphics from an SVG file or data. Use JAMSVGImage to draw in any graphics context (most likely your custom view's drawRect: method) or, use it to populate a JAMSVGImageView and enjoy resolution-independent graphics at any size anywhere in your app! */
@interface JAMSVGImage : NSObject <NSCoding>

/** Size of the SVG image, in points. This reflects the size of the 'viewBox' element of the SVG document. */
@property (nonatomic, readonly) CGSize size;

/** Scale at which the SVG image will be drawn. Default is 1.0. */
@property (nonatomic) CGFloat scale;

/** Returns a CGImageRef or UIImage of the SVG image at the current scale. */
- (CGImageRef)CGImage;
- (UIImage *)image;

/** Initializes a new SVG image from a file or data source. */
+ (JAMSVGImage *)imageNamed:(NSString *)name;
+ (JAMSVGImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (JAMSVGImage *)imageWithContentsOfFile:(NSString *)path;
+ (JAMSVGImage *)imageWithSVGData:(NSData *)svgData;

/** Draws the SVG image either in the context, or at a specific point, or in a specific rect. */
- (void)drawInContext:(CGContextRef)context;
- (void)drawAtPoint:(CGPoint)point inContext:(CGContextRef)context;
- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;

- (void)drawInCurrentContext;
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

/** Returns a Boolean value indicating whether the area enclosed by the path contains the specified point. */
- (BOOL)containsPoint:(CGPoint)point;

/** Returns a UIImage with the SVG rendered "scale to fill" the provided size. */
- (UIImage *)imageAtSize:(CGSize)size;

@end
