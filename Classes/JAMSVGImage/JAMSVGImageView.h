
#import <UIKit/UIKit.h>
@class JAMSVGImage;

/** The JAMSVGImageView encapsulates a JAMSVGImage in a UIView. The SVG redraw respects the contentMode property and redraws at every frame/bounds change. */
@interface JAMSVGImageView : UIView

/** Creates a new JAMSVGImageView from a JAMSVGImage. */
- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;

@end
