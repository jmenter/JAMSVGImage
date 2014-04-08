//
//  JAMSVGGradientParts.m
//  JAMSVGImage
//
//  Created by Jeff Menter on 4/7/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import "JAMSVGGradientParts.h"

@implementation JAMSVGGradient

- (NSMutableArray *)colorStops;
{
    if (!_colorStops) _colorStops = NSMutableArray.new;
    return _colorStops;
}

@end

@implementation JAMSVGGradientColorStop
@end

@implementation JAMSVGLinearGradient
@end

@implementation JAMSVGRadialGradient
@end