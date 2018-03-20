
#import "TestViewController.h"
#import "JAMSVGImageView.h"
#import "SplitImageView.h"

@interface TestViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet SplitImageView *splitImageView;
@property (nonatomic) NSArray <NSString *> *svgFilePaths;
@property (nonatomic) UIWebView *webView;
@end

@implementation TestViewController

static const CGFloat kTestWidth = 480;
static const CGFloat kTestHeight = 360;

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.svgFilePaths = [[NSBundle.mainBundle pathsForResourcesOfType:@"svg" inDirectory:nil]
                         sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.webView = [UIWebView.alloc initWithFrame:CGRectMake(0, 0, kTestWidth, kTestHeight)];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = self.splitImageView.backgroundColor;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self loadImageAtPath:self.svgFilePaths.firstObject];
}

- (void)loadImageAtPath:(NSString *)imagePath;
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:imagePath]]];
    self.splitImageView.leftImage = [[JAMSVGImage imageNamed:imagePath.lastPathComponent.stringByDeletingPathExtension]
                                     imageAtSize:CGSizeMake(kTestWidth, kTestHeight)];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    UIGraphicsBeginImageContextWithOptions(webView.frame.size, YES, 0);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.splitImageView.rightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.svgFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = UITableViewCell.new;
    cell.textLabel.text = self.svgFilePaths[indexPath.row].lastPathComponent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self loadImageAtPath:self.svgFilePaths[indexPath.row]];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender;
{
    self.splitImageView.contentMode = sender.selectedSegmentIndex;
}

- (IBAction)dismiss;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)wat;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"What These Tests" message:@"\nThese tests show that JAMSVGImage will render an SVG's path elements exactly the same as a canonical SVG renderer such as the one used by a UIWebView.\n\nTap an svg in the list to load it up.\n\nThe JAMSVGImage is rendered on the left, while a UIWebView rendered representation is shown on the right.\n\nUse the slidey thing to compare the two.\n\nTap on the segmented control to change the contentMode property of the compared images." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okely Dokely" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
