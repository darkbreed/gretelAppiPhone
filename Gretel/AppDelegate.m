//
//  AppDelegate.m
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "AppDelegate.h"
#import "HistoryViewController.h"
#import "SettingsMenuViewController.h"
#import <Dropbox/Dropbox.h>
#import <Instabug/Instabug.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    
#ifdef TESTING
    
    NSString *uuid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] identifierForVendor]];
    [TestFlight setDeviceIdentifier:uuid];
    [TestFlight takeOff:@"0677e702-7b7f-4508-a59f-9af8109b5718"];
    
    [Instabug KickOffWithToken:@"584de8774752975b5f94a0a4c1752d49" CaptureSource:InstabugCaptureSourceUIKit FeedbackEvent:InstabugFeedbackEventShake IsTrackingLocation:YES];
    
#endif
    
    UIImage *backgroundInage = [UIImage imageNamed:@"navigationBarBackground.png"];
    
    [[UINavigationBar appearance] setBackgroundImage:backgroundInage forBarMetrics:UIBarMetricsDefault];
    //[[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setTintColor:[UIColor lightGrayColor]];
    
    NSMutableDictionary *appearance = [NSMutableDictionary dictionary];
    [appearance setValue:[UIColor grayColor] forKey:UITextAttributeTextColor];
    [appearance setValue:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:appearance];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TRIP_IMPORT_NOTIFICATION object:nil];

    [[TripManager sharedManager] importTripFromGPXFile:url];
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
    [[TripManager sharedManager] saveTripAndStop];
    
}


@end
