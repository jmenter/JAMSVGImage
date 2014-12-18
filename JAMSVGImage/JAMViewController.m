
#import "JAMViewController.h"

@implementation JAMViewController

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.svgImageView.frame = CGRectMake(0, 0, [touches.anyObject locationInView:self.view].x, [touches.anyObject locationInView:self.view].y);
}

@end
