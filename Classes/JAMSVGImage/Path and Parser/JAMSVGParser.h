/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

/** JAMSVGParser uses NSXMLParser to parse SVG documents and extract graphic data. The end result is an array of JAMStyledBezierPaths that are used by JAMSVGImage and JAMSVGImageView to draw these resolution-independent vector graphics. */
@interface JAMSVGParser : NSObject

/** The array of JAMStyledBezierPaths. */
@property (nonatomic) NSMutableArray *paths;
/** The viewBox from the SVG document. This is used to configure the JAMSVGImage size property. */
@property (nonatomic) CGRect viewBox;

/** Initializers for file path and data. */
- (id)initWithSVGDocument:(NSString *)path;
- (id)initWithSVGData:(NSData *)data;

/** Triggers the parsing of the SVG XML data. */
- (BOOL)parseSVGDocument;

@end
