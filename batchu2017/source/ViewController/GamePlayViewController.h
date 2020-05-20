//
//  GamePlayViewController.h
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WinViewController.h"
#import "CustomAdvBannerOffline.h"
#import "WebViewController.h"


//#import <FacebookSDK/FacebookSDK.h>




typedef NS_ENUM(NSInteger, GameState) {
    GameStateNoState,
    GameStateStarting,
    GameStateStarted,
    GameStateOpenningChar,
    GameStatePlaying,
    GameStateEnding,
    GameStateEnded
};

@class GADBannerView;

@interface GamePlayViewController : BaseViewController
{
 
    WebViewController *userinfo;
    WinViewController*win;

}
//@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (strong) NSMutableArray* mOfferButtons;
@property (strong) NSMutableArray* mAnswerButtons;
@property (weak) UILabel* mScoreLabel;
@property (weak)  NSTimer* opencharTimer;
@property (weak) UIButton* opencharButton;


@property () int mState;


-(void)reCreateUI;
-(void)delayReloadRuby;
-(void)reloadRuby;
-(void)receivedReloadData:(NSData*) data;
-(void)refreshRuby;

-(void) reCreateUIForNextLevel:(NSNotification*)nt;


@end
