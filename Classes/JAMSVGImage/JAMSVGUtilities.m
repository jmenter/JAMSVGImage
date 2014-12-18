
#import "JAMSVGUtilities.h"

#pragma mark - Core Graphics Utilities

CGAffineTransform CGAffineTransformSkew(CGAffineTransform transform, CGFloat skewX, CGFloat skewY)
{
    return CGAffineTransformConcat(transform, CGAffineTransformMake(1, tanf(skewY), tanf(skewX), 1, 0, 0));
}

CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

#pragma mark - Hella useful categories.

@implementation NSString (Utilities)
- (NSString *)stringByTrimmingWhitespace;
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)characterStringAtIndex:(NSUInteger)index;
{
    return (self.length > index) ? [NSString stringWithFormat:@"%C", [self characterAtIndex:index]] : nil;
}

- (NSString *)firstCharacter;
{
    return (self.length > 0) ? [NSString stringWithFormat:@"%C", [self characterAtIndex:0]] : nil;
}

- (NSString *)lastCharacter;
{
    return (self.length > 0) ? [NSString stringWithFormat:@"%C", [self characterAtIndex:self.length - 1]] : nil;
}
@end

@implementation UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
{
    if (!hexString || [hexString isEqualToString:@"none"] || !(hexString.length == 3 || hexString.length == 4 || hexString.length == 6 || hexString.length == 7))
        return nil;
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    if (hexString.length == 3) {
        hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@", [hexString characterStringAtIndex:0], [hexString characterStringAtIndex:0],
                     [hexString characterStringAtIndex:1], [hexString characterStringAtIndex:1],
                     [hexString characterStringAtIndex:2], [hexString characterStringAtIndex:2]];
    }
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}
@end

@implementation NSScanner (Utilities)

- (BOOL)scanFloatAndAdvance:(float *)result;
{
    BOOL foundFloat = [self scanFloat:result];
    [self scanThroughWhitespaceCommasAndClosingParenthesis];
    return foundFloat;
}

- (void)scanThroughWhitespaceCommasAndClosingParenthesis;
{
    [self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" ,)"] intoString:NULL];
}

- (NSString *)initialCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:0]];
}

- (NSString *)currentCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:self.scanLocation]];
}

- (void)scanThroughToHyphen;
{
    if (self.isAtEnd) {
        return;
    }
    if (![self.currentCharacter isEqualToString:@"-"])
        self.scanLocation++;
}

- (BOOL)scanPoint:(CGPoint *)point;
{
    float xCoord, yCoord;
    [self scanThroughToHyphen];
    BOOL didScanX = [self scanFloat:&xCoord];
    [self scanThroughToHyphen];
    BOOL didScanY = [self scanFloat:&yCoord];
    if (didScanX && didScanY) {
        *point = CGPointMake(xCoord, yCoord);
        return YES;
    }
    return NO;
}

@end

@implementation NSDictionary (Utilities)

- (CGFloat)floatForKey:(NSString *)key;
{
    return self[key] ? [self[key] floatValue] : 0.f;
}

- (NSNumber *)opacityForKey:(NSString *)key
{
    return self[key] ? @([self[key] floatValue]) : nil;
}

- (UIColor *)strokeColorForKey:(NSString *)key;
{
    return [UIColor colorFromHexString:self[key]];
}

- (UIColor *)fillColorForKey:(NSString *)key;
{
    return [UIColor colorFromHexString:self[key] ?: @"#000000"];
}

- (NSArray *)dashArrayForKey:(NSString *)key;
{
    NSMutableArray *floatValues = NSMutableArray.new;
    for (NSString *value in [self[key] componentsSeparatedByString:@","]) {
        [floatValues addObject:@(value.floatValue)];
    }
    return floatValues.count == 0 ? nil : floatValues.copy;
}

- (CGFloat)strokeWeightForKey:(NSString *)key;
{
    return self[key] ? [self[key] floatValue] : 1.f;
}

- (CGLineJoin)lineJoinForKey:(NSString *)key;
{
    return [self[key] isEqualToString:@"round"] ? kCGLineJoinRound : [self[key] isEqualToString:@"square"] ? kCGLineJoinBevel : kCGLineJoinMiter;
}

- (CGLineCap)lineCapForKey:(NSString *)key;
{
    return [self[key] isEqualToString:@"round"] ? kCGLineCapRound : [self[key] isEqualToString:@"square"] ? kCGLineCapSquare : kCGLineCapButt;
}

- (CGFloat)miterLimitForKey:(NSString *)key;
{
    return self[key] ? [self[key] floatValue] : 10.f;
}

- (NSValue *)affineTransformForKey:(NSString *)key;
{
    if (!self[key]) return nil;
    
    float a = 1, b = 0, c = 0, d = 1, tx = 0, ty = 0, angle = 0;
    CGAffineTransform transform = CGAffineTransformIdentity;
    NSScanner *floatScanner = [NSScanner scannerWithString:self[key]];
    
    while (!floatScanner.isAtEnd) {
        a = 1, b = 0, c = 0, d = 1, tx = 0, ty = 0, angle = 0;
        if ([floatScanner scanString:@"matrix(" intoString:NULL]) {
            [floatScanner scanFloatAndAdvance:&a];
            [floatScanner scanFloatAndAdvance:&b];
            [floatScanner scanFloatAndAdvance:&c];
            [floatScanner scanFloatAndAdvance:&d];
            [floatScanner scanFloatAndAdvance:&tx];
            [floatScanner scanFloatAndAdvance:&ty];
            transform = CGAffineTransformConcat(transform, CGAffineTransformMake(a, b, c, d, tx, ty));
        }
        else if ([floatScanner scanString:@"translate(" intoString:NULL]) {
            [floatScanner scanFloatAndAdvance:&tx];
            [floatScanner scanFloatAndAdvance:&ty];
            transform = CGAffineTransformTranslate(transform, tx, ty);
        }
        else if ([floatScanner scanString:@"scale(" intoString:NULL]) {
            [floatScanner scanFloatAndAdvance:&a];
            d = [floatScanner scanFloatAndAdvance:&d] ? d : a;
            transform = CGAffineTransformScale(transform, a, d);
        }
        else if ([floatScanner scanString:@"rotate(" intoString:NULL]) {
            float translateX = 0;
            float translateY = 0;
            [floatScanner scanFloatAndAdvance:&angle];
            [floatScanner scanFloatAndAdvance:&translateX];
            [floatScanner scanFloatAndAdvance:&translateY];
            transform = CGAffineTransformTranslate(transform, translateX, translateY);
            transform = CGAffineTransformRotate(transform, angle * (M_PI / 180.f));
            transform = CGAffineTransformTranslate(transform, -translateX, -translateY);
        }
        else if ([floatScanner scanString:@"skewX(" intoString:NULL]) {
            [floatScanner scanFloatAndAdvance:&angle];
            transform = CGAffineTransformSkew(transform, angle * (M_PI / 180.f), 0);
        }
        else if ([floatScanner scanString:@"skewY(" intoString:NULL]) {
            [floatScanner scanFloatAndAdvance:&angle];
            transform = CGAffineTransformSkew(transform, 0, angle * (M_PI / 180.f));
        }
    }
    
    return [NSValue valueWithCGAffineTransform:transform];
}

@end
