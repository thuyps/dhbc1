//
//  Utils.h
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils1 : NSObject
+(UIColor*) colorFromString:(NSString*)strColor;
+(void)alert:(NSString*)str;
+ (BOOL) checkCurrentConnection;
+ (NSData *)obfuscate:(NSData *)data withKey:(NSString *)key;

+(void) pushTransaction:(UIViewController*)aViewController;


+(void) backTransaction:(UIViewController*)aViewController;
@end
