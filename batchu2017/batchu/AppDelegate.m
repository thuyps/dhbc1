//
//  AppDelegate.m
//  batchu
//
//  Created by Dung on 2/6/17.
//  Copyright © 2017 WePlay. All rights reserved.
//

#import "AppDelegate.h"

#import "CustomContext.h"
#import "SplashViewController.h"
#import "config.h"
#import "Reachability.h"
#import "GAI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize tracker;
@synthesize viewController;
@synthesize count_press_home;
id delegate_instance = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    delegate_instance = self;
    count_press_home = 0;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
   /* application.statusBarHidden = YES;
    [CustomContext getInstance];
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    
    self.viewController = [[SplashViewController
                            alloc] init] ;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    */
    
    
    suspend = NO;
    
    return YES;
}
/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}*/



- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL) checkCurrentConnection{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        BM4Log(@"There IS NO internet connection");
        return NO;
    }
    return YES;
}

+(AppDelegate*)getInstance
{
    return delegate_instance;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[CustomContext getInstance] saveLocalData];
    
    
    
    if(self.count_press_home++>5){
        if(suspend == NO){
            exit(0);
            
        }
    }
    
}

- (void)setSuspend:(BOOL)value
{
    suspend = value;
}

- (void)setMaxLevel
{
    suspend = NO;
    self.count_press_home = 10;
}
@end
