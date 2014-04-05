
#import <UIKit/UIKit.h>
@class JAMSVGImage;

@interface JAMSVGImageView : UIView

/** Creates a new JAMSVGImageView from a JAMSVGImage. */
- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;

@end
