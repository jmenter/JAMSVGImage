/*
 
 Copyright (c) 2014-2018 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

CGAffineTransform CGAffineTransformSkew(CGAffineTransform transform, CGFloat skewX, CGFloat skewY);
CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2);
CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2);

CGFloat angle(CGPoint point1, CGPoint point2);
CGFloat ratio(CGPoint point1, CGPoint point2);
CGFloat magnitude(CGPoint point);

@interface NSString (Utilities)
- (NSString *)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSString *)stringByTrimmingWhitespace;
- (NSString *)firstCharacter;
- (NSString *)lastCharacter;
@end

@interface UIColor (HexUtilities)
+ (UIColor *)colorFromString:(NSString *)string;
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
