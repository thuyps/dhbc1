//
//  CustomAdvBannerOffline.m
//  batchu
//
//  Created by dungpq on 12/4/14.
//  Copyright (c) 2014 Weplay.vn. All rights reserved.
//

#import "CustomAdvBannerOffline.h"
#import "CustomContext.h"
#import "AppDelegate.h"
#import "config.h"


@implementation CustomAdvBannerOffline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenW, 50)];
        self.mContext = [CustomContext getInstance];
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imgView];
        self.bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenW, 50)];
        self.bt.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bt];
    }
    return self;
}

-(void)setAdvItem:(AdvItem*)item
{
    self.adv = item;
    if(self.adv.image_frames != nil){
        self.startFrameCount = 0;
        if(self.adv.imgArray == nil){
            self.adv.imgArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.adv.image_frames.count; i++) {
                NSData* data = [self.mContext loadCachedUrl:[self.adv.image_frames objectAtIndex:i]];
                UIImage* img = [UIImage imageWithData:data];
                
                [self.adv.imgArray addObject:img];
                
                
                
            }
        }
        
        
        self.imgView.image = [self.adv.imgArray objectAtIndex:0];
        
        if(self.adv.image_frames.count > 1){
            [self scheduleUpdate];
        }
        
        
    }else{
        NSData* data = [self.mContext loadCachedUrl:self.adv.image];
        self.imgView.image = [UIImage imageWithData:data];
    }
    
    
    [[AppDelegate getInstance].tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"CustomAdv"     // Event category (required)
                                                          action:@"View"  // Event action (required)
                                                           label:self.adv.name          // Event label
                                                           value:nil] build]];
    
    
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.bt addTarget:target action:action forControlEvents:controlEvents];
}

-(void)scheduleUpdate
{
    self.startFrameCount++;
    if (self.schedule != nil)
    {
        [self.schedule invalidate];
        self.schedule = nil;
    }
    
    if(self.startFrameCount >= self.adv.imgArray.count){
        self.startFrameCount = 0;
    }
    self.imgView.image = [self.adv.imgArray objectAtIndex:self.startFrameCount];
    
    self.schedule = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scheduleUpdate) userInfo:nil repeats:NO];
}




@end
