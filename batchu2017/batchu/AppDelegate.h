//
//  AppDelegate.h
//  batchu
//
//  Created by Dung on 2/6/17.
//  Copyright © 2017 WePlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Reachability.h"

@class SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL suspend;
}
@property (strong, nonatomic) UIWindow *window;





@property (nonatomic) int count_press_home;

//@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) SplashViewController *viewController;
@property(nonatomic, strong) id<GAITracker> tracker;
- (void)setSuspend:(BOOL)value;
+(AppDelegate*)getInstance;
- (void)setMaxLevel;
- (BOOL) checkCurrentConnection;

@end

