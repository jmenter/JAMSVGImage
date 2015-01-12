
#import "JAMSVGUtilities.h"
#import <zlib.h>

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

CGFloat angle(CGPoint point1, CGPoint point2)
{
    return (point1.x * point2.y < point1.y * point2.x ? -1 : 1) * acos(ratio(point1, point2));
}

CGFloat ratio(CGPoint point1, CGPoint point2)
{
    return (point1.x * point2.x + point1.y * point2.y) / (magnitude(point1) * magnitude(point2));
}

CGFloat magnitude(CGPoint point)
{
    return sqrt(pow(point.x, 2) + pow(point.y, 2));
}



#pragma mark - Hella useful categories.

@implementation NSString (Utilities)

- (BOOL)doesContainString:(NSString *)aString;
{
    if ([self respondsToSelector:@selector(containsString:)]) {
        return [self containsString:aString];
    }
    return [self rangeOfString:aString].location != NSNotFound;
}

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

+ (UIColor *)colorFromString:(NSString *)string;
{
    if ([string doesContainString:@"rgb"]) {
        return [UIColor colorFromRGBString:string];
    } else if ([string doesContainString:@"#"]) {
        return [UIColor colorFromHexString:string];
    } else if ([string doesContainString:@"hsl"]) {
        return [UIColor colorFromHSLString:string];
    }
    return nil;
}

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

+ (UIColor *)colorFromRGBString:(NSString *)rgbString;
{
    if (!rgbString || [rgbString doesContainString:@"none"]) { return nil; }
    
    NSScanner *scanner = [NSScanner scannerWithString:rgbString];
    BOOL hasAlpha = [rgbString doesContainString:@"rgba"];
    if (![scanner scanString: hasAlpha ? @"rgba(" : @"rgb(" intoString:NULL]) { return nil; }
    
    float red = 0, green = 0, blue = 0, alpha = 1;
    BOOL redWasScanned = [scanner scanFloat:&red];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", "] intoString:NULL];
    BOOL greenWasScanned = [scanner scanFloat:&green];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", "] intoString:NULL];
    BOOL blueWasScanned = [scanner scanFloat:&blue];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", "] intoString:NULL];
    
    if (!(redWasScanned && greenWasScanned && blueWasScanned)) {
        return nil;
    }
    if (hasAlpha && ![scanner scanFloat:&alpha]) {
        return nil;
    }
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha];
}

+ (UIColor *)colorFromHSLString:(NSString *)hslString;
{
    if (!hslString || [hslString doesContainString:@"none"]) { return nil; }
    
    NSScanner *scanner = [NSScanner scannerWithString:hslString];
    BOOL hasAlpha = [hslString doesContainString:@"hsla"];
    if (![scanner scanString: hasAlpha ? @"hsla(" : @"hsl(" intoString:NULL]) { return nil; }
    
    float hue = 0, saturation = 0, lightness = 0, alpha = 1;
    BOOL hueWasScanned = [scanner scanFloat:&hue];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", %"] intoString:NULL];
    BOOL saturationWasScanned = [scanner scanFloat:&saturation];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", %"] intoString:NULL];
    BOOL lightnessWasScanned = [scanner scanFloat:&lightness];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@", %"] intoString:NULL];
    
    if (!(hueWasScanned && saturationWasScanned && lightnessWasScanned)) {
        return nil;
    }
    if (hasAlpha && ![scanner scanFloat:&alpha]) {
        return nil;
    }
    return [UIColor colorWithHue:hue / 360.f saturation:saturation / 100.f brightness:lightness / 100.f alpha:alpha];
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
    [self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"].invertedSet intoString:NULL];
}

- (BOOL)scanPoint:(CGPoint *)point;
{
    [self scanUpToCharactersFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet.invertedSet intoString:NULL];
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

- (BOOL)scanBool:(BOOL *)boolean;
{

    while (!self.isAtEnd && ([self.currentCharacter isEqualToString:@" "] || [self.currentCharacter isEqualToString:@","])) {
        self.scanLocation++;
    }
    if (!self.isAtEnd) {
        if ([self.currentCharacter isEqualToString:@"-"]) {
            return NO;
        }
        if (![@[@"0", @"1"] containsObject:self.currentCharacter]) {
            self.scanLocation++;
        }
        if (!self.isAtEnd) {
            if ([@[@"0", @"1"] containsObject:self.currentCharacter]) {
                *boolean = (BOOL)[self.currentCharacter intValue];
                if (!self.isAtEnd) {
                    self.scanLocation++;
                }
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)scanCGFloat:(CGFloat *)scannedFloat;
{
    [self scanUpToCharactersFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet.invertedSet intoString:NULL];
    float floatValue;
    if ([self scanFloat:&floatValue]) {
        *scannedFloat = (CGFloat)floatValue;
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
    return [UIColor colorFromString:self[key]];
}

- (UIColor *)fillColorForKey:(NSString *)key;
{
    if (!self[key]) {
        return [UIColor colorFromString:@"#000000"];
    }
    return [UIColor colorFromString:self[key]];
}

- (NSArray *)dashArrayForKey:(NSString *)key;
{
    if ([self[key] isEqualToString:@"none"]) { return nil; }
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

@implementation NSData (GZIPUtilities)

- (NSData *)gunzip:(NSError**)error;
{
    NSString *yourErrorDomain = @"com.yourdomainhere";
    if (self.length < 18) {
        if (error)
            *error = [NSError errorWithDomain:yourErrorDomain code:Z_DATA_ERROR userInfo:nil];
        return nil;
    }
    z_stream zStream;
    memset(&zStream, 0, sizeof(zStream));

    int iResult = inflateInit2(&zStream, 16);
    if (iResult != Z_OK) {
        if (error)
            *error = [NSError errorWithDomain:yourErrorDomain code:iResult userInfo:nil];
        return nil;
    }

    UInt32 nUncompressedBytes = *(UInt32 *)(self.bytes + self.length - 4);
    NSMutableData *gunzippedData = [NSMutableData dataWithLength:nUncompressedBytes];
    
    zStream.next_in = (Bytef *)self.bytes;
    zStream.avail_in = (uint)self.length;
    zStream.next_out = (Bytef *)gunzippedData.bytes;
    zStream.avail_out = (uint)gunzippedData.length;
    
    iResult = inflate(&zStream, Z_FINISH);
    if (iResult != Z_STREAM_END) {
        if (error)
            *error = [NSError errorWithDomain:yourErrorDomain code:iResult userInfo:nil];
        gunzippedData = nil;
    }
    inflateEnd(&zStream);
    return gunzippedData;
}

@end