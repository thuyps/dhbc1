//
//  AlertInfo.h
//  kytaidatviet
//
//  Created by Admin on 11/14/16.
//  Copyright © 2016 WePlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^CallBackFunction)();

@interface AlertInfo : NSObject
@property (strong) NSString* title;
@property (strong) NSString* message;
@property (strong) NSString* butt1;
@property (strong) NSString* butt2;
@property (strong) CallBackFunction okFunction;
@property (strong) CallBackFunction cancelFuntion;
@property (weak) UIViewController* fromView;
@end
