//
//  JAMViewController.m
//  JAMSVGImage
//
//  Created by Jeff Menter on 4/4/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import "JAMViewController.h"
#import "JAMSVGImage.h"
#import "JAMSVGImageView.h"

@interface JAMViewController ()

@end

@implementation JAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JAMSVGImage *svgImage = [JAMSVGImage imageNamed:@"face"];
    JAMSVGImageView *svgImageView = [JAMSVGImageView.alloc initWithSVGImage:svgImage];
    svgImageView.frame = CGRectMake(20, 20, svgImage.size.width, svgImage.size.height);
    [self.view addSubview:svgImageView];
}

@end
