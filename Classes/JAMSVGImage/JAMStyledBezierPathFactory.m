/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMStyledBezierPathFactory.h"
#import "JAMStyledBezierPath.h"
#import "JAMSVGGradientParts.h"

#pragma mark - CG Utility Functions

static CGAffineTransform CGAffineTransformSkew(CGAffineTransform transform, CGFloat skewX, CGFloat skewY) {
    return CGAffineTransformConcat(transform, CGAffineTransformMake(1, tanf(skewY), tanf(skewX), 1, 0, 0));
}

static CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

static CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

#pragma mark - Private path properties.

@interface JAMStyledBezierPath (Private)
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) JAMSVGGradient *gradient;
@property (nonatomic) NSValue *transform;
@property (nonatomic) NSNumber *opacity;
@end

#pragma mark - Hella useful categories.

@interface UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

@implementation UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
{
    if (!hexString || [hexString isEqualToString:@"none"])
        return nil;
    
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    scanner.scanLocation = 1;
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}
@end

@interface NSScanner (Utilities)
- (BOOL)scanFloatAndAdvance:(float *)result;
- (void)scanThroughWhitespaceCommasAndClosingParenthesis;
- (NSString *)initialCharacter;
- (NSString *)currentCharacter;
- (void)scanThroughToHyphen;
- (BOOL)scanPoint:(CGPoint *)point;
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

@interface JAMStyledBezierPathFactory ()
@property (nonatomic) NSMutableArray *gradients;
@property CGPoint previousCurveOperationControlPoint;
@property (nonatomic) NSNumber *groupOpacityValue;
@property (nonatomic) NSMutableArray *affineTransformStack;
@end

@implementation JAMStyledBezierPathFactory

#pragma mark - Main Factory

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.gradients = NSMutableArray.new;
    self.affineTransformStack = NSMutableArray.new;
    return self;
}

- (JAMStyledBezierPath *)styledPathFromElementName:(NSString *)elementName attributes:(NSDictionary *)attributes;
{
    if ([elementName isEqualToString:@"circle"])
        return [self circleWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"ellipse"])
        return [self ellipseWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"rect"])
        return [self rectWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"path"])
        return [self pathWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"polyline"])
        return [self polylineWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"polygon"])
        return [self polygonWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"line"])
        return [self lineWithAttributes:attributes];
    
    if ([elementName isEqualToString:@"linearGradient"]) {
        [self saveLinearGradient:attributes];
        return nil;
    }
   if ([elementName isEqualToString:@"radialGradient"]) {
        [self saveRadialGradient:attributes];
        return nil;
    }
    return nil;
}

- (void)addGradientStopWithAttributes:(NSDictionary *)attributes;
{
    JAMSVGGradientColorStop *colorStop = JAMSVGGradientColorStop.new;
    colorStop.position = [attributes floatForKey:@"offset"];
    colorStop.color = [self parseStyleColor:attributes[@"style"]];
    [((JAMSVGGradient *)self.gradients.lastObject).colorStops addObject:colorStop];
}

- (void)addGroupOpacityValueWithAttributes:(NSDictionary *)attributes;
{
    self.groupOpacityValue = [attributes opacityForKey:@"opacity"];
}

- (void)removeGroupOpacityValue;
{
    self.groupOpacityValue = nil;
}

- (void)pushGroupTransformWithAttributes:(NSDictionary *)attributes;
{
    [self.affineTransformStack addObject:[attributes affineTransformForKey:@"transform"]];
}

- (void)popGroupTransform;
{
    [self.affineTransformStack removeLastObject];
}

- (CGAffineTransform)concatenatedGroupTransforms;
{
    CGAffineTransform concatenated = CGAffineTransformIdentity;
    for (NSValue *value in self.affineTransformStack) {
        concatenated = CGAffineTransformConcat(concatenated, value.CGAffineTransformValue);
    }
    return concatenated;
}

- (CGRect)getViewboxFromAttributes:(NSDictionary *)attributes;
{
    if (!attributes[@"viewBox"]) {
        if (attributes[@"width"] && attributes[@"height"]) {
            return CGRectMake(0, 0, [attributes[@"width"] floatValue], [attributes[@"height"] floatValue]);
        } else {
            return CGRectMake(0, 0, 256, 256);
        }
    }
    
    float xPosition, yPosition, width, height;
    NSScanner *viewBoxScanner = [NSScanner scannerWithString:attributes[@"viewBox"]];
    
    [viewBoxScanner scanFloat:&xPosition];
    [viewBoxScanner scanFloat:&yPosition];
    [viewBoxScanner scanFloat:&width];
    [viewBoxScanner scanFloat:&height];
    
    return CGRectMake(xPosition, yPosition, width, height);
}

- (UIColor *)parseStyleColor:(NSString *)styleColor;
{
    UIColor *color;
    NSScanner *colorScanner = [NSScanner scannerWithString:styleColor];
    if ([colorScanner scanString:@"stop-color:" intoString:NULL]) {
        color = [UIColor colorFromHexString:[styleColor substringFromIndex:colorScanner.scanLocation]];
    };
    if ([colorScanner scanUpToString:@"stop-opacity:" intoString:NULL]) {
        [colorScanner scanString:@"stop-opacity:" intoString:NULL];
        float opacity = 1;
        [colorScanner scanFloat:&opacity];
        color = [color colorWithAlphaComponent:opacity];
    }
    return color;
}

- (void)saveLinearGradient:(NSDictionary *)attributes;
{
    JAMSVGLinearGradient *gradient = JAMSVGLinearGradient.new;
    gradient.identifier = attributes[@"id"];
    gradient.startPosition = CGPointMake([attributes[@"x1"] floatValue], [attributes[@"y1"] floatValue]);
    gradient.endPosition = CGPointMake([attributes[@"x2"] floatValue], [attributes[@"y2"] floatValue]);
    gradient.gradientTransform = [attributes affineTransformForKey:@"gradientTransform"];
    [self.gradients addObject:gradient];
}

-(void)saveRadialGradient:(NSDictionary *)attributes;
{
    JAMSVGRadialGradient *gradient = JAMSVGRadialGradient.new;
    gradient.identifier = attributes[@"id"];
    gradient.position = CGPointMake([attributes[@"cx"] floatValue], [attributes[@"cy"] floatValue]);
    gradient.radius = [attributes[@"r"] floatValue];
    gradient.gradientTransform = [attributes affineTransformForKey:@"gradientTransform"];
    [self.gradients addObject:gradient];
}

#pragma mark - Basic Element Factory Methods

- (JAMStyledBezierPath *)rectWithAttributes:(NSDictionary *)attributes;
{
    CGRect rect = CGRectMake([attributes floatForKey:@"x"],
                             [attributes floatForKey:@"y"],
                             [attributes floatForKey:@"width"],
                             [attributes floatForKey:@"height"]);
    return [self createStyledPath:[UIBezierPath bezierPathWithRect:rect] withAttributes:attributes];
}

- (JAMStyledBezierPath *)ellipseWithAttributes:(NSDictionary *)attributes;
{
    CGRect rect = CGRectMake([attributes floatForKey:@"cx"] - [attributes floatForKey:@"rx"],
                             [attributes floatForKey:@"cy"] - [attributes floatForKey:@"ry"],
                             [attributes floatForKey:@"rx"] * 2.f,
                             [attributes floatForKey:@"ry"] * 2.f);
    return [self createStyledPath:[UIBezierPath bezierPathWithOvalInRect:rect] withAttributes:attributes];
}

- (JAMStyledBezierPath *)circleWithAttributes:(NSDictionary *)attributes;
{
    NSMutableDictionary *newAttributes = attributes.mutableCopy;
    newAttributes[@"rx"] = attributes[@"r"];
    newAttributes[@"ry"] = attributes[@"r"];
    return [self ellipseWithAttributes:newAttributes];
}

- (JAMStyledBezierPath *)pathWithAttributes:(NSDictionary *)attributes;
{
    NSString *commandString = attributes[@"d"];
    NSString *trimmedCommandString = [commandString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *commandList = [self commandListForCommandString:trimmedCommandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    commandListPath.usesEvenOddFillRule = [attributes[@"fill-rule"] isEqualToString:@"evenodd"];
    return [self createStyledPath:commandListPath withAttributes:attributes];
}

- (JAMStyledBezierPath *)polygonWithAttributes:(NSDictionary *)attributes;
{
    NSString *commandString = attributes[@"points"];
    NSArray *commandList = [self commandListForPolylineString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    [commandListPath closePath];
    return [self createStyledPath:commandListPath withAttributes:attributes];
}

- (JAMStyledBezierPath *)polylineWithAttributes:(NSDictionary *)attributes;
{
    NSString *commandString = attributes[@"points"];
    NSArray *commandList = [self commandListForPolylineString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    return [self createStyledPath:commandListPath withAttributes:attributes];
}

- (JAMStyledBezierPath *)lineWithAttributes:(NSDictionary *)attributes;
{
    UIBezierPath *path = UIBezierPath.new;
    [path moveToPoint:CGPointMake([attributes floatForKey:@"x1"], [attributes floatForKey:@"y1"])];
    [path addLineToPoint:CGPointMake([attributes floatForKey:@"x2"], [attributes floatForKey:@"y2"])];

    return [self createStyledPath:path withAttributes:attributes];
}

#pragma mark - Styled Path Creation Methods

- (JAMStyledBezierPath *)createStyledPath:(UIBezierPath *)path withAttributes:(NSDictionary *)attributes;
{
    
    NSArray *transforms = nil;
    if (attributes[@"transform"] || self.affineTransformStack.count > 0) {
        if (attributes[@"transform"]) {
            transforms = [self.affineTransformStack arrayByAddingObject:[attributes affineTransformForKey:@"transform"]];
        } else {
            transforms = self.affineTransformStack.copy;
        }
    }
    return [JAMStyledBezierPath styledPathWithPath:[self applyStrokeAttributes:attributes toPath:path]
                                         fillColor:[attributes fillColorForKey:@"fill"]
                                       strokeColor:[attributes strokeColorForKey:@"stroke"]
                                          gradient:[self gradientForFillURL:attributes[@"fill"]]
                                  affineTransforms:transforms
                                           opacity:[self opacityFromAttributes:attributes]];
}

- (UIBezierPath *)applyStrokeAttributes:(NSDictionary *)attributes toPath:(UIBezierPath *)path;
{
    NSArray *dashArray = [attributes dashArrayForKey:@"stroke-dasharray"];
    if (dashArray) {
        CGFloat values[dashArray.count];
        for (int i = 0; i < dashArray.count; i++) {
            values[i] = [dashArray[i] floatValue];
        }
        [path setLineDash:values count:dashArray.count phase:0.f];
    }
    path.lineWidth = [attributes strokeWeightForKey:@"stroke-width"];
    path.miterLimit = [attributes miterLimitForKey:@"stroke-miterlimit"];
    path.lineJoinStyle = [attributes lineJoinForKey:@"stroke-linejoin"];
    path.lineCapStyle = [attributes lineCapForKey:@"stroke-linecap"];
    
    return path;
}

- (NSNumber *)opacityFromAttributes:(NSDictionary *)attributes;
{
    NSNumber *opacity = [attributes opacityForKey:@"opacity"];
    if (self.groupOpacityValue) {
        if (opacity) {
            opacity = @(opacity.floatValue * self.groupOpacityValue.floatValue);
        } else {
            opacity = self.groupOpacityValue;
        }
    }
    return opacity;
}

- (JAMSVGGradient *)gradientForFillURL:(NSString *)fillURL;
{
    
    if (fillURL && [fillURL rangeOfString:@"url(#"].location != NSNotFound) {
        NSScanner *urlScanner = [NSScanner scannerWithString:fillURL];
        [urlScanner scanString:@"url(#" intoString:NULL];
        NSString *gradientIdentifier;
        [urlScanner scanUpToString:@")" intoString:&gradientIdentifier];
        NSArray *filteredArray = [self.gradients filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", gradientIdentifier]];
        return filteredArray.lastObject;
    }
    return nil;
}

#pragma mark - Command List Methods

- (NSArray *)commandListForCommandString:(NSString *)commandString;
{
    NSScanner *commandScanner = [NSScanner scannerWithString:commandString];
    NSCharacterSet *knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
    NSMutableArray *commandList = NSMutableArray.new;
    
    NSString *command;
    NSUInteger lastLocation = 0;
    while (!commandScanner.isAtEnd)
    {
        [commandScanner scanUpToCharactersFromSet:knownCommands intoString:&command];
        NSString *fullCommand = [commandString substringWithRange:NSMakeRange(lastLocation, commandScanner.scanLocation - lastLocation)];
        NSString *trimmedFullCommand = [fullCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedFullCommand isEqualToString:@""])
            [commandList addObject:trimmedFullCommand];
        
        lastLocation = commandScanner.scanLocation;
        if (!commandScanner.isAtEnd)
            commandScanner.scanLocation++;
    }
    return commandList.copy;
}

- (NSArray *)commandListForPolylineString:(NSString *)polylineString;
{
    NSMutableArray *commandList = NSMutableArray.new;
    [[polylineString componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString *)obj isEqualToString:@""]) return;
        [commandList addObject:[NSString stringWithFormat: (commandList.count == 0) ? @"M%@" : @"L%@", obj]];
    }];
    return commandList;
}

- (UIBezierPath *)bezierPathFromCommandList:(NSArray *)commandList;
{
    UIBezierPath *path = UIBezierPath.new;
    for (NSString *command in commandList) {
        NSScanner *commandScanner = [NSScanner scannerWithString:command];
        if ([@[@"M", @"m"] containsObject:commandScanner.currentCharacter])
            [self addMoveToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"L", @"l"] containsObject:commandScanner.currentCharacter])
            [self addLineToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"H", @"h"] containsObject:commandScanner.currentCharacter])
            [self addHorizontalLineToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"V", @"v"] containsObject:commandScanner.currentCharacter])
            [self addVerticalLineToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"C", @"c"] containsObject:commandScanner.currentCharacter])
            [self addCurveToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"S", @"s"] containsObject:commandScanner.currentCharacter])
            [self addSmoothCurveToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"Q", @"q"] containsObject:commandScanner.currentCharacter])
            [self addQuadCurveToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"A", @"a"] containsObject:commandScanner.currentCharacter])
            [self addEllipticalArcToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"Z", @"z"] containsObject:commandScanner.currentCharacter])
            [path closePath];
    }
    return path;
}

#pragma mark - Path Command Methods

- (void)addMoveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint moveToPoint = CGPointZero;
    [commandScanner scanPoint:&moveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"m"])
        moveToPoint = CGPointAddPoints(moveToPoint, path.currentPoint);
    [path moveToPoint:moveToPoint];
}

- (void)addLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint lineToPoint = CGPointZero;
    [commandScanner scanPoint:&lineToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"l"])
        lineToPoint = CGPointAddPoints(lineToPoint, path.currentPoint);
    [path addLineToPoint:lineToPoint];
}

- (void)addHorizontalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    float xPosition;
    [commandScanner scanThroughToHyphen];
    [commandScanner scanFloat:&xPosition];
    CGPoint horizontalLineToPoint = CGPointMake(xPosition, path.currentPoint.y);
    
    if ([commandScanner.initialCharacter isEqualToString:@"h"])
        horizontalLineToPoint.x += path.currentPoint.x;
    [path addLineToPoint:horizontalLineToPoint];
}

- (void)addVerticalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    float yPosition;
    [commandScanner scanThroughToHyphen];
    [commandScanner scanFloat:&yPosition];
    CGPoint verticalLineToPoint = CGPointMake(path.currentPoint.x, yPosition);
    
    if ([commandScanner.initialCharacter isEqualToString:@"v"])
        verticalLineToPoint.y += path.currentPoint.y;
    [path addLineToPoint:verticalLineToPoint];
}

- (void)addCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint curveToPoint = CGPointZero;
    CGPoint controlPoint1 = CGPointZero;
    CGPoint controlPoint2 = CGPointZero;
    [commandScanner scanPoint:&controlPoint1];
    [commandScanner scanPoint:&controlPoint2];
    [commandScanner scanPoint:&curveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"c"]) {
        curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
        controlPoint1 = CGPointAddPoints(controlPoint1, path.currentPoint);
        controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
    }
    self.previousCurveOperationControlPoint = controlPoint2;
    [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)addSmoothCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint smoothedPrevious = CGPointSubtractPoints(path.currentPoint, self.previousCurveOperationControlPoint);
    CGPoint controlPoint1 = CGPointAddPoints(path.currentPoint, smoothedPrevious);
    CGPoint controlPoint2 = CGPointZero;
    CGPoint curveToPoint = CGPointZero;
    [commandScanner scanPoint:&controlPoint2];
    [commandScanner scanPoint:&curveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"s"]) {
        curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
        controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
    }
    self.previousCurveOperationControlPoint = controlPoint2;
    [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)addQuadCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint controlPoint = CGPointZero;
    CGPoint quadCurveToPoint = CGPointZero;
    [commandScanner scanPoint:&controlPoint];
    [commandScanner scanPoint:&quadCurveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"q"]) {
        controlPoint = CGPointAddPoints(controlPoint, path.currentPoint);
        quadCurveToPoint = CGPointAddPoints(quadCurveToPoint, path.currentPoint);
    }
    [path addQuadCurveToPoint:quadCurveToPoint controlPoint:controlPoint];
}

- (void)addEllipticalArcToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint radii, arcEndPoint, arcStartPoint = path.currentPoint;
    float xAxisRotation;
    int largeArcFlag, sweepFlag;
    
    [commandScanner scanPoint:&radii];
    [commandScanner scanFloat:&xAxisRotation];
    [commandScanner scanInt:&largeArcFlag];
    [commandScanner scanThroughToHyphen];
    [commandScanner scanInt:&sweepFlag];
    [commandScanner scanPoint:&arcEndPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"a"]) {
        arcEndPoint = CGPointAddPoints(arcEndPoint, path.currentPoint);
    }
    
    xAxisRotation *= M_PI / 180.f;
    CGPoint currentPoint = CGPointMake(cos(xAxisRotation) * (arcStartPoint.x - arcEndPoint.x) / 2.0 + sin(xAxisRotation) * (arcStartPoint.y - arcEndPoint.y) / 2.0, -sin(xAxisRotation) * (arcStartPoint.x - arcEndPoint.x) / 2.0 + cos(xAxisRotation) * (arcStartPoint.y - arcEndPoint.y) / 2.0);

    CGFloat radiiAdjustment = pow(currentPoint.x, 2) / pow(radii.x, 2) + pow(currentPoint.y, 2) / pow(radii.y, 2);
    radii.x *= (radiiAdjustment > 1) ? sqrt(radiiAdjustment) : 1;
    radii.y *= (radiiAdjustment > 1) ? sqrt(radiiAdjustment) : 1;

    CGFloat sweep = (largeArcFlag == sweepFlag ? -1 : 1) * sqrt(((pow(radii.x, 2) * pow(radii.y, 2)) - (pow(radii.x, 2) * pow(currentPoint.y, 2)) - (pow(radii.y, 2) * pow(currentPoint.x, 2))) / (pow(radii.x, 2) * pow(currentPoint.y, 2) + pow(radii.y, 2) * pow(currentPoint.x, 2)));
    sweep = (sweep != sweep) ? 0 : sweep;
    CGPoint preCenterPoint = CGPointMake(sweep * radii.x * currentPoint.y / radii.y, sweep * -radii.y * currentPoint.x / radii.x);

    CGPoint centerPoint = CGPointMake((arcStartPoint.x + arcEndPoint.x) / 2.0 + cos(xAxisRotation) * preCenterPoint.x - sin(xAxisRotation) * preCenterPoint.y, (arcStartPoint.y + arcEndPoint.y) / 2.0 + sin(xAxisRotation) * preCenterPoint.x + cos(xAxisRotation) * preCenterPoint.y);
    
    CGFloat startAngle = angle(CGPointMake(1, 0), CGPointMake((currentPoint.x-preCenterPoint.x)/radii.x,
                                                              (currentPoint.y-preCenterPoint.y)/radii.y));

    CGPoint deltaU = CGPointMake((currentPoint.x - preCenterPoint.x) / radii.x,
                                 (currentPoint.y - preCenterPoint.y) / radii.y);
    CGPoint deltaV = CGPointMake((-currentPoint.x - preCenterPoint.x) / radii.x,
                                 (-currentPoint.y - preCenterPoint.y) / radii.y);
    CGFloat angleDelta = (deltaU.x * deltaV.y < deltaU.y * deltaV.x ? -1 : 1) * acos(ratio(deltaU, deltaV));
    
    angleDelta = (ratio(deltaU, deltaV) <= -1) ? M_PI : (ratio(deltaU, deltaV) >= 1) ? 0 : angleDelta;
    
    CGFloat radius = MAX(radii.x, radii.y);
    CGPoint scale = (radii.x > radii.y) ? CGPointMake(1, radii.y / radii.x) : CGPointMake(radii.x / radii.y, 1);
    
    [path applyTransform:CGAffineTransformMakeTranslation(-centerPoint.x, -centerPoint.y)];
    [path applyTransform:CGAffineTransformMakeRotation(-xAxisRotation)];
    [path applyTransform:CGAffineTransformMakeScale(1 / scale.x, 1 / scale.y)];
    [path addArcWithCenter:CGPointZero radius:radius startAngle:startAngle endAngle:startAngle + angleDelta clockwise:sweepFlag];
    [path applyTransform:CGAffineTransformMakeScale(scale.x, scale.y)];
    [path applyTransform:CGAffineTransformMakeRotation(xAxisRotation)];
    [path applyTransform:CGAffineTransformMakeTranslation(centerPoint.x, centerPoint.y)];
}

static CGFloat angle(CGPoint point1, CGPoint point2)
{
    return (point1.x * point2.y < point1.y * point2.x ? -1 : 1) * acos(ratio(point1, point2));
}

static CGFloat ratio(CGPoint point1, CGPoint point2)
{
    return (point1.x * point2.x + point1.y * point2.y) / (magnitude(point1) * magnitude(point2));
}

static CGFloat magnitude(CGPoint point)
{
    return sqrt(pow(point.x, 2) + pow(point.y, 2));
}

@end
