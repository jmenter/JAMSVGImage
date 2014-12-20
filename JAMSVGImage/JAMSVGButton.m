
#import "JAMSVGButton.h"
#import "JAMSVGImage.h"

@implementation JAMSVGButton

- (void)setSvgName:(NSString *)svgName;
{
    _svgName = svgName;
    [self setBackgroundImage:[[JAMSVGImage imageNamed:svgName] imageAtSize:self.bounds.size]
                    forState:UIControlStateNormal];
}

@end
