
#import "JAMViewController.h"
#import "JAMSVGImage.h"
#import "JAMSVGImageView.h"

@interface JAMView : UIView
@end

@implementation JAMView
- (void)drawRect:(CGRect)rect
{
    // Draw the tiger three different ways.
    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
//    [tiger drawInCurrentContext];
    [tiger drawAtPoint:CGPointMake(50, 50)];
//    [tiger drawInRect:CGRectMake(100, 100, 500, 20)];
    
    // Get a low res image from the svg and blow that up, shows what happens when you upsize raster images.
//    JAMSVGImage *face = [JAMSVGImage imageNamed:@"gradients"];
//    face.scale = 0.5;
//    UIImage *faceImage = face.image;
//    
//    [faceImage drawInRect:CGRectMake(150, 150, 256, 256)];
}
@end


@interface JAMViewController ()
@property (nonatomic) JAMSVGImageView *svgImageView;
@end
@implementation JAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JAMView *view = [JAMView.alloc initWithFrame:CGRectMake(0, 10, 320, 320)];
    view.backgroundColor = UIColor.darkGrayColor;
//    [self.view addSubview:view];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSData *cloudData = [self.cloudString dataUsingEncoding:NSUTF8StringEncoding];
//    JAMSVGImage *svgImage = [JAMSVGImage imageWithSVGData:cloudData];
    JAMSVGImage *svgImage = [JAMSVGImage imageNamed:@"curvy"];
    self.svgImageView = [JAMSVGImageView.alloc initWithSVGImage:svgImage];
    self.svgImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.svgImageView];
//    UIImage *tigerImage = svgImage.image;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.svgImageView.frame = CGRectMake(0, 0, [touch locationInView:self.view].x, [touch locationInView:self.view].y);
}

- (NSString *)cloudString;
{
    return @"<?xml version='1.0' encoding='utf-8'?><!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><svg version='1.1' id='Layer_1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px'	 width='512px' height='512px' viewBox='0 0 512 512' enable-background='new 0 0 512 512' xml:space='preserve'><path fill='#F5FBFE' stroke='#231F20' stroke-width='15' stroke-linecap='round' stroke-linejoin='round' stroke-miterlimit='10' d='	M466.575,272.406c0-43.174-35-78.173-78.173-78.173c-10.014,0-19.577,1.903-28.377,5.334	c-3.213-57.275-50.663-102.733-108.742-102.733c-60.159,0-108.93,48.77-108.93,108.93c0,6.079,0.521,12.034,1.479,17.842	c-8.418-3.234-17.552-5.025-27.107-5.025c-41.758,0-75.609,33.851-75.609,75.608c0,41.758,33.852,75.609,75.609,75.609	c12.679,0,24.62-3.137,35.115-8.652c8.926,29.479,36.294,50.941,68.686,50.941c31.793,0,58.739-20.68,68.164-49.316	c13.521,23.348,38.755,39.064,67.676,39.064c38.896,0,71.144-28.41,77.153-65.609C453.513,322.064,466.575,298.768,466.575,272.406z	'/><path fill='#B2E3EB' d='M339.706,373.646c-5.698,0-11.236-0.674-16.558-1.908c8.701,6.043,19.26,9.592,30.654,9.592	c29.726,0,53.823-24.098,53.823-53.822c0-0.01,0-0.02,0-0.029C396.916,354.516,370.554,373.646,339.706,373.646z'/><path fill='#B2E3EB' d='M258.11,359.562c-12.848,11.366-29.297,18.895-47.694,20.547c-4.984,0.449-9.898,0.422-14.714,0.006	c7.589,6.478,17.674,10.021,28.397,9.059C241.072,387.646,254.463,375.305,258.11,359.562z'/><path fill='#231F20' d='M253.846,198.996c0,4.954-4.016,8.97-8.97,8.97l0,0c-4.954,0-8.97-4.016-8.97-8.97v-39.492	c0-4.954,4.016-8.97,8.97-8.97l0,0c4.954,0,8.97,4.016,8.97,8.97V198.996z'/><path fill='#231F20' d='M299.115,198.996c0,4.954-4.016,8.97-8.97,8.97l0,0c-4.954,0-8.97-4.016-8.97-8.97v-39.492	c0-4.954,4.016-8.97,8.97-8.97l0,0c4.954,0,8.97,4.016,8.97,8.97V198.996z'/></svg>";
}

@end
