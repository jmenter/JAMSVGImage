
#import <UIKit/UIKit.h>

CGAffineTransform CGAffineTransformSkew(CGAffineTransform transform, CGFloat skewX, CGFloat skewY);
CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2);
CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2);

@interface NSString (Utilities)
- (NSString *)stringByTrimmingWhitespace;
- (NSString *)characterStringAtIndex:(NSUInteger)index;
- (NSString *)firstCharacter;
- (NSString *)lastCharacter;
@end

@interface UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

@interface NSScanner (Utilities)
- (BOOL)scanFloatAndAdvance:(float *)result;
- (void)scanThroughWhitespaceCommasAndClosingParenthesis;
- (NSString *)initialCharacter;
- (NSString *)currentCharacter;
- (void)scanThroughToHyphen;
- (BOOL)scanPoint:(CGPoint *)point;
- (BOOL)scanBool:(BOOL *)boolean;
- (BOOL)scanCGFloat:(CGFloat *)scannedFloat;
@end

@interface NSDictionary (Utilities)
- (CGFloat)floatForKey:(NSString *)key;
- (NSNumber *)opacityForKey:(NSString *)key;
- (UIColor *)strokeColorForKey:(NSString *)key;
- (UIColor *)fillColorForKey:(NSString *)key;
- (CGFloat)strokeWeightForKey:(NSString *)key;
- (NSArray *)dashArrayForKey:(NSString *)key;
- (CGLineJoin)lineJoinForKey:(NSString *)key;
- (CGLineCap)lineCapForKey:(NSString *)key;
- (CGFloat)miterLimitForKey:(NSString *)key;
- (NSValue *)affineTransformForKey:(NSString *)key;
@end

@interface NSData (GZIPUtilities)
- (NSData *)gunzip:(NSError**)error;
@end
