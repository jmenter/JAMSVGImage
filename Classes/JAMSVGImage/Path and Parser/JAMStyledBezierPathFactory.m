/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMStyledBezierPathFactory.h"
#import "JAMStyledBezierPath.h"
#import "JAMSVGGradientParts.h"
#import "JAMSVGUtilities.h"

#pragma mark - Private path properties.

@interface JAMStyledBezierPath (Private)
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) JAMSVGGradient *gradient;
@property (nonatomic) NSValue *transform;
@property (nonatomic) NSNumber *opacity;
@end

@interface JAMStyledBezierPathFactory ()
@property (nonatomic) NSMutableArray *gradients;
@property CGPoint previousCurveOperationControlPoint;
@property (nonatomic) NSNumber *groupOpacityValue;
@property (nonatomic) NSMutableArray *affineTransformStack;
@property (nonatomic) NSMutableArray *groupAppearanceStack;
@end

@implementation JAMStyledBezierPathFactory

#pragma mark - Main Factory

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.gradients = NSMutableArray.new;
    self.affineTransformStack = NSMutableArray.new;
    self.groupAppearanceStack = NSMutableArray.new;
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
        return [self polyWithAttributes:attributes closed:NO];
    
    if ([elementName isEqualToString:@"polygon"])
        return [self polyWithAttributes:attributes closed:YES];
    
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
    if (colorStop.position > 1) {
        colorStop.position /= 100.f;
    }
    UIColor *stopColor;
    if (attributes[@"stop-color"]) {
        stopColor = [UIColor colorFromString:attributes[@"stop-color"]];
        if (attributes[@"stop-opacity"]) {
            stopColor = [stopColor colorWithAlphaComponent:[attributes[@"stop-opacity"] floatValue]];
        }
    } else if (attributes[@"style"]) {
        stopColor = [self parseStyleColor:attributes[@"style"]];
    }
    colorStop.color = stopColor;
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

- (void)pushGroupAppearanceWithAttributes:(NSDictionary *)attributes;
{
    [self.groupAppearanceStack addObject:attributes];
}

- (void)popGroupAppearance;
{
    [self.groupAppearanceStack removeLastObject];
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
            // No viewbox or width or height? I guess that's possible. Either way, we need a viewBox of some kind.
            return CGRectMake(0, 0, 256, 256);
        }
    }
    
    CGFloat xPosition, yPosition, width, height;
    NSScanner *viewBoxScanner = [NSScanner scannerWithString:attributes[@"viewBox"]];
    
    [viewBoxScanner scanCGFloat:&xPosition];
    [viewBoxScanner scanCGFloat:&yPosition];
    [viewBoxScanner scanCGFloat:&width];
    [viewBoxScanner scanCGFloat:&height];
    
    return CGRectMake(xPosition, yPosition, width, height);
}

- (UIColor *)parseStyleColor:(NSString *)styleColor;
{
    UIColor *color;
    NSScanner *colorScanner = [NSScanner scannerWithString:styleColor];
    if ([colorScanner scanString:@"stop-color:" intoString:NULL]) {
        color = [UIColor colorFromString:[styleColor substringFromIndex:colorScanner.scanLocation]];
    };
    if ([colorScanner scanUpToString:@"stop-opacity:" intoString:NULL]) {
        [colorScanner scanString:@"stop-opacity:" intoString:NULL];
        CGFloat opacity = 1;
        [colorScanner scanCGFloat:&opacity];
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
    NSArray *commandList = [self commandListForCommandString:commandString.stringByTrimmingWhitespace];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    commandListPath.usesEvenOddFillRule = [attributes[@"fill-rule"] isEqualToString:@"evenodd"];
    return [self createStyledPath:commandListPath withAttributes:attributes];
}

- (JAMStyledBezierPath *)polyWithAttributes:(NSDictionary *)attributes closed:(BOOL)closed;
{
    NSString *commandString = attributes[@"points"];
    NSArray *commandList = [self commandListForPolylineString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    if (closed) {
        [commandListPath closePath];
    }
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

- (NSDictionary *)attributesByAddingGroupAttributesToAttributes:(NSDictionary *)attributes;
{
    NSMutableDictionary *concatenatedAppearance = NSMutableDictionary.new;

    // Grab group level attributes from the stack, replacing as we nest in.
    for (NSDictionary *groupLevelAttributes in self.groupAppearanceStack) {
        [groupLevelAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            concatenatedAppearance[key] = obj;
        }];
    }
    // Use the final appearances from the object, if any.
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        concatenatedAppearance[key] = obj;
    }];

    return concatenatedAppearance.copy;
}

- (NSDictionary *)attributesByApplyingStyleAttributeToAttributes:(NSDictionary *)attributes;
{
    if (!attributes[@"style"]) { return attributes; }
    
    // These attributes come via the "style" attribute rather than directly attached to the path.
    NSMutableDictionary *appliedAttributes = attributes.mutableCopy;
    NSScanner *attributeNameScanner = [NSScanner scannerWithString:attributes[@"style"]];
    
    while (!attributeNameScanner.isAtEnd) {
        NSString *attributeName;
        NSString *attributeValue;
        if ([attributeNameScanner scanUpToString:@":" intoString:&attributeName]) {
            attributeNameScanner.scanLocation++;
            if ([attributeNameScanner scanUpToString:@";" intoString:&attributeValue]) {
                appliedAttributes[attributeName.stringByTrimmingWhitespace] = attributeValue.stringByTrimmingWhitespace;
            }
            if (!attributeNameScanner.isAtEnd) {
                attributeNameScanner.scanLocation++;
            }
        } else {
            if (!attributeNameScanner.isAtEnd) {
                attributeNameScanner.scanLocation++;
            }
        }
    }
    return appliedAttributes.copy;
}

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
    attributes = [self attributesByAddingGroupAttributesToAttributes:attributes];
    attributes = [self attributesByApplyingStyleAttributeToAttributes:attributes];
    
    NSString *fillColorString = ((NSString *)attributes[@"fill"]).lowercaseString;
    NSString *strokeColorString = ((NSString *)attributes[@"stroke"]).lowercaseString;
    NSString *fillColorStringValue = self.webColors[fillColorString];
    NSString *strokeColorStringValue = self.webColors[strokeColorString];
    UIColor *fillColor = fillColorStringValue ? [UIColor colorFromString:fillColorStringValue] : [attributes fillColorForKey:@"fill"];
    UIColor *strokeColor = strokeColorStringValue ? [UIColor colorFromString:strokeColorStringValue] : [attributes strokeColorForKey:@"stroke"];
    
    return [JAMStyledBezierPath styledPathWithPath:[self applyStrokeAttributes:attributes toPath:path]
                                         fillColor:fillColor
                                       strokeColor:strokeColor
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
    // TODO: Not sure if this is really how multiple opacities stack up with each other.
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
    commandString = commandString.stringByTrimmingWhitespace;
    // Add an extra z if the last command is a close command. A little hacky but prevents missing out on final Zs.
    if ([@[@"Z", @"z"] containsObject:commandString.lastCharacter]) {
        commandString = [commandString stringByAppendingString:@"z"];
    }
    NSScanner *commandScanner = [NSScanner scannerWithString:commandString];
    NSCharacterSet *knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz#"];
    NSMutableArray *commandList = NSMutableArray.new;
    
    NSString *command;
    NSUInteger lastLocation = 0;
    while (!commandScanner.isAtEnd)
    {
        [commandScanner scanUpToCharactersFromSet:knownCommands intoString:&command];
        NSString *fullCommand = [commandString substringWithRange:NSMakeRange(lastLocation, commandScanner.scanLocation - lastLocation)];
        NSString *trimmedFullCommand = [fullCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedFullCommand isEqualToString:@""] && ![trimmedFullCommand.firstCharacter isEqualToString:@"#"])
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

    NSScanner *scanner = [NSScanner scannerWithString:polylineString];
    while(!scanner.atEnd) {
        float x = 0, y = 0;
        BOOL didScanX = [scanner scanFloatAndAdvance:&x];
        BOOL didScanY = [scanner scanFloatAndAdvance:&y];

        if(didScanX && didScanY) {
            char commandChar = commandList.count == 0 ? 'M' : 'L';
            NSString *commandString = [NSString stringWithFormat:@"%c%f,%f", commandChar, x, y];
            [commandList addObject:commandString];
         } else {
             break;
         }
    }
    return commandList;
}

- (UIBezierPath *)bezierPathFromCommandList:(NSArray *)commandList;
{
    UIBezierPath *path = UIBezierPath.new;
    self.previousCurveOperationControlPoint = CGPointZero;
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

        else if ([@[@"T", @"t"] containsObject:commandScanner.currentCharacter])
            [self addSmoothQuadCurveToPointFromCommandScanner:commandScanner toPath:path];

        else if ([@[@"A", @"a"] containsObject:commandScanner.currentCharacter])
            [self addEllipticalArcToPointFromCommandScanner:commandScanner toPath:path];
        
        else if ([@[@"Z", @"z"] containsObject:commandScanner.currentCharacter]) {
            [path closePath];
            
        }
    }
    return path;
}

#pragma mark - Path Command Methods

- (void)addMoveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"m"];
    CGPoint scannedPoint = CGPointZero;
    if ([commandScanner scanPoint:&scannedPoint]) {
        if (path.isEmpty) {
            [path moveToPoint:scannedPoint];
        } else {
            [path moveToPoint:relative ? CGPointAddPoints(scannedPoint, path.currentPoint) : scannedPoint];
        }
    };
    
    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&scannedPoint]) {
            [path addLineToPoint:relative ? CGPointAddPoints(scannedPoint, path.currentPoint) : scannedPoint];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"l"];
    CGPoint scannedPoint = CGPointZero;

    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&scannedPoint]) {
            [path addLineToPoint:relative ? CGPointAddPoints(scannedPoint, path.isEmpty ? CGPointZero : path.currentPoint) : scannedPoint];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addHorizontalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"h"];
    CGFloat xPosition;
    [commandScanner scanThroughToHyphen];
    
    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanCGFloat:&xPosition]) {
            xPosition += (relative) ? path.currentPoint.x : 0;
            [path addLineToPoint:CGPointMake(xPosition, path.currentPoint.y)];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addVerticalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"v"];
    CGFloat yPosition;
    [commandScanner scanThroughToHyphen];
    
    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanCGFloat:&yPosition]) {
            yPosition += (relative) ? path.currentPoint.y : 0;
            [path addLineToPoint:CGPointMake(path.currentPoint.x, yPosition)];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    if (CGPointEqualToPoint(self.previousCurveOperationControlPoint, CGPointZero)) {
        self.previousCurveOperationControlPoint = path.currentPoint;
    }
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"c"];
    CGPoint curveToPoint = CGPointZero;
    CGPoint controlPoint1 = CGPointZero;
    CGPoint controlPoint2 = CGPointZero;

    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&controlPoint1] &&
            [commandScanner scanPoint:&controlPoint2] &&
            [commandScanner scanPoint:&curveToPoint]) {
            if (relative) {
                curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
                controlPoint1 = CGPointAddPoints(controlPoint1, path.currentPoint);
                controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
            }
            self.previousCurveOperationControlPoint = controlPoint2;
            [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addSmoothCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    if (CGPointEqualToPoint(self.previousCurveOperationControlPoint, CGPointZero)) {
        self.previousCurveOperationControlPoint = path.currentPoint;
    }
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"s"];
    CGPoint controlPoint2 = CGPointZero;
    CGPoint curveToPoint = CGPointZero;

    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&controlPoint2] && [commandScanner scanPoint:&curveToPoint]) {
            CGPoint smoothedPrevious = CGPointSubtractPoints(path.currentPoint, self.previousCurveOperationControlPoint);
            CGPoint controlPoint1 = CGPointAddPoints(path.currentPoint, smoothedPrevious);
            if (relative) {
                curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
                controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
            }
            self.previousCurveOperationControlPoint = controlPoint2;
            [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addQuadCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    if (CGPointEqualToPoint(self.previousCurveOperationControlPoint, CGPointZero)) {
        self.previousCurveOperationControlPoint = path.currentPoint;
    }
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"q"];
    CGPoint controlPoint = CGPointZero;
    CGPoint quadCurveToPoint = CGPointZero;
    
    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&controlPoint] && [commandScanner scanPoint:&quadCurveToPoint]) {
            if (relative) {
                controlPoint = CGPointAddPoints(controlPoint, path.currentPoint);
                quadCurveToPoint = CGPointAddPoints(quadCurveToPoint, path.currentPoint);
            }
            self.previousCurveOperationControlPoint = controlPoint;
            [path addQuadCurveToPoint:quadCurveToPoint controlPoint:controlPoint];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }
}

- (void)addSmoothQuadCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    if (CGPointEqualToPoint(self.previousCurveOperationControlPoint, CGPointZero)) {
        self.previousCurveOperationControlPoint = path.currentPoint;
    }
    BOOL relative = [commandScanner.initialCharacter isEqualToString:@"t"];
    CGPoint quadCurveToPoint = CGPointZero;

    while (!commandScanner.isAtEnd) {
        if ([commandScanner scanPoint:&quadCurveToPoint]) {
            if (relative) {
                quadCurveToPoint = CGPointAddPoints(quadCurveToPoint, path.currentPoint);
            }
            CGPoint controlPoint = CGPointAddPoints(path.currentPoint, CGPointSubtractPoints(path.currentPoint, self.previousCurveOperationControlPoint));
            self.previousCurveOperationControlPoint = controlPoint;
            [path addQuadCurveToPoint:quadCurveToPoint controlPoint:controlPoint];
        } else {
            if (!commandScanner.isAtEnd) {
                commandScanner.scanLocation++;
            }
        }
    }    
}

- (void)addEllipticalArcToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    while (!commandScanner.isAtEnd) {
        CGPoint radii = CGPointZero;
        CGPoint arcEndPoint = CGPointZero;
        CGPoint arcStartPoint = path.currentPoint;
        CGFloat xAxisRotation = 0;
        BOOL largeArcFlag = 0;
        BOOL sweepFlag = 0;
        
        BOOL didScanRadii = [commandScanner scanPoint:&radii];
        BOOL didScanXAxisRotation = [commandScanner scanCGFloat:&xAxisRotation];
        BOOL didScanLargeArcFlag = [commandScanner scanBool:&largeArcFlag];
        BOOL didScanSweepFlag = [commandScanner scanBool:&sweepFlag];
        BOOL didScanArcEndPoint = [commandScanner scanPoint:&arcEndPoint];
        
        if (!(didScanRadii && didScanXAxisRotation && didScanLargeArcFlag && didScanSweepFlag && didScanArcEndPoint)) {
            return;
        }
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
        
        if (!commandScanner.isAtEnd) {
            commandScanner.scanLocation++;
        }
    }
}

- (NSDictionary *)webColors;
{
    return @{@"aliceblue" : @"#f0f8ff",
             @"antiquewhite" : @"#faebd7",
             @"aqua" : @"#00ffff",
             @"aquamarine" : @"#7fffd4",
             @"azure" : @"#f0ffff",
             @"beige" : @"#f5f5dc",
             @"bisque" : @"#ffe4c4",
             @"black" : @"#000000",
             @"blanchedalmond" : @"#ffebcd",
             @"blue" : @"#0000ff",
             @"blueviolet" : @"#8a2be2",
             @"brown" : @"#a52a2a",
             @"burlywood" : @"#deb887",
             @"cadetblue" : @"#5f9ea0",
             @"chartreuse" : @"#7fff00",
             @"chocolate" : @"#d2691e",
             @"coral" : @"#ff7f50",
             @"cornflowerblue" : @"#6495ed",
             @"cornsilk" : @"#fff8dc",
             @"crimson" : @"#dc143c",
             @"cyan" : @"#00ffff",
             @"darkblue" : @"#00008b",
             @"darkcyan" : @"#008b8b",
             @"darkgoldenrod" : @"#b8860b",
             @"darkgray" : @"#a9a9a9",
             @"darkgreen" : @"#006400",
             @"darkkhaki" : @"#bdb76b",
             @"darkmagenta" : @"#8b008b",
             @"darkolivegreen" : @"#556b2f",
             @"darkorange" : @"#ff8c00",
             @"darkorchid" : @"#9932cc",
             @"darkred" : @"#8b0000",
             @"darksalmon" : @"#e9967a",
             @"darkseagreen" : @"#8fbc8f",
             @"darkslateblue" : @"#483d8b",
             @"darkslategray" : @"#2f4f4f",
             @"darkturquoise" : @"#00ced1",
             @"darkviolet" : @"#9400d3",
             @"deeppink" : @"#ff1493",
             @"deepskyblue" : @"#00bfff",
             @"dimgray" : @"#696969",
             @"dodgerblue" : @"#1e90ff",
             @"firebrick" : @"#b22222",
             @"floralwhite" : @"#fffaf0",
             @"forestgreen" : @"#228b22",
             @"fuchsia" : @"#ff00ff",
             @"gainsboro" : @"#dcdcdc",
             @"ghostwhite" : @"#f8f8ff",
             @"gold" : @"#ffd700",
             @"goldenrod" : @"#daa520",
             @"gray" : @"#808080",
             @"green" : @"#008000",
             @"greenyellow" : @"#adff2f",
             @"honeydew" : @"#f0fff0",
             @"hotpink" : @"#ff69b4",
             @"indianred " : @"#cd5c5c",
             @"indigo " : @"#4b0082",
             @"ivory" : @"#fffff0",
             @"khaki" : @"#f0e68c",
             @"lavender" : @"#e6e6fa",
             @"lavenderblush" : @"#fff0f5",
             @"lawngreen" : @"#7cfc00",
             @"lemonchiffon" : @"#fffacd",
             @"lightblue" : @"#add8e6",
             @"lightcoral" : @"#f08080",
             @"lightcyan" : @"#e0ffff",
             @"lightgoldenrodyellow" : @"#fafad2",
             @"lightgray" : @"#d3d3d3",
             @"lightgreen" : @"#90ee90",
             @"lightpink" : @"#ffb6c1",
             @"lightsalmon" : @"#ffa07a",
             @"lightseagreen" : @"#20b2aa",
             @"lightskyblue" : @"#87cefa",
             @"lightslategray" : @"#778899",
             @"lightsteelblue" : @"#b0c4de",
             @"lightyellow" : @"#ffffe0",
             @"lime" : @"#00ff00",
             @"limegreen" : @"#32cd32",
             @"linen" : @"#faf0e6",
             @"magenta" : @"#ff00ff",
             @"maroon" : @"#800000",
             @"mediumaquamarine" : @"#66cdaa",
             @"mediumblue" : @"#0000cd",
             @"mediumorchid" : @"#ba55d3",
             @"mediumpurple" : @"#9370db",
             @"mediumseagreen" : @"#3cb371",
             @"mediumslateblue" : @"#7b68ee",
             @"mediumspringgreen" : @"#00fa9a",
             @"mediumturquoise" : @"#48d1cc",
             @"mediumvioletred" : @"#c71585",
             @"midnightblue" : @"#191970",
             @"mintcream" : @"#f5fffa",
             @"mistyrose" : @"#ffe4e1",
             @"moccasin" : @"#ffe4b5",
             @"navajowhite" : @"#ffdead",
             @"navy" : @"#000080",
             @"oldlace" : @"#fdf5e6",
             @"olive" : @"#808000",
             @"olivedrab" : @"#6b8e23",
             @"orange" : @"#ffa500",
             @"orangered" : @"#ff4500",
             @"orchid" : @"#da70d6",
             @"palegoldenrod" : @"#eee8aa",
             @"palegreen" : @"#98fb98",
             @"paleturquoise" : @"#afeeee",
             @"palevioletred" : @"#db7093",
             @"papayawhip" : @"#ffefd5",
             @"peachpuff" : @"#ffdab9",
             @"peru" : @"#cd853f",
             @"pink" : @"#ffc0cb",
             @"plum" : @"#dda0dd",
             @"powderblue" : @"#b0e0e6",
             @"purple" : @"#800080",
             @"red" : @"#ff0000",
             @"rosybrown" : @"#bc8f8f",
             @"royalblue" : @"#4169e1",
             @"saddlebrown" : @"#8b4513",
             @"salmon" : @"#fa8072",
             @"sandybrown" : @"#f4a460",
             @"seagreen" : @"#2e8b57",
             @"seashell" : @"#fff5ee",
             @"sienna" : @"#a0522d",
             @"silver" : @"#c0c0c0",
             @"skyblue" : @"#87ceeb",
             @"slateblue" : @"#6a5acd",
             @"slategray" : @"#708090",
             @"snow" : @"#fffafa",
             @"springgreen" : @"#00ff7f",
             @"steelblue" : @"#4682b4",
             @"tan" : @"#d2b48c",
             @"teal" : @"#008080",
             @"thistle" : @"#d8bfd8",
             @"tomato" : @"#ff6347",
             @"turquoise" : @"#40e0d0",
             @"violet" : @"#ee82ee",
             @"wheat" : @"#f5deb3",
             @"white" : @"#ffffff",
             @"whitesmoke" : @"#f5f5f5",
             @"yellow" : @"#ffff00",
             @"yellowgreen" : @"#9acd32"};
}

@end
