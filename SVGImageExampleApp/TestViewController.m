
#import "TestViewController.h"
#import "JAMSVGImageView.h"
#import "SplitImageView.h"

@interface TestViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet SplitImageView *splitImageView;
@property (nonatomic) NSArray <NSString *> *fileNames;
@property (nonatomic) UIWebView *webView;
@end

@implementation TestViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    NSMutableArray *allFiles = NSMutableArray.new;
    for (NSString *filePath in [NSBundle.mainBundle pathsForResourcesOfType:@"svg" inDirectory:nil]) {
        [allFiles addObject:filePath.lastPathComponent];
    }
    self.fileNames = [allFiles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.webView = [UIWebView.alloc initWithFrame:CGRectMake(0, 0, 480, 360)];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = self.splitImageView.backgroundColor;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self loadImageNamed:self.fileNames.firstObject];
}

- (void)loadImageNamed:(NSString *)imageName;
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:imageName ofType:nil];
    if (filePath) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    }
    
    self.splitImageView.leftImage = [[JAMSVGImage imageNamed:imageName.stringByDeletingPathExtension] imageAtSize:CGSizeMake(480, 360)];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    UIGraphicsBeginImageContextWithOptions(webView.frame.size, YES, 1);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.splitImageView.rightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.fileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = UITableViewCell.new;
    cell.textLabel.text = self.fileNames[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self loadImageNamed:self.fileNames[indexPath.row]];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"What These Tests" message:@"\nTap an svg in the list to load it up.\n\nThe svg view is renedered on the left, while a UIWebView rendered representation is shown on the right.\n\nUse the slidey thing to compare the two.\n\nTap on the segmented control to change the contentMode property of the compared images." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okely Dokely" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
