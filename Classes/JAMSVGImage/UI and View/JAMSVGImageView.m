/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGImageView.h"

@implementation JAMSVGImageView

- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;
{
    if (!(self = [super initWithFrame:CGRectMake(0, 0, svgImage.size.width, svgImage.size.height)])) return nil;
    
    self.svgImage = svgImage;
    self.backgroundColor = UIColor.clearColor;
    return self;
}

- (void)setSvgName:(NSString *)imageName;
{
    self.backgroundColor = UIColor.clearColor;
    self.svgImage = [JAMSVGImage imageNamed:imageName];
}

- (void)sizeToFit;
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.svgImage.size.width, self.svgImage.size.height);
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    if (_contentMode != contentMode) {
        _contentMode = contentMode;
        [self setNeedsDisplay];
    }
}

- (void)setSvgImage:(JAMSVGImage *)svgImage
{
    if (_svgImage != svgImage) {
        _svgImage = svgImage;
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews;
{
    [self setNeedsDisplay];
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.svgImage drawInRect:[self destinationRectForRect:rect] inContext:context];
}

- (CGRect)destinationRectForRect:(CGRect)rect;
{
    CGRect destinationRect = CGRectZero;
    CGFloat scalingFactor = 1.f;
    CGFloat halfRectWidth = rect.size.width / 2.0;
    CGFloat halfRectHeight = rect.size.height / 2.0;
    CGFloat halfSVGWidth = self.svgImage.size.width / 2.0;
    CGFloat halfSVGHeight = self.svgImage.size.height / 2.0;
    
    switch (self.contentMode) {
        case UIViewContentModeBottom:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeBottomLeft:
            destinationRect = CGRectMake(0, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeBottomRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeCenter:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeLeft:
            destinationRect = CGRectMake(0, halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeRedraw: // This option doesn't make sense with SVG. We'll redraw regardless.
            destinationRect = rect;
            break;
        case UIViewContentModeRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width,
                                         halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeScaleAspectFill:
            scalingFactor = MAX(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake(halfRectWidth - (halfSVGWidth * scalingFactor),
                                         halfRectHeight - (halfSVGHeight * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleAspectFit:
            scalingFactor = MIN(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake(halfRectWidth - (halfSVGWidth * scalingFactor),
                                         halfRectHeight - (halfSVGHeight * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleToFill:
            destinationRect = rect;
            break;
        case UIViewContentModeTop:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeTopLeft:
            destinationRect = CGRectMake(0, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeTopRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        default:
            destinationRect = rect;
            break;
    }
    return destinationRect;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    if (![super pointInside:point withEvent:event]) {
        return NO;
    }
    
    return [self.svgImage containsPoint:point];
}

@end
