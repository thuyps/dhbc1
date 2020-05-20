//
//  ViewController.h
//  batchu
//
//  Created by MacBookPro on 9/17/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GamePlayViewController.h"
@class Reachability;
@interface HomeViewController : BaseViewController<UIAlertViewDelegate> 
{
   
}

-(void) checkupdateVersion;

-(void)reloadRuby;
-(void)delayReloadRuby;

-(void)receivedReloadData:(NSData*) data;

-(void) receiveupdateVersion;

-(void)updateUILevel:(NSNotification*)nt;


@end
