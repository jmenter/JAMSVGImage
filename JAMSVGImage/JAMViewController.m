
#import "JAMViewController.h"
#import "JAMView.h"
#import "JAMSVGImage.h"
#import "JAMSVGImageView.h"

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
    
    JAMSVGImage *svgImage = [JAMSVGImage imageNamed:@"face"];
    JAMSVGImageView *svgImageView = [JAMSVGImageView.alloc initWithSVGImage:[JAMSVGImage imageNamed:@"face"]];
    svgImageView.frame = CGRectMake(20, 20, svgImage.size.width, svgImage.size.height);
    [self.view addSubview:svgImageView];
}

@end
