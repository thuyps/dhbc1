//
//  CustomAdvBannerOffline.h
//  batchu
//
//  Created by dungpq on 12/4/14.
//  Copyright (c) 2014 Weplay.vn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"
#import "UIKit/UIKit.h"

@class CustomContext;
@interface CustomAdvBannerOffline : UIView
{
    
}
@property (weak) CustomContext* mContext;
@property (weak) AdvItem* adv;
@property (strong) UIButton* bt;
@property (strong) UIImageView* imgView;
//@property (retain) NSMutableArray* imgArray;
@property () int startFrameCount;

@property (strong) NSTimer* schedule;


- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
-(void)scheduleUpdate;
-(void)setAdvItem:(AdvItem*)item;
@end
