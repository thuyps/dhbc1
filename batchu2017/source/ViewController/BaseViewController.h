//
//  BaseViewController.h
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomContext.h"
#import "MBProgressHUD.h"
#import "config.h"
#import <GoogleAnalytics/GAI.h>



//#ifdef GA_INCLUDE
@interface BaseViewController : GAITrackedViewController<MBProgressHUDDelegate,NSURLSessionDelegate>
/*#else
@interface BaseViewController : UIViewController<MBProgressHUDDelegate,NSURLSessionDelegate>
#endif*/
{
}

@property (weak) UIView* coverScreen ;
@property (weak) MBProgressHUD* HUD ;
@property (weak) CustomContext* mContext;


-(void)addBackground1:(NSString*)imgname;
-(void)addBackground:(NSString*)imgname;



-(void) showLoadingProgress;

-(void)stopLoadingProgress;

-(void)addBackGroundScaleFill:(NSString*)name;

-(void)reloadRuby;
-(void)delayReloadRuby;



-(void)requestUrl:(NSString*)urlString PostData:(NSObject*)data CompletionHandler:(void (^)(NSData *  data, NSURLResponse * response, NSError *error))completionHandler;
-(void)handleResponse:(NSData*)data Callback:(void (^)(NSDictionary *dic))callbackFunction;

@end
