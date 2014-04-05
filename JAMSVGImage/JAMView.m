
#import "JAMView.h"
#import "JAMSVGImage.h"

@implementation JAMView

- (void)drawRect:(CGRect)rect
{
    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];
    [tiger drawAtPoint:CGPointMake(50, 50)];
    [tiger drawInRect:CGRectMake(100, 100, 500, 20)];
    
    JAMSVGImage *face = [JAMSVGImage imageNamed:@"face"];
    face.scale = 0.5;
    UIImage *faceImage = face.image;

    [faceImage drawInRect:CGRectMake(150, 150, 256, 256)];
}

@end
