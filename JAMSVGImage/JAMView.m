//
//  JAMView.m
//  JAMSVGImage
//
//  Created by Jeff Menter on 4/4/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import "JAMView.h"
#import "JAMSVGImage.h"

@implementation JAMView

- (void)drawRect:(CGRect)rect
{
    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];
    JAMSVGImage *face = [JAMSVGImage imageNamed:@"face"];
    face.scale = 0.5;
    UIImage *faceImage = face.image;

    [faceImage drawInRect:CGRectMake(20, 20, 256, 256)];
//    [tiger drawAtPoint:CGPointMake(50, 50)];
//    [tiger drawInRect:CGRectMake(100, 100, 20, 100)];
}

@end
