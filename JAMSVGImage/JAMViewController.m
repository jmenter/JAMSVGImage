
#import "JAMViewController.h"
#import "JAMSVGImageView.h"

@interface JAMViewController ()
@property (nonatomic) JAMSVGImageView *svgImageView;
@end
@implementation JAMViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    JAMSVGImage *image = [JAMSVGImage imageNamed:@"spring_tree_final"];
    self.svgImageView = [JAMSVGImageView.alloc initWithSVGImage:image];
    self.svgImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.svgImageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.svgImageView.frame = CGRectMake(0, 0, [touches.anyObject locationInView:self.view].x, [touches.anyObject locationInView:self.view].y);
}

@end
