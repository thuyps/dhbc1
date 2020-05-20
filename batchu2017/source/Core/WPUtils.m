//
//  Utils.m
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "WPUtils.h"
#import "config.h"
#import "AlertInfo.h"
#import "ExtendNSString.h"
#import <CommonCrypto/CommonDigest.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


@implementation WPUtils

+(UIImageView*)createImageView:(NSString*)name fitWidth:(CGFloat)w
{
    UIImage* image = [UIImage imageNamed:name];
    CGFloat h = w*image.size.height/image.size.width;
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    view.image = image;
    view.contentMode = UIViewContentModeScaleAspectFit;
    return view;
}

+(UIColor*) colorFromString:(NSString*)strColor
{
    if(strColor!=nil)
    {
        unsigned int argb = 0;
        NSScanner *scanner = [NSScanner scannerWithString:strColor];
        [scanner scanHexInt:&argb];
        
        int blue = argb & 0xff;
        int green = argb >> 8 & 0xff;
        int red = argb >> 16 & 0xff;
        
        return RGB( red, green,blue );
    }
    return RGB( 0, 0,0 );
    
}

+(void)alert:(NSString*)title Message:(NSString*)msg FromController:(UIViewController*)controller
{
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:nil];
        [dialog setMessage:msg];
        [dialog setTitle:title];
        [dialog addButtonWithTitle:@"Đóng"];
        [dialog show];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    }
    
}


+(void)alert:(NSString*)str FromController:(UIViewController*)controller
{
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:nil];
        [dialog setMessage:str];
        [dialog setTitle:@"Thông báo"];
        [dialog addButtonWithTitle:@"Đóng"];
        [dialog show];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Thông báo" message:str preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    }
    
    

    
}



+ (NSData *)obfuscate:(NSData *)data withKey:(NSString *)key
{
    NSMutableData *result = [data mutableCopy];
    
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [result mutableBytes];
    
    // Get pointer to key data
    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;
        
        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == [key length])
            keyIndex = 0, keyPtr = keyData;
    }
    
    return result;
}

+(void) backTransaction:(UIViewController*)aViewController
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    
    UIView *containerView = aViewController.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
}

+(void) pushTransaction:(UIViewController*)aViewController
{
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    
    UIView *containerView = aViewController.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
}

+(NSString *)urlencode:(NSString*)input {
    if(input == nil){
        return  nil;
    }
    
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[input UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


+(UIView*) addView:(UIView*)imgView withPoint:(CGPoint)p withAlignment:(int)alignment toView:(UIView*)toview
{
    
    
    CGFloat w = imgView.frame.size.width;
    CGFloat h = imgView.frame.size.height;
    [toview addSubview:imgView];
    CGRect frame;
    switch(alignment)
    {
        case CustomAlignTopLeft:
            frame = CGRectMake(p.x,p.y,w, h);
            break;
        case CustomAlignMidleCenter:
            frame = CGRectMake(p.x-w/2,p.y-h/2,w, h);
            break;
        case CustomAlignBottomCenter:
            frame = CGRectMake(p.x-w/2,p.y-h,w, h);
            break;
        case CustomAlignTopCenter:
            frame = CGRectMake(p.x-w/2,p.y,w, h);
            break;
            
        case CustomAlignTopRight:
            frame = CGRectMake(p.x-w,p.y,w, h);
            break;
        case CustomAlignBottomRight:
            frame = CGRectMake(p.x-w,p.y-h,w, h);
            break;
        case CustomAlignBottomLeft:
            frame = CGRectMake(p.x,p.y-h,w, h);
            break;
            
    }
    imgView.frame = frame;
    
    return imgView;
}



+(UIImage *) imageWithView:(UIView *)view
{
    
    
    [view setOpaque:NO];
    [view.layer setOpaque:NO];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, [UIScreen mainScreen].scale);
    
    
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    //BM4Log(@"%f  :scale:  %f ",img.size.width,img.scale);
    UIGraphicsEndImageContext();
    
    return img;
}


+(UIView*)createContainerViewFromImage:(NSString*)imgName Scale:(CGFloat)scale
{
    UIView* imgView = [WPUtils createViewFromImage:imgName Scale:scale];
    UIView* returnView = [[UIView alloc] initWithFrame:imgView.frame];
    [returnView addSubview:imgView];
    return returnView;
}

+(UIImageView*)createViewFromImage:(NSString*)imgName Scale:(CGFloat)scale
{
    UIImage* may = [UIImage imageNamed:imgName];
    CGFloat w = may.size.width/2*scale;
    CGFloat h = may.size.height/2*scale;
    if(h < 1){
        h = 1;
    }
    UIImageView* dammay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    dammay.image = may;
    return dammay;
}



+(UIButton*)createButtonFromImage:(NSString*)imgName Text:(NSString*)text Scale:(CGFloat)scale
{
    UIImage* img = [UIImage imageNamed:imgName];
    CGFloat w;
    CGFloat h;
   
        w = img.size.width*scale/2;
        h = img.size.height*scale/2;
    
    UIButton* bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    if(img == nil){
        [bt setTitle:text forState:UIControlStateNormal];
    }else{
        [bt setBackgroundImage:img forState:UIControlStateNormal];
    }
    return bt;
}


+(UIButton*)createButtonFromImage:(NSString*)imgName Text:(NSString*)text
{
  
    UIImage* img = [UIImage imageNamed:imgName];
    CGFloat w;
    CGFloat h;
        w = img.size.width /2;
        h = img.size.height/2;
    UIButton* bt;
        bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        [bt setBackgroundImage:img forState:UIControlStateNormal];
    return bt;
    
}


+(NSString*)getString:(NSString*)key
{
    
#ifdef DEBUG
    @try {
      //  NSLog(@"key :%@",key);
        //NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        NSString* test = [[NSBundle mainBundle] localizedStringForKey:([key uppercaseString]) value:@"" table:nil];
        if(test == nil){
           // NSLog(@"cant find key :%@",key);
        }else{
            return test;
        }
    }
    @catch (NSException *exception) {
       // NSLog(@"cant find key :%@",key);
    }
    @finally {
        
    }
    
    
#else
    return [[NSBundle mainBundle] localizedStringForKey:([key uppercaseString]) value:@"" table:nil];
#endif
    
}

+(NSString*)convertDateToString:(NSDate *)date Format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+(NSDate *)convertStringToDate:(NSString*)string Format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate* test = [dateFormatter dateFromString:string];
    return test;
    
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

//update new funtion 2015 09- 24
+(NSDate*)addDaystoDate:(NSDate*)date withDay:(int)days
{
    NSDate* test = [date dateByAddingTimeInterval:60*60*24*days];
    return test;
}

+(UILabel*)createLabel:(CGRect)frame;
{
    UILabel* l = [[UILabel alloc] initWithFrame:frame];
    l.backgroundColor = [UIColor clearColor];
    
    l.textAlignment = NSTextAlignmentCenter;
    
    return l;
}

+(UILabel*)createLabel:(NSString*)text  Color:(UIColor*)color withFont:(UIFont*)font
{
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    l.backgroundColor = [UIColor clearColor];
    l.text = text;
    l.textColor = color;
    l.font = font;
    l.numberOfLines = 1;
    l.textAlignment = NSTextAlignmentCenter;
    
    return l;
    
    
}

+ (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url fromController:(UIViewController*)controller
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [controller presentViewController:activityController animated:NO completion:nil];
}


+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

+(UIFont*)createFont:(NSString*)fontName Size:(CGFloat)size
{
    
    UIFont* font = [UIFont fontWithName:fontName size:size];
    if(font == nil){
        NSString* newName = [NSString stringWithString:fontName] ;
        if([fontName indexOf:@" "] > 0){
            newName = [fontName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            font = [UIFont fontWithName:fontName size:size];
        }
        
        if(font == nil && [newName indexOf:@"-"] > 0){
            newName = [newName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
            font = [UIFont fontWithName:newName size:size];
        }
        
        
        if(font == nil && [newName indexOf:@"_"] > 0){
            newName = [newName stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
            font = [UIFont fontWithName:newName size:size];
        }
    }
    
    return font;
    
}


+(void)removeAllSubView:(UIView*)view
{
    if(view == nil){
        return;
    }else{
        for (UIView* v in [view subviews]) {
            [v removeFromSuperview];
        }
        
    }
    
}

+(void)askForResponse:(AlertInfo*)alertinfo OKCallback:(void (^)())okFunction CancelCallback:(void (^)())cancelFunction
{
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        alertinfo.okFunction = okFunction;
        alertinfo.cancelFuntion = cancelFunction;
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:alertinfo];
        [dialog setTitle:alertinfo.title];
        [dialog setMessage:alertinfo.message];
       
        if(alertinfo.butt1!=nil)
            [dialog addButtonWithTitle:alertinfo.butt1];
        
        if(alertinfo.butt2!=nil)
            [dialog addButtonWithTitle:alertinfo.butt2];
        
        [dialog show];
        
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertinfo.title message:alertinfo.message preferredStyle:UIAlertControllerStyleAlert];
        
        if(alertinfo.butt1!=nil)
        {
            UIAlertAction* boqua = [UIAlertAction actionWithTitle:alertinfo.butt1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                cancelFunction();
            }];
            
            
            [alertController addAction:boqua];
        }
        
        
         if(alertinfo.butt2!=nil)
         {
             UIAlertAction* dongy = [UIAlertAction actionWithTitle:alertinfo.butt2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 okFunction();
             }];
             [alertController addAction:dongy];

         }
        
        
        
        
        [alertinfo.fromView presentViewController:alertController animated:YES completion:nil];
    }
    
    
    
}




+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}


@end
