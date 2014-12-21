
#import <UIKit/UIKit.h>

IB_DESIGNABLE

/** The JAMSVGButton is a UIButton subclass that allows setting JAMSVGImage properties for the four button states. The SVG images are placed in the background of the button in a "scale to fill" fashion. Make sure you set the button type to "custom" in Interface Builder*/
@interface JAMSVGButton : UIButton

@property (nonatomic) IBInspectable NSString *normalSvg;
@property (nonatomic) IBInspectable NSString *highlightedSvg;
@property (nonatomic) IBInspectable NSString *disabledSvg;
@property (nonatomic) IBInspectable NSString *selectedSvg;

@end
