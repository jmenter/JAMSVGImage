
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

@end
