
#import "JAMViewController.h"

@implementation JAMViewController

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    CGPoint center = self.svgImageView.center;
    center.x += ([touches.anyObject locationInView:self.view].x - [touches.anyObject previousLocationInView:self.view].x);
    center.y += ([touches.anyObject locationInView:self.view].y - [touches.anyObject previousLocationInView:self.view].y);
    self.svgImageView.center = center;
}

- (IBAction)sliderSlid:(UISlider *)sender
{
    CGPoint center = self.svgImageView.center;
    CGRect frame = self.svgImageView.frame;
    frame.size.width = sender.value;
    frame.size.height = sender.value;
    self.svgImageView.frame = frame;
    self.svgImageView.center = center;
}

@end
