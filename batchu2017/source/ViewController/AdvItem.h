//
//  AdvItem.m
//  batchu
//
//  Created by dungpq on 12/2/14.
//  Copyright (c) 2014 Weplay.vn. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AdvItem : NSObject
{
}

@property () int download_count;
@property () int status;

@property (strong) NSString* adv_type;
@property (strong) NSString* click_url;

@property (strong) NSArray* image_frames;
@property (strong) NSString* image;

@property (strong) NSString* name;
@property (strong) NSString* target_id;
@property (strong) NSMutableArray* imgArray;
@end