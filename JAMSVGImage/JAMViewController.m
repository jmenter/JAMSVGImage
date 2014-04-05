
#import "JAMViewController.h"
#import "JAMView.h"
#import "JAMSVGImage.h"
#import "JAMSVGImageView.h"

@interface JAMViewController ()
@property (nonatomic) JAMSVGImageView *svgImageView;
@end
@implementation JAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JAMView *view = [JAMView.alloc initWithFrame:CGRectMake(0, 320, 320, 320)];
    view.backgroundColor = UIColor.darkGrayColor;
    [self.view addSubview:view];
    self.view.backgroundColor = UIColor.lightGrayColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JAMSVGImage *svgImage = [JAMSVGImage imageNamed:@"tiger"];
    self.svgImageView = [JAMSVGImageView.alloc initWithSVGImage:svgImage];
    self.svgImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.svgImageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.svgImageView.frame = CGRectMake(0, 0, [touch locationInView:self.view].x, [touch locationInView:self.view].y);
}

@end
