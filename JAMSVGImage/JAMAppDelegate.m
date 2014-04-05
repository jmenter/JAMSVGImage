
#import "JAMAppDelegate.h"
#import "JAMViewController.h"

@implementation JAMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = JAMViewController.new;
    [self.window makeKeyAndVisible];
    return YES;
}
							
@end
