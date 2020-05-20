//
//  WebViewController.h
//  batchu
//
//  Created by Pham Quang Dung on 11/13/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
//#import <MessageUI/MessageUI.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "config.h"


@interface WebViewController : BaseViewController<UIWebViewDelegate/*,MFMessageComposeViewControllerDelegate*/,GADInterstitialDelegate>
{

//#ifdef K_AdMobPublicID
    GADInterstitial *interstitial_;

//#endif
    
    UIWebView* webview ;
    UIScrollView* mScrollView ;
    BaseViewController * backViewcontroller;
   
}

-(void) setBackViewController:(UIViewController*)controller;
@end
