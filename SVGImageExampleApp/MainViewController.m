
#import "MainViewController.h"
#import "JAMSVGImageView.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet JAMSVGImageView *tigerImageView;
@end

@implementation MainViewController

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    CGPoint location = [touches.anyObject locationInView:self.view];
    self.tigerImageView.frame = CGRectMake(self.tigerImageView.frame.origin.x, self.tigerImageView.frame.origin.y,
                                           location.x - self.tigerImageView.frame.origin.x, location.y - self.tigerImageView.frame.origin.y);
}

@end
