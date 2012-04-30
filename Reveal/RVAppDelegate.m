//
//  RVAppDelegate.m
//  Reveal
//
//  Created by Nick Watts on 3/28/12.
//

#import "RVAppDelegate.h"
#import "RVMainViewController.h"
#import "RVLocationManager.h"
#import "RVLandmarkManager.h"

@interface RVAppDelegate()

@property (strong, nonatomic) RVMainViewController* main_view_controller;
@property (strong, nonatomic) RVLocationManager* location_manager;
@property (strong, nonatomic) RVLandmarkManager* landmark_manager;
@property (strong, nonatomic) UIAlertView* loading_alert;

@end

@implementation RVAppDelegate

@synthesize window = _window;
@synthesize main_view_controller = _main_view_controller;
@synthesize location_manager = _location_manager;
@synthesize landmark_manager = _landmark_manager;
@synthesize loading_alert = _loading_alert;

- (void)dealloc
{
  [_loading_alert release];
  [_main_view_controller release];
  [_location_manager release];
  [_landmark_manager release];
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  [application setStatusBarHidden:YES];
  
  self.main_view_controller = [[RVMainViewController alloc] init];
  self.window.rootViewController = self.main_view_controller;
  [self.window makeKeyAndVisible];
  
  self.location_manager = [[RVLocationManager alloc] init];
  
  self.landmark_manager = [[RVLandmarkManager alloc] init];
  
  self.main_view_controller.landmark_manager = self.landmark_manager;
  
  [self showLoadingAlert];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showLoadingAlert
{
  CGFloat center_x = self.main_view_controller.view.frame.size.width / 2;
  CGFloat center_y = self.main_view_controller.view.frame.size.height / 2;
  self.loading_alert = [[UIAlertView alloc] init];
  
  UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [self.loading_alert show];
  self.loading_alert.frame = CGRectMake(center_x - 90, center_y - 90, 180, 180);
  [self.loading_alert addSubview:indicator];
  [indicator setColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]];
  [indicator startAnimating];
  [indicator setTransform:CGAffineTransformMakeScale(2, 2)];
  indicator.frame = CGRectMake(self.loading_alert.bounds.size.width/2 - indicator.bounds.size.width/2, self.loading_alert.bounds.size.height/2 - indicator.bounds.size.height/2, indicator.bounds.size.width, indicator.bounds.size.height);
  
  UILabel* message = [[UILabel alloc] init];
  message.text = @"loading";
  message.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
  message.textColor = [UIColor whiteColor];
  [self.loading_alert addSubview:message];
  [message sizeToFit];
  [message setFrame: CGRectMake(self.loading_alert.bounds.size.width/2 - message.bounds.size.width/2, self.loading_alert.bounds.size.height/2 - message.bounds.size.height/2, message.bounds.size.width, message.bounds.size.height)];
  [self.loading_alert bringSubviewToFront:message];
  
  [indicator release];
  [self.loading_alert release];
  [message release];
}

- (void)closeLoadingAlert
{
  if ( self.loading_alert != nil ) {
    [self.loading_alert dismissWithClickedButtonIndex:0 animated:YES];
    self.loading_alert = nil;
  }
}

@end
