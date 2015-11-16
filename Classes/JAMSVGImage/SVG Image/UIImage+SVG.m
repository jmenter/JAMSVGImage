/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "UIImage+SVG.h"
#import "JAMSVGImage.h"

@implementation UIImage (SVG)

+ (UIImage *)imageFromSVGNamed:(NSString *)svgName;
{
    return [JAMSVGImage imageNamed:svgName].image;
}

+ (UIImage *)imageFromSVGNamed:(NSString *)svgName inBundle:(NSBundle *)bundle
{
    return [JAMSVGImage imageNamed:svgName inBundle:bundle].image;
}

+ (UIImage *)imageFromSVGNamed:(NSString *)svgName atSize:(CGSize)size;
{
    return [[JAMSVGImage imageNamed:svgName] imageAtSize:size];
}

+ (UIImage *)imageFromSVGNamed:(NSString *)svgName atScale:(CGFloat)scale;
{
    JAMSVGImage *svgImage = [JAMSVGImage imageNamed:svgName];
    svgImage.scale = scale;
    return svgImage.image;
}

@end
