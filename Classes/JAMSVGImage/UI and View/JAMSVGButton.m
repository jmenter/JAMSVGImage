/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGButton.h"
#import "JAMSVGImage.h"

@implementation JAMSVGButton

- (void)setNormalSvg:(NSString *)svgName;
{
    _normalSvg = svgName;
    [self setBackgroundImage:[[JAMSVGImage imageNamed:svgName] imageAtSize:self.bounds.size] forState:UIControlStateNormal];
}

- (void)setHighlightedSvg:(NSString *)svgName;
{
    _highlightedSvg = svgName;
    [self setBackgroundImage:[[JAMSVGImage imageNamed:svgName] imageAtSize:self.bounds.size] forState:UIControlStateHighlighted];
}

- (void)setDisabledSvg:(NSString *)svgName;
{
    _disabledSvg = svgName;
    [self setBackgroundImage:[[JAMSVGImage imageNamed:svgName] imageAtSize:self.bounds.size] forState:UIControlStateDisabled];
}

- (void)setSelectedSvg:(NSString *)svgName;
{
    _selectedSvg = svgName;
    [self setBackgroundImage:[[JAMSVGImage imageNamed:svgName] imageAtSize:self.bounds.size] forState:UIControlStateSelected];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    if (self.normalSvg) {
        [self setBackgroundImage:[[JAMSVGImage imageNamed:self.normalSvg] imageAtSize:self.bounds.size] forState:UIControlStateNormal];
    }
    if (self.highlightedSvg) {
        [self setBackgroundImage:[[JAMSVGImage imageNamed:self.highlightedSvg] imageAtSize:self.bounds.size] forState:UIControlStateHighlighted];
    }
    if (self.disabledSvg) {
        [self setBackgroundImage:[[JAMSVGImage imageNamed:self.disabledSvg] imageAtSize:self.bounds.size] forState:UIControlStateDisabled];
    }
    if (self.selectedSvg) {
        [self setBackgroundImage:[[JAMSVGImage imageNamed:self.selectedSvg] imageAtSize:self.bounds.size] forState:UIControlStateSelected];
    }
}

@end
