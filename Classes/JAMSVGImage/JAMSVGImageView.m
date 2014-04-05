
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

// SVG redraws whenever bounds change.
- (void)layoutSubviews;
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect destinationRect = CGRectZero;
    CGFloat scalingFactor = 1.f;
    switch (self.contentMode) {
        case UIViewContentModeBottom:
            destinationRect = CGRectMake((rect.size.width / 2.f) - (self.svgImage.size.width / 2.f),
                                         rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeBottomLeft:
            destinationRect = CGRectMake(0,
                                         rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeBottomRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width,
                                         rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeCenter:
            destinationRect = CGRectMake((rect.size.width / 2.f) - (self.svgImage.size.width / 2.f),
                                         (rect.size.height / 2.f) - (self.svgImage.size.height / 2.f),
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeLeft:
            destinationRect = CGRectMake(0,
                                         (rect.size.height / 2.f) - (self.svgImage.size.height / 2.f),
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeRedraw: // This option doesn't make sense with SVG. We redraw regardless.
            destinationRect = rect;
            break;
        case UIViewContentModeRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width,
                                         (rect.size.height / 2.f) - (self.svgImage.size.height / 2.f),
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeScaleAspectFill:
            scalingFactor = MAX(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake((rect.size.width / 2.f) - ((self.svgImage.size.width / 2.f) * scalingFactor),
                                         (rect.size.height / 2.f) - ((self.svgImage.size.height / 2.f) * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleAspectFit:
            scalingFactor = MIN(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake((rect.size.width / 2.f) - ((self.svgImage.size.width / 2.f) * scalingFactor),
                                         (rect.size.height / 2.f) - ((self.svgImage.size.height / 2.f) * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleToFill:
            destinationRect = rect;
            break;
        case UIViewContentModeTop:
            destinationRect = CGRectMake((rect.size.width / 2.f) - (self.svgImage.size.width / 2.f),
                                         0,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeTopLeft:
            destinationRect = CGRectMake(0,
                                         0,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeTopRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width,
                                         0,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        default:
            destinationRect = rect;
            break;
    }
    [self.svgImage drawInRect:destinationRect];
}

@end
