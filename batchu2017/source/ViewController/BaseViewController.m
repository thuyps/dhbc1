//
//  BaseViewController.m
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "BaseViewController.h"
#import "WPUtils.h"


@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mContext = [CustomContext getInstance];
}



-(void)addBackground1:(NSString*)imgname
{
    
    UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)] ;
    scrollview.scrollEnabled = NO;
    
    UIImage* background = [UIImage imageNamed:imgname];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:background] ;
    imgView.frame = CGRectMake(0, 0, screenW,screenH);
    [scrollview addSubview:imgView];
    [self.view addSubview:scrollview];
    
    
}
-(void)addBackground:(NSString*)imgname
{
    
    UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)] ;
    scrollview.scrollEnabled = NO;
    
    UIImage* background = [UIImage imageNamed:imgname];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:background] ;
    
    CGFloat IMG_W = background.size.width/2;
    CGFloat IMG_H = background.size.height/2;
    
    CGFloat IMG_NEW_H = self.view.frame.size.height;
    CGFloat IMG_NEW_W = IMG_NEW_H*IMG_W/IMG_H;
    
    imgView.frame = CGRectMake((IMG_W-IMG_NEW_W)/2, 0, IMG_NEW_W,IMG_NEW_H);
    
    [scrollview addSubview:imgView];
    [self.view addSubview:scrollview];
    
    
}

-(UIView*) addImageView:(NSString*)imgName withPoint:(CGPoint)p
{
   return [self addImageView:imgName withPoint:p withAlignment:CustomAlignTopLeft];
}




-(UIView*) addImageView:(NSString*)imgName withPoint:(CGPoint)p withAlignment:(CustomAlign)alignment
{
    UIImage* img = [UIImage imageNamed:imgName];
    
    CGFloat w = img.size.width/2;
    CGFloat h = img.size.height/2;
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img] ;
    [self.view addSubview:imgView];
    switch(alignment)
    {
        case CustomAlignTopLeft:
            imgView.frame = CGRectMake(p.x,p.y,w, h);
            break;
        case CustomAlignMidleCenter:
            imgView.frame = CGRectMake(p.x-w/2,p.y-h/2,w, h);
            break;
        case CustomAlignBottomCenter:
            imgView.frame = CGRectMake(p.x-w/2,p.y-h,w, h);
            break;
        case CustomAlignTopCenter:
            imgView.frame = CGRectMake(p.x-w/2,p.y,w, h);
            break;
            
    }
    return imgView;
}

-(void) showLoadingProgress
{
    if(self.HUD==nil){
        self.HUD =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)stopLoadingProgress
{
    
    if(self.HUD!=nil){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.HUD = nil;
    }
    
}

-(void)addBackGroundScaleFill:(NSString*)name
{
    UIImage* background = [UIImage imageNamed:name];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:background] ;
    imgView.contentMode = UIViewContentModeScaleToFill;
    imgView.frame = CGRectMake(0, 0, screenW,screenH);
    [self.view addSubview:imgView];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)requestUrl:(NSString*)urlString PostData:(NSString*)postdata CompletionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler
{
    
    
    NSError *error;
    
    
    
    NSURL *url = nil;
 //   if([urlString indexOf:@"http"] >=0){
        url = [NSURL URLWithString:urlString];
  //  }else{
  //      url = [NSURL URLWithString:[self.mContext getURL:urlString]];
  //  }
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if(postdata != nil){
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[postdata dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        BM4Log(@"%@%@",urlString,postdata);
    }
    
    
    
    
    
    
    
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   
                                   /*if(data != nil){
                                    NSString* newStr = [[NSString alloc] initWithData:data
                                    encoding:NSUTF8StringEncoding];
                                    BM4Log(@"openchar response: %@ \n",newStr);
                                    }*/
                                   
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionHandler(data,response,error);
                                   });
                                   
                                   
                               }];
    }else
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /*#ifdef DEBUG
                 if(data!= nil){
                 
                 NSError* error;
                 NSDictionary *lvObjUserInfo = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:kNilOptions
                 error:&error];
                 
                 BM4Log(@"%@",[lvObjUserInfo description]);
                 
                 
                 }
                 #endif*/
                completionHandler(data,response,error);
            });
            
            
        }];
        
        [postDataTask resume];
    }
    
    
    
    
}









-(void)handleResponse:(NSData*)data Callback:(void (^)(NSDictionary * __nullable dic))callbackFunction
{
    
    if(data == nil)
    {
        [WPUtils alert:MSG_NETWORK_ERROR FromController:self];
        return;
    }
    
    
    NSError* error;
    NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
    
    BM4Log(@"%@",[lvObjUserInfo description]);
    
    
    
    NSString* lvResult = [lvObjUserInfo objectForKey:TAG_RESULT];
    
    if (lvResult != nil )
    {
        lvResult =
        [lvResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([lvResult isEqualToString:@"OK"]){
            callbackFunction(lvObjUserInfo);
        }else{
            if(![self handleError:lvObjUserInfo])
            {
                [WPUtils alert:[lvObjUserInfo objectForKey:@"error_content"] FromController:self];
            }
            
        }
    }
    
    
    
}


-(BOOL)handleError:(NSDictionary*)dic
{
  /*  int error_code =  [[dic objectForKey:@"error_code"] intValue];
    self.mContext.mErrorMessage  = [dic objectForKey:@"error_content"];
    if(error_code == 402 && self.mContext.is_release_version == 1){
        [self handleError402];
        return YES;
    }
    
    if(error_code == 1603 && self.mContext.is_release_version == 1){
        [self handleError1603_522];
        return YES;
    }
    
    if(error_code == 522 && self.mContext.is_release_version == 1){
        [self handleError1603_522];
        return YES;
    }
    
    if(error_code == 523 ){
        
        [self handleError523];
        return YES;
    }
    
    if(error_code == 98 ){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ERROR_ACTION_95 object:nil];
        
    }else if(error_code == 99){
        NSString *str = [dic objectForKey:@"previous_request_id"];
        self.mContext.mRequestID = [str longLongValue]+1;
        NSString* lvRequestID = [NSString stringWithFormat:@"%ld",self.mContext.mRequestID];
        BM4Log(@"%@",lvRequestID);
        
    }*/
    
    return NO;
    
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    NSLog([error description]);
    
}


@end
