//
//  JAMSVGGradientParts.h
//  JAMSVGImage
//
//  Created by Jeff Menter on 4/7/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAMSVGGradient : NSObject
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *colorStops;
@end

@interface JAMSVGLinearGradient : JAMSVGGradient
@property CGPoint startPosition;
@property CGPoint endPosition;
@end

@interface JAMSVGRadialGradient : JAMSVGGradient
@property CGPoint position;
@property CGFloat radius;
@end

@interface JAMSVGGradientColorStop : NSObject
@property (nonatomic) UIColor *color;
@property CGFloat position;
@end
