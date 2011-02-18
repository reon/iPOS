//
//  iPOSAppDelegate.m
//  iPOS
//
//  Created by Steven McCoole on 1/31/11.
//  Copyright NA 2011. All rights reserved.
//

#import "iPOSAppDelegate.h"

#pragma mark -
@implementation iPOSAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize loginViewController;
#pragma mark Constructors
- (void) applicationDidFinishLaunching:(UIApplication*)application 
{   
    // Set the application setting defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"YES" forKey:@"enableDemoMode"];
    
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    // Create window
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// Create the login root view controller
	loginViewController = [[LoginViewController alloc] init];
	
	// Create navigation controller with login view controller as contents
	navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	[loginViewController release];
	
	// Add the navigation controller view to the window
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
   }

- (void) applicationWillTerminate:(UIApplication*)application {	[navigationController release];
    [window release];
    
    [super dealloc];
}

@end
