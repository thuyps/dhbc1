//
//  Utils.m
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "Utils1.h"
#import "Reachability.h"
#import "config.h"

@implementation Utils1

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

+(void)alert:(NSString*)str
{
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:nil];
    [dialog setTitle:@"Thông tin"];
    
    [dialog setMessage:str];
    [dialog addButtonWithTitle:@"Đóng"];
    [dialog show];
}

+ (BOOL) checkCurrentConnection{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        BM4Log(@"There IS NO internet connection");
        return NO;
    }
    return YES;
    
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

@end
