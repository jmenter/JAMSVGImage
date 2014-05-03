/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMStyledBezierPathFactory.h"
#import "JAMStyledBezierPath.h"
#import "JAMSVGGradientParts.h"

@interface JAMStyledBezierPath (Private)
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) JAMSVGGradient *gradient;
@property (nonatomic) NSValue *transform;
@property (nonatomic) NSNumber *opacity;
@end


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
    NSString *value = [self valueForKey:key];
    return value ? [value floatValue] : 0.f;
}

- (NSNumber *)opacityForKey:(NSString *)key
{
    return [self valueForKey:key] ? @([[self valueForKey:key] floatValue]) : nil;
}

- (UIColor *)strokeColorForKey:(NSString *)key;
{
    NSString *hexColor = [self valueForKey:key];
    return [UIColor colorFromHexString:hexColor];
}

- (UIColor *)fillColorForKey:(NSString *)key;
{
    NSString *hexColor = [self valueForKey:key] ?: @"#000000";
    return [UIColor colorFromHexString:hexColor];
}

- (NSArray *)dashArrayForKey:(NSString *)key;
{
    NSString *dashValues = [self valueForKey:key];
    if (!dashValues) return nil;

    NSMutableArray *floatValues = NSMutableArray.new;
    NSArray *stringValues = [dashValues componentsSeparatedByString:@","];
    
    for (NSString *value in stringValues) {
        [floatValues addObject:@(value.floatValue)];
    }
    return floatValues;
}

- (CGFloat)strokeWeightForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    return value ? value.floatValue : 1.f;
}

- (CGLineJoin)lineJoinForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    if ([value isEqualToString:@"round"]) {
        return kCGLineJoinRound;
    }
    if ([value isEqualToString:@"square"]) {
        return kCGLineJoinBevel;
    }
    return kCGLineJoinMiter;
}

- (CGLineCap)lineCapForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    if ([value isEqualToString:@"round"]) {
        return kCGLineCapRound;
    }
    if ([value isEqualToString:@"square"]) {
        return kCGLineCapSquare;
    }
    return kCGLineCapButt;
}

- (CGFloat)miterLimitForKey:(NSString *)key;
{
    NSString *miterLimit = [self valueForKey:key];
    return miterLimit ? miterLimit.floatValue : 10.f;
}

- (NSValue *)transformForKey:(NSString *)key;
{
    NSString *transform = [self valueForKey:key];
    if (!transform) return nil;

    float a, b, c, d, tx, ty;
    NSScanner *floatScanner = [NSScanner scannerWithString:transform];
    [floatScanner scanString:@"matrix(" intoString:NULL];
    [floatScanner scanFloat:&a];
    [floatScanner scanFloat:&b];
    [floatScanner scanFloat:&c];
    [floatScanner scanFloat:&d];
    [floatScanner scanFloat:&tx];
    [floatScanner scanFloat:&ty];
    return [NSValue valueWithCGAffineTransform:CGAffineTransformMake(a, b, c, d, tx, ty)];
}

@end

@interface NSScanner (Utilities)
- (NSString *)initialCharacter;
- (NSString *)currentCharacter;
- (void)conditionallyIncrement;
- (BOOL)scanPoint:(CGPoint *)point;
@end

@implementation NSScanner (Utilities)

- (NSString *)initialCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:0]];
}

- (NSString *)currentCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:self.scanLocation]];
}

- (void)conditionallyIncrement;
{
    if (![self.currentCharacter isEqualToString:@"-"])
        self.scanLocation++;
}

- (BOOL)scanPoint:(CGPoint *)point;
{
    float xCoord;
    float yCoord;
    [self conditionallyIncrement];
    BOOL didScanX = [self scanFloat:&xCoord];
    [self conditionallyIncrement];
    BOOL didScanY = [self scanFloat:&yCoord];
    if (didScanX && didScanY) {
        *point = CGPointMake(xCoord, yCoord);
        return YES;
    }
    return NO;
}

@end

CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

@interface JAMStyledBezierPathFactory ()
@property (nonatomic) NSMutableArray *gradients;
@property CGPoint previousControlPoint;
@end

@implementation JAMStyledBezierPathFactory

#pragma mark - Main Factory

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.gradients = NSMutableArray.new;
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
    JAMSVGGradient *lastGradient = self.gradients.lastObject;
    JAMSVGGradientColorStop *colorStop = JAMSVGGradientColorStop.new;
    colorStop.position = [attributes floatForKey:@"offset"];
    colorStop.color = [self parseStyleColor:attributes[@"style"]];
    [lastGradient.colorStops addObject:colorStop];
}

- (CGRect)getViewboxFromAttributes:(NSDictionary *)attributes;
{
    if (!attributes[@"viewBox"]) return CGRectZero;
    
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
    gradient.gradientTransform = [attributes transformForKey:@"gradientTransform"];
    [self.gradients addObject:gradient];
}

-(void)saveRadialGradient:(NSDictionary *)attributes;
{
    JAMSVGRadialGradient *gradient = JAMSVGRadialGradient.new;
    gradient.identifier = attributes[@"id"];
    gradient.position = CGPointMake([attributes[@"cx"] floatValue], [attributes[@"cy"] floatValue]);
    gradient.radius = [attributes[@"r"] floatValue];
    gradient.gradientTransform = [attributes transformForKey:@"gradientTransform"];
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
    NSArray *commandList = [self commandListForCommandString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
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
    return [self styledPathWithBezierPath:path
                                  opacity:[attributes opacityForKey:@"opacity"]
                                fillColor:[attributes fillColorForKey:@"fill"]
                              strokeColor:[attributes strokeColorForKey:@"stroke"]
                             strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                               miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                             lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                            lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]
                                 gradient:attributes[@"fill"]
                                transform:[attributes transformForKey:@"transform"]];
}

- (JAMStyledBezierPath *)styledPathWithBezierPath:(UIBezierPath *)bezierPath
                                          opacity:(NSNumber *)opacity
                                        fillColor:(UIColor *)fillColor
                                      strokeColor:(UIColor *)strokeColor
                                     strokeWeight:(CGFloat)strokeWeight
                                        dashArray:(NSArray *)dashArray
                                       miterLimit:(CGFloat)miterLimit
                                     lineCapStyle:(CGLineCap)lineCapStyle
                                    lineJoinStyle:(CGLineJoin)lineJoinStyle
                                         gradient:(NSString *)url
                                        transform:(NSValue *)transform;
{
    JAMStyledBezierPath *styledBezierPath = JAMStyledBezierPath.new;
    styledBezierPath.opacity = opacity;
    styledBezierPath.fillColor = fillColor;
    styledBezierPath.strokeColor = strokeColor;
    styledBezierPath.gradient = [self gradientForFillURL:url];
    styledBezierPath.transform = transform;
    
    styledBezierPath.path = bezierPath;
    styledBezierPath.path.lineWidth = strokeWeight;
    styledBezierPath.path.miterLimit = miterLimit;
    styledBezierPath.path.lineJoinStyle = lineJoinStyle;
    styledBezierPath.path.lineCapStyle = lineCapStyle;
    if (dashArray) {
        CGFloat values[dashArray.count];
        
        for (int i = 0; i < dashArray.count; i++)
            values[i] = [dashArray[i] floatValue];
        
        [styledBezierPath.path setLineDash:values count:dashArray.count phase:0.f];
    }
    return styledBezierPath;
}

- (JAMSVGGradient *)gradientForFillURL:(NSString *)fillURL;
{
    
    if ([fillURL rangeOfString:@"url(#"].location != NSNotFound) {
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
    while (!commandScanner.isAtEnd) {
        [commandScanner scanUpToCharactersFromSet:knownCommands intoString:&command];
        NSString *fullCommand = [commandString substringWithRange:NSMakeRange(lastLocation, commandScanner.scanLocation - lastLocation)];
        if (![fullCommand isEqualToString:@""])
            [commandList addObject:fullCommand];
        
        lastLocation = commandScanner.scanLocation;
        if (!commandScanner.isAtEnd)
            commandScanner.scanLocation++;
    }
    return commandList;
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
    [commandScanner conditionallyIncrement];
    [commandScanner scanFloat:&xPosition];
    CGPoint horizontalLineToPoint = CGPointMake(xPosition, path.currentPoint.y);
    
    if ([commandScanner.initialCharacter isEqualToString:@"h"])
        horizontalLineToPoint.x += path.currentPoint.x;
    [path addLineToPoint:horizontalLineToPoint];
}

- (void)addVerticalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    float yPosition;
    [commandScanner conditionallyIncrement];
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
    self.previousControlPoint = controlPoint2;
    [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)addSmoothCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint smoothedPrevious = CGPointSubtractPoints(path.currentPoint, self.previousControlPoint);
    CGPoint controlPoint1 = CGPointAddPoints(path.currentPoint, smoothedPrevious);
    CGPoint controlPoint2 = CGPointZero;
    CGPoint curveToPoint = CGPointZero;
    [commandScanner scanPoint:&controlPoint2];
    [commandScanner scanPoint:&curveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"s"]) {
        curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
        controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
    }
    self.previousControlPoint = controlPoint2;
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

@end
