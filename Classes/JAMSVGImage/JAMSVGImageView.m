
#import "JAMSVGImageView.h"
#import "JAMSVGImage.h"

@interface JAMSVGImageView ()
@property (nonatomic) JAMSVGImage *svgImage;
@end

@implementation JAMSVGImageView

- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;
{
    if (!(self = [super initWithFrame:CGRectMake(0, 0, svgImage.size.width, svgImage.size.height)])) return nil;
    
    self.svgImage = svgImage;
    self.backgroundColor = UIColor.clearColor;
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.svgImage drawInRect:rect];
}

@end
