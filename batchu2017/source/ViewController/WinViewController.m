//
//  ViewController.m
//  batchu
//
//  Created by MacBookPro on 9/17/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//
#import "config.h"
#import "WinViewController.h"
#import "WPUtils.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>


#import "AppDelegate.h"
#import "GamePlayViewController.h"
#import "AlphabetButton.h"

#import <CommonCrypto/CommonDigest.h>

#import "AdvItem.h"


@interface WinViewController ()

@end



@implementation WinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.mContext.mOpenCharCounts!= nil)
    {
        [self.mContext.mOpenCharCounts removeAllObjects];
       
        self.mContext.mOpenCharCounts = nil;
    }
    
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    BOOL networkCheck =  [app checkCurrentConnection];
    BOOL fullads = [self.mContext checkShowFullAdv];
    
    if(networkCheck && fullads){
        [self reCreateUI];
        [self disableTieptuc:4];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(WinScreenShowFullAdsOnline) userInfo:nil repeats:NO];
    }else if(networkCheck && !fullads){
        [self reCreateUIAdv];
        [self disableTieptuc:3];
        [self addBanner];
    }else if (!networkCheck && !fullads){
        //check offline banner
        BOOL offlineBanner = [self.mContext checkOfflineBannerExists];
        if(offlineBanner){
            [self reCreateUI];
            [self disableTieptuc:3];
            [self addOfflineBanner];
        }else{
            [self reCreateUI];
        }
    }else {
        [self reCreateUI];
        //check offline full adv
        BOOL offlinefullads = [self.mContext checkOfflineFullAdvExists];
        if(offlinefullads){
            [self disableTieptuc:4];
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(WinScreenShowFullAdsOffline) userInfo:nil repeats:NO];
        }
    }
    
    
    [self.mContext saveLocalData];
    
}

-(void)addOfflineBanner
{
    if(self.mContext.gameOfflineBanner == nil){
        self.mContext.gameOfflineBanner = [[CustomAdvBannerOffline alloc] initWithFrame:CGRectMake(0, 0, screenW,50)] ;
        
    }
    [self.mContext.gameOfflineBanner setAdvItem:[self.mContext getOfflineBanner]];
    
    [self.mContext.gameOfflineBanner removeFromSuperview];
    
     self.mContext.gameOfflineBanner.frame = CGRectMake(0, screenH - 50, screenW, 50);
    [self.view addSubview:self.mContext.gameOfflineBanner];
    
     
}

-(void)addBanner
{
    if(self.mContext.winBannerView == nil){
        if(screenH > 490){
            self.mContext.winBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
        }else{
            self.mContext.winBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];
        }
        
        self.mContext.winBannerView.adUnitID = WIN_ADV_BANNER;
        self.mContext.winBannerView.rootViewController = self;
        
        self.mContext.winBannerView.frame = CGRectMake((screenW-self.mContext.winBannerView.frame.size.width)/2, (screenH-self.mContext.winBannerView.frame.size.height), self.mContext.winBannerView.frame.size.width, self.mContext.winBannerView.frame.size.height);
        
        
        GADRequest *request = [GADRequest request];
        // Enable test ads on simulators.
#ifdef DEBUG
         request.testDevices = @[ kGADSimulatorID ];
#endif
        [self.mContext.winBannerView loadRequest:request];
        
    }
   
    [self.view addSubview:self.mContext.winBannerView];
    
}


-(void) reCreateUI
{
    
   
    [self addBackGroundScaleFill:@"winbg"];
    
    UIView* congratView =  [self addCongrat];
    
    [WPUtils addView:congratView withPoint:CGPointMake(screenW/2, 10*SCALE) withAlignment:CustomAlignTopCenter toView:self.view];
    
    
    UILabel* label = [WPUtils createLabel:@"Bạn đã tìm ra đáp án:" Color:[WPUtils colorFromString:@"007716"] withFont:[UIFont fontWithName:kLevelFont size:18*SCALE]];
    [label sizeToFit];
    [WPUtils addView:label withPoint:CGPointMake(screenW/2, CGRectGetMaxY(congratView.frame)+CGRectGetHeight(congratView.frame)/2) withAlignment:CustomAlignTopCenter toView:self.view];
    
    
    
    
    UIView* answerView = [self  CreateAnswer];
    
    [WPUtils addView:answerView withPoint:CGPointMake(screenW/2, CGRectGetMaxY(label.frame)+CGRectGetHeight(congratView.frame)/2) withAlignment:CustomAlignTopCenter toView:self.view];
    
  
    
    int winpoint = [self.mContext getBonusForWin:(int)self.mContext.mLevel];
    
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    BOOL networkCheck =  [app checkCurrentConnection];
    
    if(!networkCheck)
    {
        winpoint = 0;
    }
    UIView* textpoint = [self CreateTextPoint:winpoint];
    
    [WPUtils addView:textpoint withPoint:CGPointMake(screenW/2, CGRectGetMaxY(answerView.frame)+CGRectGetHeight(congratView.frame)/2) withAlignment:CustomAlignTopCenter toView:self.view];
    
    CGFloat posY = CGRectGetMaxY(textpoint.frame);
    
    if(winpoint==0){
        UILabel*label = [WPUtils createLabel:@"(Bạn đang chơi ofline)" Color:[WPUtils colorFromString:@"ff00ff"] withFont:[UIFont systemFontOfSize:14*SCALE]];
        [label sizeToFit];
        
        [WPUtils addView:label withPoint:CGPointMake(screenW/2, CGRectGetMaxY(textpoint.frame)+5*SCALE) withAlignment:CustomAlignTopCenter toView:self.view];
        posY = CGRectGetMaxY(label.frame);
    }
    
    
    
    UIButton* tieptuc = [WPUtils createButtonFromImage:@"tieptuc" Text:nil];
    
    [WPUtils addView:tieptuc withPoint:CGPointMake(screenW/2,posY + CGRectGetHeight(congratView.frame)/2 ) withAlignment:CustomAlignTopCenter toView:self.view];
  
    
    [tieptuc addTarget:self action:@selector(loadNextlevel) forControlEvents:UIControlEventTouchUpInside];
    
    self.tieptuc = tieptuc;
    self.mContext.mScore = self.mContext.mScore +winpoint;
    
    
    [self.mContext winlevel];
    
    self.mContext.mLevel = self.mContext.mLevel+1;
    
    [self.mContext saveLocalData];
    
}





-(void) reCreateUIAdv
{
    [self addBackGroundScaleFill:@"winbg"];
    
    UIView* congratView =  [self addCongrat];
    
    [WPUtils addView:congratView withPoint:CGPointMake(screenW/2, 10*SCALE) withAlignment:CustomAlignTopCenter toView:self.view];
    
    
    int winpoint = [self.mContext getBonusForWin:(int)self.mContext.mLevel];
    
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    BOOL networkCheck =  [app checkCurrentConnection];
    
    if(!networkCheck)
    {
        winpoint = 0;
    }
    
    
   
    
    
    
    UIButton* tieptuc = [WPUtils createButtonFromImage:@"tieptuc" Text:nil Scale:SCALE];
    
    CGFloat bottomY ;//= posY + CGRectGetHeight(congratView.frame)/4 + CGRectGetHeight(tieptuc.frame);
    
    if(screenH > 490){
        //if(bottomY > (screenH - 255)){
            
            bottomY = screenH - 255 ;
      //  }
        
    }else{
        bottomY = screenH - 100 ;
    }
    
    
    
    [WPUtils addView:tieptuc withPoint:CGPointMake(screenW/2,bottomY) withAlignment:CustomAlignBottomCenter toView:self.view];
    [tieptuc addTarget:self action:@selector(loadNextlevel) forControlEvents:UIControlEventTouchUpInside];
    
    self.tieptuc = tieptuc;
    
    
    
    UIView* dapanAndPointView =  [self createDapanAndPointView:winpoint];
    
    [WPUtils addView:dapanAndPointView withPoint:CGPointMake(screenW/2, CGRectGetMaxY(congratView.frame)/2 +CGRectGetMinY(tieptuc.frame)/2) withAlignment:CustomAlignMidleCenter toView:self.view];
    
    self.mContext.mScore = self.mContext.mScore +winpoint;
    
    [self.mContext winlevel];
    
    self.mContext.mLevel = self.mContext.mLevel+1;
    
    [self.mContext saveLocalData];
    
}


-(UIView*) createDapanAndPointView:(int)winpoint
{
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0,screenW, screenH )];
    
    UILabel* label = [WPUtils createLabel:@"Bạn đã tìm ra đáp án:" Color:[WPUtils colorFromString:@"007716"] withFont:[UIFont fontWithName:kLevelFont size:18*SCALE]];
     [label sizeToFit];
     [WPUtils addView:label withPoint:CGPointMake(screenW/2, 0) withAlignment:CustomAlignTopCenter toView:container];
     
     UIView* answerView = [self  CreateAnswer];
     
     [WPUtils addView:answerView withPoint:CGPointMake(screenW/2, CGRectGetMaxY(label.frame)+20*SCALE) withAlignment:CustomAlignTopCenter toView:container];
     
     
     
     
     UIView* textpoint = [self CreateTextPoint:winpoint];
     
     [WPUtils addView:textpoint withPoint:CGPointMake(screenW/2, CGRectGetMaxY(answerView.frame)+20*SCALE) withAlignment:CustomAlignTopCenter toView:container];
     
     CGFloat posY = CGRectGetMaxY(textpoint.frame);
     
     if(winpoint==0){
     UILabel*label = [WPUtils createLabel:@"(Bạn đang chơi ofline)" Color:[WPUtils colorFromString:@"ff00ff"] withFont:[UIFont systemFontOfSize:14*SCALE]];
     [label sizeToFit];
     
     [WPUtils addView:label withPoint:CGPointMake(screenW/2, CGRectGetMaxY(textpoint.frame)+5*SCALE) withAlignment:CustomAlignTopCenter toView:container];
     posY = CGRectGetMaxY(label.frame);
     }
    
    container.frame = CGRectMake(0, 0, screenW, posY);
    return container;
}


-(UIView*) CreateAnswer
{
    NSArray* words = [self.mContext.mAnswerString componentsSeparatedByString:@" "];
    NSString* line2=nil;
    NSMutableString* line1 = [[NSMutableString alloc] initWithString:@""];
    [line1 appendString:[words objectAtIndex:0]];
    
    int i = 1;
    while ( i < words.count && (line1.length+((NSString*)[words objectAtIndex:i]).length)<9 ) {
        [line1 appendFormat:@" %@",[words objectAtIndex:i]];
        i++;
    }
   
    if(line1.length < self.mContext.mAnswerString.length){
        line2 = [self.mContext.mAnswerString substringFromIndex:line1.length];
        line2= [line2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    }
    
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH/4)];
 
    UIView* container1 = [[UIView alloc] init];
   
    CGFloat posX = 0;
    
    UIView* bt;
    for (int i = 0; i< line1.length; i++)
    {
        NSString* ch = [line1 substringWithRange:NSMakeRange(i,1)];
        
        if([ch isEqualToString:@" "]){
            posX += 20*SCALE;
        }else{
            bt = [AlphabetButton createWinanswer:ch];
            [WPUtils addView:bt withPoint:CGPointMake(posX, 0) withAlignment:CustomAlignTopLeft toView:container1];
            posX = posX + CGRectGetWidth(bt.frame)+5*SCALE;
        }
    }
    
    container1.frame = CGRectMake(0, 0, CGRectGetMaxX(bt.frame), CGRectGetMaxY(bt.frame));
    
    [WPUtils addView:container1 withPoint:CGPointMake(screenW/2, 0) withAlignment:CustomAlignTopCenter toView:container];
    
    if (line2!=nil) {
        posX = 0;
        UIView* container2 = [[UIView alloc] init];
        for (int i = 0; i< line2.length; i++)
        {
            NSString* ch = [line2 substringWithRange:NSMakeRange(i,1)];
            
            if([ch isEqualToString:@" "]){
                posX += 20;
            }else{
                
                bt = [AlphabetButton createWinanswer:ch];
                [WPUtils addView:bt withPoint:CGPointMake(posX, 0) withAlignment:CustomAlignTopLeft toView:container2];
                posX = posX + CGRectGetWidth(bt.frame)+5*SCALE;
                
            }
        }
        
        container2.frame = CGRectMake(0, 0, CGRectGetMaxX(bt.frame), CGRectGetMaxY(bt.frame));
        
         [WPUtils addView:container2 withPoint:CGPointMake(screenW/2, CGRectGetMaxY(container1.frame)+5*SCALE) withAlignment:CustomAlignTopCenter toView:container];
        
        container.frame = CGRectMake(0, 0, screenW, CGRectGetMaxY(container2.frame));
        
    }else{
        
        container.frame = CGRectMake(0, 0, screenW, CGRectGetMaxY(bt.frame));
    }
    
    
    return container;
}


-(void)loadNextlevel
{
  //  NetworkManager* net = [NetworkManager sharedInstance];
   // [ self.mContext.audioController stopSound];
    
    [self.mContext playEffect:kSoundDing];
    
    
    if(self.mContext.mLevel > self.mContext.mTotalLevels)
    {
        [[AppDelegate getInstance] setMaxLevel];
        if(![WPUtils checkCurrentConnection]){
            [WPUtils alert:sConnectionError FromController:self];
            return;
        }
        
        
        if(self.mContext.promotion_asking != nil && ![self.mContext.promotion_asking isEqualToString:@""]){
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Thông báo"];
            dialog.tag = 2;
            [dialog setMessage:[NSString stringWithFormat:@"Bạn thật xuất sắc đã vượt qua hết các level hiện có.\n %@",self.mContext.promotion_asking]];
#ifdef APPLE
            [dialog addButtonWithTitle:@"Rate"];
#endif
            [dialog addButtonWithTitle:@"Đồng ý"];
            [dialog addButtonWithTitle:@"Bỏ qua"];
            [dialog show];
        }else{
            
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Thông tin"];
            dialog.tag = 3;
            [dialog setMessage:sMaxLevelMesage];
            
#ifdef APPLE
            [dialog addButtonWithTitle:@"Rate"];
#endif
            
            [dialog addButtonWithTitle:@"Đóng"];
            [dialog show];
            
            
        }
        return;
    }
    
    else if(self.mContext.mLevel < self.mContext.levelDownloading)
    {
        [self.mContext DownloadLevel];
        [self.mContext loadLevelData];
        
        [self gotoGamePlay];
        
        
    }
    else if(self.mContext.mLevel >= self.mContext.levelDownloading)
    {
        self.mContext.levelDownloading = self.mContext.mLevel;
        //loading level
        if(![WPUtils checkCurrentConnection]){
            [WPUtils alert:sConnectionError FromController:self];
            return;
        }
        
        
        if(self.HUD==nil){
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            self.HUD.labelText = @"Đang tải dữ liệu";
            //self.HUD.detailsLabelText = @"Loading level data...";
            [self.view addSubview:self.HUD];
            [self.HUD show:YES];
        }
        NSURL *url = [NSURL URLWithString:[self.mContext getDataUrlLevelDownload:YES]];
        //initialize a request from url
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   [self stopLoadingProgress];
                                   if(data==nil || ![self.mContext checkData:data withLevel:(int)self.mContext.levelDownloading]){
                                       [WPUtils alert:sConnectionError FromController:self];
                                   }else{
                                       [data writeToFile:[self.mContext filename:(int)self.mContext.levelDownloading] atomically:YES];
                                       [self.mContext loadLevel:data];
                                       self.mContext.levelDownloading++;
                                       [self.mContext DownloadLevel];
                                       [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gotoGamePlay) userInfo:nil repeats:NO];
                                   }
                                   
                               }];
        return;
        
    }else{
        [[AppDelegate getInstance].tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"deadpoint"     // Event category (required)
                                                                                        action:@"Clicked"  // Event action (required)
                                                                                         label:self.advCurrent.name        // Event label
                                                                                         value:nil] build]];
        
        
        [[AppDelegate getInstance] setMaxLevel];
        
    }
    
    
    
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(alertView.tag == 2){
#ifdef APPLE
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreAddress2]];
        }
        
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.mContext.promotion_url]];
            
        }
#else
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.mContext.promotion_url]];
            
        }
#endif
        
    }else if(alertView.tag == 3){
#ifdef APPLE
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreAddress2]];
        }
#endif
    }
    
}

-(NSString*)MD5:(NSString*)inString
{
    // Create pointer to the string as UTF8
    const char *ptr = [inString UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

-(void) getLevelDataFromServer
{
    if(self.mContext.mUserID==nil)
        return;
    
    NSString* pChecksum = [NSString stringWithFormat:@"%@%@%d%@",GAME_ID ,self.mContext.mUserID , self.mContext.levelDownloading , SECRET_KEY];
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:LEVEL_DATA_URL];
    [sDataUrl appendString: @"?game_id="];
    [sDataUrl appendString:GAME_ID];
    
    [sDataUrl appendString: @"&user_id="];
    [sDataUrl appendString:self.mContext.mUserID];
    
    [sDataUrl appendString: @"&device_id="];
    [sDataUrl appendString:self.mContext.mDeviceID];
    
    [sDataUrl appendString: @"&device_os=iOS"];
    [sDataUrl appendString: @"&level_id="];
    [sDataUrl appendString:[NSString stringWithFormat:@"%d",self.mContext.levelDownloading]];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:[self MD5:pChecksum ]];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    
    NSURL* url = [NSURL URLWithString:sDataUrl];
    
    NSData* data = [NSData dataWithContentsOfURL:url];
    
    
    [self.mContext loadLevel:data];
    
    
}

-(void) receivedLevelData:(NSData*) data
{
    [self stopLoadingProgress];
    if(data==nil || ![self.mContext checkData:data withLevel:self.mContext.levelDownloading]){
        [WPUtils alert:sConnectionError FromController:self];
    }else{
        
        [data writeToFile:[self.mContext filename:self.mContext.levelDownloading] atomically:YES];
        
        [self.mContext loadLevel:data];
        self.mContext.levelDownloading++;
        [self.mContext DownloadLevel];
        [self gotoGamePlay];
    }
}

-(void)gotoGamePlay
{
   // [self.mContext.play reCreateUI];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_RE_CREATE_UI" object:self];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.mContext.winBannerView removeFromSuperview];
    }];
    
}

-(UIView*)CreateTextPoint:(int)point
{
    
    UIView * container = [[UIView alloc] init];
    
    UIFont* fontText = [UIFont fontWithName:kLevelFont size:17*SCALE];
    UIColor *colorText = [UIColor blueColor] ;
    NSString * text1 = @"Bạn được tặng:";
    
    UILabel* label1 = [WPUtils createLabel:text1 Color:colorText withFont:fontText];
    [label1 sizeToFit];
    
    [WPUtils addView:label1 withPoint:CGPointMake(0, 5*SCALE) withAlignment:CustomAlignTopLeft toView:container];
    
   UIFont* fontNumber = [UIFont fontWithName:kLevelFont size:22*SCALE];
   UIColor *colorNumber = [WPUtils colorFromString:@"ff00ff"];
   text1 = [NSString stringWithFormat:@"+%d",point];
  
    UILabel *label2 = [WPUtils createLabel:text1 Color:colorNumber withFont:fontNumber];
    [label2 sizeToFit];
    
    [WPUtils addView:label2 withPoint:CGPointMake(CGRectGetMaxX(label1.frame)+CGRectGetWidth(label2.frame)/2+2*SCALE, CGRectGetMidY(label1.frame)) withAlignment:CustomAlignMidleCenter toView:container];
    
    
   
   
   
    UILabel* label3 = [WPUtils createLabel:@"Ruby" Color:colorText withFont:fontText];
    [label3 sizeToFit];
    
     [WPUtils addView:label3 withPoint:CGPointMake(CGRectGetMaxX(label2.frame)+2*SCALE+CGRectGetWidth(label3.frame)/2, CGRectGetMidY(label1.frame)) withAlignment:CustomAlignMidleCenter toView:container];
    
    container.frame = CGRectMake(0, 0, CGRectGetMaxX(label3.frame), MAX(CGRectGetMaxY(label3.frame),CGRectGetMaxY(label2.frame)));
    
    return container;
}

-(UIView*)addCongrat
{
    
    UIView* container = [WPUtils createContainerViewFromImage:@"wintextbg.png" Scale:screenW/320.0];
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectInset(container.frame, 5*SCALE, 0)];
    
    UIFont* font = [UIFont fontWithName:kLevelFont size:34*SCALE];
    @try {
        label.text = [self.mContext.mWinTexts objectAtIndex:(self.mContext.mWinTextIndex++%self.mContext.mWinTexts.count)];
        label.textColor = [self.mContext.mWinColors objectAtIndex:(self.mContext.mWinColorIndex++%self.mContext.mWinColors.count)];
        label.font = font;
        
        if(label.textColor==[self.mContext.mWinColors objectAtIndex:1] || label.textColor==[self.mContext.mWinColors objectAtIndex:2]
           || label.textColor==[self.mContext.mWinColors objectAtIndex:6]){
            label.layer.shadowColor = [[UIColor blueColor] CGColor];
            label.layer.shadowOffset = CGSizeMake(2, 2);
            label.layer.shadowRadius = 1.0;
            label.layer.shadowOpacity = 0.65;
        }
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
    } @catch (NSException *exception) {
        
    }
    
    [container addSubview:label];
    return container;
}

-(void)enableTieptuc
{
    self.tieptuc.enabled = YES;
}

-(void)disableTieptuc:(int)time
{
    self.tieptuc.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(enableTieptuc) userInfo:nil repeats:NO];
}

- (void) WinScreenShowFullAdsOnline
{
    self.mContext.showAdsCount++;
    int found = 0;
    for ( NSString* str in [self.mContext.bc_interstitial_positions componentsSeparatedByString:@","]) {
        if([str intValue] == self.mContext.showAdsCount){
            found = 1;
            break;
        }
    }
    
    if(found == 1){
        [self showCustomAdsOnline];
    }else{
        [self officialAds];
    }
    
}

- (void) WinScreenShowFullAdsOffline
{
    
    self.mContext.showCustomAdsCount++;
    
    AdvItem * item = [self.mContext getOfflineFullAdv];
    if(item != nil)
    {
        [self showCustomAds:item];
        [self.mContext LogView:self.advCurrent];
    }
    
}



-(void)showCustomAdsOnline
{
    self.mContext.showCustomAdsCount++;
    int index = self.mContext.showCustomAdsCount% self.mContext.advArrayOnline.count;
    
    AdvItem * item = [self.mContext.advArrayOnline objectAtIndex:index];
    
    [self showCustomAds:item];
    
    [self.mContext LogView:self.advCurrent];
}

-(void)showCustomAds:(AdvItem*) item
{
    
    self.advCurrent = item;
    
    NSData* data = [self.mContext loadCachedUrl:item.image];
    
    UIImage* img = [UIImage imageWithData:data] ;
    if (img == nil) return;
    UIView* background = [self addBackground_new:img];
    
    UIButton*closebutton = [[UIButton alloc] initWithFrame:CGRectMake( 320-60,0, 60, 60)];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    imgview.image = [UIImage imageNamed:@"close"];
    imgview.contentMode = UIViewContentModeCenter;
    [closebutton addSubview:imgview];
    [closebutton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    self.advViewContainner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    
    [self.advViewContainner addSubview:background];
    [self.advViewContainner addSubview:closebutton];
    
    UIButton* mainButton = [[UIButton alloc] initWithFrame:CGRectMake( 0,60,screenW, screenH - 60)];
    [mainButton addTarget:self action:@selector(OpenAdvLink:) forControlEvents:UIControlEventTouchUpInside];
    mainButton.backgroundColor = [UIColor clearColor];
    
    [self.advViewContainner addSubview:mainButton];
    [self.view addSubview:self.advViewContainner];
    
}

-(void) OpenAdvLink:(UIButton*)sender
{
    [[AppDelegate getInstance].tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"CustomAdv"     // Event category (required)
                                                                                    action:@"Clicked"  // Event action (required)
                                                                                     label:self.advCurrent.name        // Event label
                                                                                     value:nil] build]];
    
    [self.mContext LogClick:self.advCurrent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.advCurrent.click_url]];
}

-(void) close:(UIButton*)sender
{
    [self.advViewContainner removeFromSuperview];
    self.advViewContainner = nil;
}



-(UIView*)addBackground_new:(UIImage*) background
{
    
    UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollview.scrollEnabled = NO;
    
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:background];
    
    CGFloat IMG_W = background.size.width/2;
    CGFloat IMG_H = background.size.height/2;
    
    CGFloat IMG_NEW_H = screenH;
    CGFloat IMG_NEW_W = 0;
    
    IMG_NEW_W = IMG_NEW_H * IMG_W / IMG_H ;
    
    if(IMG_NEW_W < screenW){
        IMG_NEW_W = screenW;
        IMG_NEW_H = IMG_NEW_W * IMG_H / IMG_W ;
    }
    
    imgView.frame = CGRectMake((screenW - IMG_NEW_W)/2, (screenH - IMG_NEW_H)/2, IMG_NEW_W,IMG_NEW_H);
    [scrollview addSubview:imgView];
    
    return scrollview;
    
}


- (void) officialAds
{
    int ADMOD_SHOW_INDEX = 1;
    int STARTAPP_SHOW_INDEX = 2;
    int APPNEXT_SHOW_INDEX = 0;
    
    int countAds = 0;

    countAds++;

    ADMOD_SHOW_INDEX = 0;
    STARTAPP_SHOW_INDEX = 1;

    

    if((self.mContext.countShowAsd%countAds)==ADMOD_SHOW_INDEX){
        [self showGoogleAdMobView];
    }
    
    self.mContext.countShowAsd = self.mContext.countShowAsd + 1;
}




- (void)PopupOpened
{
    self.tieptuc.enabled = YES;
    
}
- (void)PopupClosed
{
    self.tieptuc.enabled = YES;
}

- (void)PopupClicked
{
    
}


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    self.tieptuc.enabled = YES;
    [interstitial_ presentFromRootViewController:self];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.tieptuc.enabled = YES;
}


#pragma mark Google AdMob



- (void) showGoogleAdMobView {
    

    if(interstitial_ != nil){
        interstitial_ = nil;
    }
    interstitial_ = [[GADInterstitial alloc] initWithAdUnitID:K_AdMobPublicID];
    interstitial_.delegate = self;
    interstitial_.delegate = self;
    [interstitial_ loadRequest:[GADRequest request]];
    

    
    
}





@end
