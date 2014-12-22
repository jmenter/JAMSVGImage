/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGParser.h"
#import "JAMStyledBezierPath.h"
#import "JAMStyledBezierPathFactory.h"
#import "JAMSVGUtilities.h"

@interface JAMStyledBezierPathFactory (Private)
@property (nonatomic) NSNumber *groupOpacityValue;
- (void)addGroupOpacityValueWithAttributes:(NSDictionary *)attributes;
- (void)removeGroupOpacityValue;
- (void)pushGroupTransformWithAttributes:(NSDictionary *)attributes;
- (void)popGroupTransform;
- (void)pushGroupAppearanceWithAttributes:(NSDictionary *)attributes;
- (void)popGroupAppearance;
@end

@interface JAMSVGParser () <NSXMLParserDelegate>
@property (nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) JAMStyledBezierPathFactory *pathFactory;
@property NSUInteger groupLevel;
@property (nonatomic) NSMutableDictionary *groupTransforms;
@property (nonatomic) NSMutableDictionary *groupAppearances;
@end

@implementation JAMSVGParser

- (id)initWithSVGDocument:(NSString *)path;
{
    if (!(self = [super init]) || !path) return nil;
    
    NSData *fileData;
    NSError *error;
    if ([path.lastPathComponent.pathExtension isEqualToString:@"svgz"]) {
        fileData = [[NSData dataWithContentsOfFile:path] gunzip:&error];
        if (error) {
            NSLog(@"error gunzipping svgz: %@, error: %@", path, error);
            return nil;
        }
    } else {
        fileData = [NSData dataWithContentsOfFile:path];
    }
    return [self initWithSVGData:fileData];
}

- (id)initWithSVGData:(NSData *)data;
{
    if (!(self = [super init]) || !data) return nil;
    
    self.xmlParser = [NSXMLParser.alloc initWithData:data];
    self.xmlParser.delegate = self;
    self.paths = NSMutableArray.new;
    self.pathFactory = JAMStyledBezierPathFactory.new;
    self.groupLevel = 0;
    self.groupTransforms = NSMutableDictionary.new;
    self.groupAppearances = NSMutableDictionary.new;
    return self;
}

- (BOOL)parseSVGDocument;
{
    BOOL success = [self.xmlParser parse];
    if (self.xmlParser.parserError)
        NSLog(@"parserError: %@", self.xmlParser.parserError);

    return success;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"svg"]) {
        self.viewBox = [self.pathFactory getViewboxFromAttributes:attributeDict];
        return;
    }
    if ([elementName isEqualToString:@"stop"]) {
        [self.pathFactory addGradientStopWithAttributes:attributeDict];
        return;
    }
    if ([elementName isEqualToString:@"g"]) {
        self.groupLevel++;
        [self.pathFactory addGroupOpacityValueWithAttributes:attributeDict];
        self.groupAppearances[@(self.groupLevel)] = attributeDict;
        [self.pathFactory pushGroupAppearanceWithAttributes:attributeDict];
        if (attributeDict[@"transform"]) {
            self.groupTransforms[@(self.groupLevel)] = attributeDict;
            [self.pathFactory pushGroupTransformWithAttributes:attributeDict];
        }
    }
    JAMStyledBezierPath *path = [self.pathFactory styledPathFromElementName:elementName attributes:attributeDict];
    if (path) {
        [self.paths addObject:path];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"g"]) {
        if (self.groupTransforms[@(self.groupLevel)]) {
            [self.pathFactory popGroupTransform];
            [self.groupTransforms removeObjectForKey:@(self.groupLevel)];
        }
        
        if (self.groupAppearances[@(self.groupLevel)]) {
            [self.pathFactory popGroupAppearance];
            [self.groupAppearances removeObjectForKey:@(self.groupLevel)];
        }
        
        [self.pathFactory removeGroupOpacityValue];
        self.groupLevel--;
    }
}

@end
