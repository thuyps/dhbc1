//
//  ViewController.h
//  batchu
//
//  Created by MacBookPro on 9/17/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"



#import <GoogleMobileAds/GoogleMobileAds.h>



#import "AdvItem.h"

@class GADBannerView,AdvItem;


@interface WinViewController : BaseViewController<UIAlertViewDelegate,GADInterstitialDelegate>
{
    // NSInteger adMobCount;
    GADInterstitial *interstitial_;

    
}

@property (strong) UIButton *tieptuc;


@property (strong) UIView  *advViewContainner;
@property (weak) AdvItem* advCurrent;

-(void) reCreateUI;
@end
