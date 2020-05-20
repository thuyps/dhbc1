
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AlertInfo.h"




@interface WPUtils : NSObject

+(UIImageView*)createImageView:(NSString*)name fitWidth:(CGFloat)w;
+(UIColor*) colorFromString:(NSString*)strColor;
+(void)alert:(NSString*)str Message:(NSString*)msg FromController:(UIViewController*)controller;
+(void)alert:(NSString*)str FromController:(UIViewController*)controller;
+ (NSData *)obfuscate:(NSData *)data withKey:(NSString *)key;



+(NSString *)urlencode:(NSString*)input ;
+(UIFont*)createFont:(NSString*)fontName Size:(CGFloat)size;

+(UIView*) addView:(UIView*)view withPoint:(CGPoint)p withAlignment:(int)alignment toView:(UIView*)toview;
+(UILabel*)createLabel:(NSString*)text  Color:(UIColor*)color withFont:(UIFont*)font;
+(UILabel*)createLabel:(CGRect)frame;
+(UIImage *) imageWithView:(UIView *)view;

+(UIView*)createContainerViewFromImage:(NSString*)imgName Scale:(CGFloat)scale;
+(UIButton*)createButtonFromImage:(NSString*)imgName Text:(NSString*)text;
+(UIButton*)createButtonFromImage:(NSString*)imgName Text:(NSString*)text Scale:(CGFloat)scale;
+(UIImageView*)createViewFromImage:(NSString*)imgName Scale:(CGFloat)scale;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

+(NSString*)convertDateToString:(NSDate*)date Format:(NSString*)format;
+(NSDate *)convertStringToDate:(NSString*)string Format:(NSString *)format;

+ (BOOL) checkCurrentConnection;

+(NSString*)getString:(NSString*)key;

//update new funtion 2015 09- 24
+(NSDate*)addDaystoDate:(NSDate*)date withDay:(int)days;


+ (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url fromController:(UIViewController*)controller;

+ (NSString *) applicationDocumentsDirectory;

+(void)removeAllSubView:(UIView*)view;

+(void)askForResponse:(AlertInfo*)alertinfo OKCallback:(void (^)())okFunction CancelCallback:(void (^)())cancelFunction;

+ (NSString *)cachedFileNameForKey:(NSString *)key ;

@end
