//
//  AlertInfo.m
//  kytaidatviet
//
//  Created by Admin on 11/14/16.
//  Copyright © 2016 WePlay. All rights reserved.
//

#import "AlertInfo.h"

#import <UIKit/UIKit.h>

@implementation AlertInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
        if(buttonIndex == 0){
            self.cancelFuntion();
        }else{
            self.okFunction();
        }
    
}

@end
