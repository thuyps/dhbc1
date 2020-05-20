
#import "config.h"
#import "HomeViewController.h"
#import "WPUtils.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "Reachability.h"
#import "GamePlayViewController.h"

#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "xOutputStream.h"
#import "WPUtils.h"

#import "KiemRubyViewController.h"

#import "AdvItem.h"

@interface HomeViewController ()
{
    
    Reachability *internetReachableFoo;
    WebViewController *userinfo;
    NSString *linkitunes;
}

@property (strong) UILabel* mLevelLabel;
@property (strong) UIButton* choingayButton;
@property (strong) NSTimer* scheduleDownloadAdvImage;

@end


@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
   [self loadLocalAdv];
    if(self.mContext.showAdsCount > 10){
        self.mContext.showAdsCount = 0;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delayReloadRuby) name:@"delayReloadRuby" object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUILevel:) name:@"UPDATE_HOME_LEVEL" object:nil];
    
    NSData* data = [self loadVersionInfo];
    
    if(data != nil){
        [self parseVersionInfo:data];
   
    }
    
    [self CreateUI];

#ifdef BATCHU2
    [self onloadBatchu2];
#else
   [self onloadBatchu1];
#endif
    
 
    
}


-(void) onloadBatchu1
{
     [self downloadVersionInfo1];
    
    if(self.mContext.mUserID == nil || [self.mContext.mUserID isEqualToString:@""])
    {

        [self showLoadingProgress];
        
        [self deviceIDLogin];
        
        
    }
    else
    {
 
        [self deviceIDLogin];
   
    }
    
}

-(void) onloadBatchu2
{
    
    if(self.mContext.mUserID == nil || [self.mContext.mUserID isEqualToString:@""])
    {

        if (self.mContext.mAllowSync != nil &&  [self.mContext.mAllowSync isEqualToString:@"1"]) {
            _choingayButton.enabled = NO;
        }
        
        
       // [self createUserIDifInternetReachable];
         [self deviceIDLogin];
        [self checkupdateVersion];

    }
    else
    {
        //[self createUserIDifInternetReachable];
        
        [self deviceIDLogin];
        
        [self checkupdateVersion];
        
    }

}


#ifdef BATCHU2
-(void)batchu2Sync
{
    
/*
#ifdef DEBUG
    self.mContext.mAllowSync = @"1";
#endif
  */
    
    if(self.mContext.mAllowSync == nil || ![self.mContext.mAllowSync isEqualToString:@"1"] ){
        return;
    }
    
    if(self.mContext.mIsSync){
        return;
    }
    
    _choingayButton.enabled = NO;
    //thong bao dong bo
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Bắt Chữ 2"];
    
    [dialog setMessage:@"Đây là phiên bản khởi đầu từ câu thứ 900. Bạn cần hoàn thành hết các câu hỏi ở bản bắt chữ 1 để tiếp tục. Nếu đã hoàn thành, bạn có thể đồng bộ tài khoản từ Bắt Chữ 1 sang Bắt Chữ 2"];
    
    [dialog addButtonWithTitle:@"Thoát"];
    [dialog addButtonWithTitle:@"Đồng ý"];
    dialog.tag = 12;
    
    [dialog show];
   
}
#endif

-(void) readPromoteInfoApp
{
   
    
    NSData *data = [self loadVersionInfo];
    
    if (data == nil)
    {
        return;
    }
    
    NSError* error;
    NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
    
    BM4Log(@"%@",[lvObjUserInfo description]);
    
    
    
    NSString* lvResult = [lvObjUserInfo objectForKey:TAG_RESULT];
    
    if (lvResult == nil )
    {
        return;
    }
    
    lvResult =
    [lvResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
  
    
    if([lvResult isEqualToString:@"OK"]){
        
        
        NSString* temp = [lvObjUserInfo objectForKey:@"promotion_asking"];
        
        if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.promotion_asking isEqualToString:temp]){
            self.mContext.promotion_asking = temp;
            
        }
        
        temp = [lvObjUserInfo objectForKey:@"promotion_icon"];
        
        if(temp != nil /*&& ![temp isEqualToString:@""]*/ && ![self.mContext.promotion_icon isEqualToString:temp]){
            self.mContext.promotion_icon = temp;
            
        }
        
        temp = [lvObjUserInfo objectForKey:@"promotion_url"];
        
        if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.promotion_url isEqualToString:temp]){
            self.mContext.promotion_url = temp;
            
        }
        temp = [lvObjUserInfo objectForKey:@"more_app_link"];
        
        if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.more_app_link isEqualToString:temp]){
            self.mContext.more_app_link = temp;
            
        }
        
    }
    
}



-(void) receiveupdateVersion
{
   
    
    NSData* data = [self loadVersionInfo];
    if(data != nil){
        [self parseVersionInfo:data];
        [self reCreateUI];
    }
    
#ifdef BATCHU2
    
    if(self.mContext.mAllowSync == nil || ![self.mContext.mAllowSync isEqualToString:@"1"] ){
        return;
    }
    
    if(self.mContext.mIsSync){
        return;
    }
    
    
    if(!self.mContext.mIsSync && self.mContext.mIsSyncNative == NO && self.mContext.mAllowSync != nil && [self.mContext.mAllowSync isEqualToString:@"1"]){
        
        self.mContext.mIsSyncNative = YES;
        [self.mContext saveLocalData];
        NSString* str = [NSString stringWithFormat:@"weplaybatchu1://weplay?from=weplaybatchu2"];
        
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        
    }else{
        [self batchu2Sync];
    }
  
    

#endif
    
    
}

-(void) checkupdateVersion
{
    NSData *data = [self loadVersionInfo];
    
    if(data != nil){
        [self parseVersionInfo:data];
    }
    [self downloadVersionInfo1];
}

-(void)parseVersionInfo:(NSData*)data
{
    
    if (data != nil)
    {
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
            
            BOOL changed = false;
            
            if([lvResult isEqualToString:@"OK"]){
                NSString * advertisement_id = [lvObjUserInfo objectForKey:@"advertisement_id"];
                if(advertisement_id != nil && ![advertisement_id isEqualToString:@""] && ![advertisement_id isEqualToString:self.mContext.mAdmodID] ){
                    self.mContext.mAdmodID = advertisement_id;
                    changed = true;
                }
                
                
                
                
                NSString* temp = [lvObjUserInfo objectForKey:@"delay_adv_in_second"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0 && ![self.mContext.delay_adv_in_second isEqualToString:temp] ){
                    self.mContext.delay_adv_in_second = temp;
                    changed = true;
                }
                
                
                temp = [lvObjUserInfo objectForKey:@"show_banner_in_game"];
                if(temp != nil && ![temp isEqualToString:@""]){
                    self.mContext.show_banner_in_game = [temp intValue];
                }

                
                
                temp = [lvObjUserInfo objectForKey:@"push_message"];
                
                if(temp != nil && ![temp isEqualToString:@""] ){
                    long current_time = time(0);
                    
                    int one_day = 16*60*60;
                    if ((self.mContext.time_push + one_day) < current_time)
                    {
                        self.mContext.time_push = current_time;
                        self.mContext.push_message = @"";
                        changed = true;
                    }
                    
                    if (![self.mContext.push_message isEqualToString:temp] || (self.mContext.time_push - current_time) > 16*60*60)
                    {
                        self.mContext.push_message = [lvObjUserInfo objectForKey:@"push_message"];
                        [WPUtils alert:self.mContext.push_message FromController:self];
                    }else{
                        self.mContext.push_message = @"";
                    }
                    
                    changed = true;
                }
                

                
                temp = [lvObjUserInfo objectForKey:@"addition_ruby"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0  && ![self.mContext.mScoreAds isEqualToString:temp]){
                    self.mContext.mScoreAds = temp ;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"total_advs_a_day"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0  && ![self.mContext.total_advs_a_day isEqualToString:temp]){
                    self.mContext.total_advs_a_day = temp;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"sms_number"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0 && ![self.mContext.mSmsNumber
                                                                                          isEqualToString:temp]){
                    self.mContext.mSmsNumber = temp;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"level_mod_to_adv"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0 && self.mContext.level_mod_to_adv != [temp intValue] ){
                    self.mContext.level_mod_to_adv = [temp intValue] ;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"request_network_level"];
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] > 0 && self.mContext.request_network_level != [temp intValue] ){
                    self.mContext.request_network_level = [temp intValue] ;
                    changed = true;
                }
                
#ifdef IS_FREE_VERSION
                self.mContext.is_release_version = 0;
#else
                temp = [lvObjUserInfo objectForKey:@"disable_payment_version"];
                
                self.mContext.is_release_version = 1;
#endif
#ifdef BATCHU2
                self.mContext.mAllowSync = @"1";
                
#endif
                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                if(temp != nil && ![temp isEqualToString:@""]){
                    if([temp isEqualToString:version]){
                        self.mContext.is_release_version = 0;
                        
#ifdef BATCHU2
                        self.mContext.mAllowSync = @"0";
#endif
                        
                    }
                }
                
                
                
                
                
                temp = [lvObjUserInfo objectForKey:@"sms_syntax"];
                if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.sms_syntax isEqualToString:temp]){
                    self.mContext.sms_syntax = temp;
                    changed = true;
                }

                temp = [lvObjUserInfo objectForKey:@"is_blocked"];
                
                if(temp != nil && ![temp isEqualToString:@""] && [temp intValue] == 1 ){
                    self.mContext.is_blocked = 1 ;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"promotion_asking"];
                
                if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.promotion_asking isEqualToString:temp]){
                    self.mContext.promotion_asking = temp;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"promotion_icon"];
                
                if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.promotion_icon isEqualToString:temp]){
                    self.mContext.promotion_icon = temp;
                    changed = true;
                }
                
                temp = [lvObjUserInfo objectForKey:@"promotion_url"];
                
                if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.promotion_url isEqualToString:temp]){
                    self.mContext.promotion_url = temp;
                    changed = true;
                }
                temp = [lvObjUserInfo objectForKey:@"more_app_link"];
                
                if(temp != nil && ![temp isEqualToString:@""] && ![self.mContext.more_app_link isEqualToString:temp]){
                    self.mContext.more_app_link = temp;
                    changed = true;
                }
                                
                
                if(changed)
                    [self.mContext saveLocalData];
                
                NSString* appstoreversion = [lvObjUserInfo objectForKey:@"version"];
                //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                
                if (appstoreversion != nil && ![appstoreversion isEqualToString:@""])
                {
                    if ([appstoreversion compare:version] > 0)
                    {
                        
                        NSString* update_ask = [lvObjUserInfo objectForKey:@"update_ask"];
                        NSString* must_update = [lvObjUserInfo objectForKey:@"must_update"];
                        linkitunes = [lvObjUserInfo objectForKey:@"update_url"];
                        if([update_ask isEqualToString:@""])
                        {
                            update_ask = @"Cập nhật phiên bản mới";
                        }
                        
                        UIAlertView* dialog = [[UIAlertView alloc] init];
                        [dialog setDelegate:self];
                        [dialog setTitle:@"Thông tin"];
                        
                        [dialog setMessage:update_ask];
                        
                        
                        if([must_update isEqualToString:@"1"]){
                            
                            [dialog addButtonWithTitle:@"Đồng ý"];
                            [dialog addButtonWithTitle:@"Thoát"];
                            dialog.tag = 10;
                            
                        }else{
                            [dialog addButtonWithTitle:@"Đồng ý"];
                            [dialog addButtonWithTitle:@"Bỏ qua"];
                            dialog.tag = 9;
                        }
                        
                        [dialog show];
                        
                    }
                    
                }
            }
        }
     
    }
    

}



-(void) downloadVersionInfo1
{
    
    long seconds = time(0);
    
    NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [self.mContext MD5:lvBaseChecksum];
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:GET_VERSION_INFO_URL];
    [sDataUrl appendString: @"?game_id="];
    [sDataUrl appendString:GAME_ID];
    
    if(self.mContext.mUserID!=nil && ![self.mContext.mUserID isEqualToString:@""])
    {
        [sDataUrl appendString: @"&user_id="];
        [sDataUrl appendString:self.mContext.mUserID];
    }
    
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    
    [sDataUrl appendString: @"&device_os=iOS"];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    if(self.mContext.mRefID != nil && ![self.mContext.mRefID isEqualToString:@""]){
        
#ifdef VCC
        [sDataUrl appendString: @"&refid="];
#else
        [sDataUrl appendString: @"&refcode="];
#endif
        [sDataUrl appendString:self.mContext.mRefID];
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    
        NSURL *url = [NSURL URLWithString:sDataUrl];
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:12];
        [request setHTTPMethod:@"GET"];
        
        
    
        
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError)
         {
            
             if(data != nil){
                 
                 NSData* oldData = [self loadVersionInfo];
                 
                 if(oldData == nil){
                     [self saveVersionInfo:data];
                     [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(receiveupdateVersion) userInfo:nil repeats:NO];
                 }else{
                     [self saveVersionInfo:data];
                 }
             }
             
             
         }];
        
        
        
        
        
        
    }


-(void) downloadIcon :(NSString*)urlString
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
         if (data==nil)
             return;
         
         UIImage* img = [UIImage imageWithData:data];
         
         if(img == nil)
             return ;
         
         NSString *docsDir;
         NSArray *dirPaths;
         
         dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         docsDir = [dirPaths objectAtIndex:0];
         
         NSString * filename = [self.mContext cachedFileNameForKey:self.mContext.promotion_icon];
         
         NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
         
         [data writeToFile:databasePath atomically:YES];
         
         [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reCreateUI) userInfo:nil repeats:NO];
     }];
 
}

/*
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}*/



-(void) saveVersionInfo:(NSData*) data1
{
    NSString * key = [self.mContext cachedFileNameForKey:SECRET_KEY];
    NSData* data = [WPUtils obfuscate:data1 withKey:key];
    if (data==nil)
        return;
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"versioninfo"]];
    [data writeToFile:databasePath atomically:YES];
}

-(NSData*) loadVersionInfo
{
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"versioninfo"]];
    NSData *data1 = [NSData dataWithContentsOfFile:databasePath];
    if (data1==nil)
        return nil;
    
    NSString * key = [self.mContext cachedFileNameForKey:SECRET_KEY];
    NSData* data = [WPUtils obfuscate:data1 withKey:key];
    return data;
}

-(void)reCreateUI
{
    for (UIView* view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    [self CreateUI];
}

-(void) CreateUI
{
   

    
    [self addBackGroundScaleFill:@"bg"];
    
    UIImageView *topbar  = [WPUtils createViewFromImage:@"topbar.png" Scale:screenW/320.0];
    
    [WPUtils addView:topbar withPoint:CGPointMake(screenW/2, 0) withAlignment:CustomAlignTopCenter toView:self.view];
    
    
    UIFont* font = [UIFont fontWithName:kLevelFont size:kLevelFontSize*screenH/568];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:topbar.frame];
    titleLabel.textColor = [WPUtils colorFromString:@"0000fe"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = font;
    titleLabel.text = [NSString stringWithFormat:@"%d", self.mContext.mLevel ];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
    titleLabel.layer.shadowOffset = CGSizeMake(2, 2);
    titleLabel.layer.shadowRadius = 1.0;
    titleLabel.layer.shadowOpacity = 0.65;
    self.mLevelLabel = titleLabel;
    [self.view addSubview:titleLabel];
    
    
    UIButton* choingayButton = [WPUtils createButtonFromImage:@"choingay_new" Text:nil Scale:screenH/568];
    
    [choingayButton addTarget:self action:@selector(choingayAction:) forControlEvents:UIControlEventTouchUpInside];
   
    _choingayButton = choingayButton;
    
    [WPUtils addView:choingayButton withPoint:CGPointMake(screenW/2, screenH/2) withAlignment:CustomAlignBottomCenter toView:self.view];
    
    
    
    
    
    UIImageView* batchu = [WPUtils createViewFromImage:@"batchu.png" Scale:screenH*2/568];
    
    [WPUtils addView:batchu withPoint:CGPointMake(screenW/2, (CGRectGetMaxY(topbar.frame)+CGRectGetMinY(choingayButton.frame))/2) withAlignment:CustomAlignMidleCenter toView:self.view];
  

   
    

#ifdef BATCHU2
    if(self.mContext.is_release_version == 1 && self.mContext.mIsSync == YES){
        [self addKiemRubyButton];
    }else{
        _choingayButton.frame = CGRectMake(_choingayButton.frame.origin.x,_choingayButton.frame.origin.y+_choingayButton.frame.size.height/2,_choingayButton.frame.size.width,_choingayButton.frame.size.height);
    }
#else
    if(self.mContext.is_release_version == 1){
        [self addKiemRubyButton];
    }else{
        _choingayButton.frame = CGRectMake(_choingayButton.frame.origin.x,_choingayButton.frame.origin.y+_choingayButton.frame.size.height/2,_choingayButton.frame.size.width,_choingayButton.frame.size.height);
    }
    
#endif
    
    [self addSoundButton];
    [self addInfoButton];
    [self addRateButton];
    
    UIButton* userinfoButton = [WPUtils createButtonFromImage:@"btn_user.png" Text:nil Scale:screenH/568];
    
    [userinfoButton addTarget:self action:@selector(userinfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addBottomButton:userinfoButton Index:4];
    
    
    [self readPromoteInfoApp];
    
   
    
    int backgroundH = 70;
    int spaceH = 65;
    int spaceV = 15;
    int numberofItem = 1;
    
    int itemH = 57;
    int itemW = 57;
    
 
    if(self.mContext.promotion_icon != nil && ![self.mContext.promotion_icon isEqualToString:@""])
    {
        numberofItem = 2;
    }

    
    UIView* view = nil;
    UIImage* img = nil;
    
    UIButton* moreAppsButton = [WPUtils createButtonFromImage:@"icon_more_apps" Text:nil Scale:screenH/568];
    
     itemH = CGRectGetWidth(moreAppsButton.frame);
     itemW = CGRectGetHeight(moreAppsButton.frame);;
   
    backgroundH = CGRectGetHeight(moreAppsButton.frame)*1.3;
    
    spaceH = screenH - CGRectGetMinY(userinfoButton.frame);
    
    
    if(numberofItem >0)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW ,backgroundH)];
        
        
        view.alpha = 0.3 ;
        view.backgroundColor = [UIColor grayColor];
        [WPUtils addView:view withPoint:CGPointMake(screenW/2, screenH -spaceH ) withAlignment:CustomAlignBottomCenter toView:self.view];
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - backgroundH-spaceH, screenW ,backgroundH)];
        view.backgroundColor = [UIColor clearColor];
        
        img = [UIImage imageNamed:@"icon_more_apps"];
        
        UIButton *bt = [[UIButton alloc] init];
        
        if(numberofItem == 1){
            bt.frame = CGRectMake(screenW/2 - itemW/2 , (backgroundH - itemH)/2,itemW, itemH);
        }else{
            bt.frame = CGRectMake(screenW/2 + spaceV , (backgroundH - itemH)/2,itemW, itemH);
        }
        
        
        
        [bt setImage:img forState:UIControlStateNormal];
        [bt addTarget:self action:@selector(openMoreApp:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:bt];
    }
    UIButton *bt;
    if(numberofItem > 1)
    {
        @try{
           
            NSData *data = nil;
            if(self.mContext.promotion_icon != nil && ![self.mContext.promotion_icon isEqualToString:@""] )
            {
                NSString * filename = [self.mContext cachedFileNameForKey:self.mContext.promotion_icon];
                NSString *docsDir;
                NSArray *dirPaths;
                
                dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                docsDir = [dirPaths objectAtIndex:0];
                NSString *fullpath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
                
                data = [NSData dataWithContentsOfFile:fullpath];
            }
            if(data != nil){
                img = [UIImage imageWithData:data];
                
            }else{
                img = [UIImage imageNamed:@"icon_2048"];
                [self downloadIcon:self.mContext.promotion_icon];
            }
            
            bt = [[UIButton alloc] init];
            bt.frame = CGRectMake(screenW/2-spaceV - itemW, (backgroundH - itemH)/2,itemW, itemH);
            
            
            
            [bt setImage:img forState:UIControlStateNormal];
            
            [bt addTarget:self action:@selector(openPromoteApp:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:bt];
        }@catch(NSException* ex){
        
        }
    }

    if(numberofItem > 0)
    {
        [self.view addSubview:view];
    }
   
}

- (IBAction)openPromoteApp:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.mContext.promotion_url]];
}

- (IBAction)openMoreApp:(id)sender
{
    if(self.mContext.more_app_link == nil || [self.mContext.more_app_link isEqualToString:@""]){
        self.mContext.more_app_link = @"https://itunes.apple.com/vn/artist/son-thuy-pham/id405005883";
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.mContext.more_app_link]];
}

#define RUBY_IMAGE1 @"kiemruby_new"
#define RUBY_IMAGE2 @"kiemruby2_new"

//#define RUBY_IMAGE1 @"ruby_onl.png"
//#define RUBY_IMAGE2 @"ruby_onl_new.png"


-(UIButton*)addKiemRubyButton
{
    
    UIButton* kiemrubyButton;
    
    if(self.mContext.kiemruby == 1){
        kiemrubyButton = [WPUtils createButtonFromImage:RUBY_IMAGE1 Text:nil Scale:screenH/568];
    }else{
        kiemrubyButton = [WPUtils createButtonFromImage:RUBY_IMAGE2 Text:nil Scale:screenH/568];
        
    }
    [WPUtils addView:kiemrubyButton withPoint:CGPointMake(screenW/2 , CGRectGetMaxY(_choingayButton.frame)+CGRectGetHeight(_choingayButton.frame)) withAlignment:CustomAlignTopCenter toView:self.view];
    
    [kiemrubyButton addTarget:self action:@selector(kiemrubyAction:) forControlEvents:UIControlEventTouchUpInside];
   
    
    return kiemrubyButton;
}

/*
-(UIButton*)addKiemRubyButton1
{
    
    UIImage* img;
    
    if(self.mContext.kiemruby == 1){
        img = [UIImage imageNamed:@"kiemruby_new"];
    }else{
        img = [UIImage imageNamed:@"kiemruby2_new"];
    }
    
    
    CGFloat w = img.size.width/2;
    CGFloat h = img.size.height/2;
    
    
    UIButton *bt = [[UIButton alloc] init];
    
    int y;
    if(self.view.frame.size.height < 490){
        y = 270;
    }else{
        y = 270*self.view.frame.size.height/480;
    }
    
 
    
    bt.frame = CGRectMake((320-w)/2, y,w, h);
    
    [bt setImage:img forState:UIControlStateNormal];
    
    [bt addTarget:self action:@selector(kiemrubyAction:) forControlEvents:UIControlEventTouchUpInside];
    [bt setExclusiveTouch:YES];
    [self.view addSubview:bt];

    return bt;
}*/




-(void)addRateButton
{
    
  
    
    
    
   UIButton* bt = [WPUtils createButtonFromImage:@"btn_rate" Text:nil Scale:screenH/568];

   [bt addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self addBottomButton:bt Index:3];
 
    
    
}


-(void) addBottomButton:(UIButton*)bt Index:(int)index
{
    CGFloat margin = 10*screenW/320;
    
    UIImage* img = [UIImage imageNamed:@"btn_rate.png"];
    CGFloat w = screenH/568*img.size.width/2;
    CGFloat space = (screenW - 4*w - 2* margin)/5.0;

   [WPUtils addView:bt withPoint:CGPointMake(margin+space*index+w*(index-1)+w/2.0 , screenH - CGRectGetHeight(bt.frame)) withAlignment:CustomAlignMidleCenter toView:self.view];
    
}




-(void)addInfoButton
{
   /* UIImage* img = [UIImage imageNamed:@"info"];
    
    CGFloat w = screenH/568*img.size.width/2;
    CGFloat h = screenH/568*img.size.height/2;
   
    
    UIButton *bt =  [[UIButton alloc] init];
    
    bt.frame = CGRectMake(INFO_X, screenH-10-(h*MODIFY_POS),w, h);

    [bt setImage:img forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(infoAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:bt];
    */
    
    
    UIButton* bt = [WPUtils createButtonFromImage:@"info.png" Text:nil Scale:screenH/568];
    
    [bt addTarget:self action:@selector(infoAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addBottomButton:bt Index:2];
    
    
}

-(void)addUserButton
{
   
   
}

-(void)addSoundButton
{
    
    
    UIButton* bt = [WPUtils createButtonFromImage:@"sound1.png" Text:nil Scale:screenH/568];
    
    if(self.mContext.mSoundEnable==1){
        [bt setImage:[UIImage imageNamed:@"sound1.png"] forState:UIControlStateNormal];
    }else{
        [bt setImage:[UIImage imageNamed:@"sound2.png"] forState:UIControlStateNormal];
    }
    
    
    [bt addTarget:self action:@selector(changeSoundAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addBottomButton:bt Index:1];
    
    
}




- (BOOL) checkCurrentConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        BM4Log(@"There IS NO internet connection");
        return NO;
    }
    return YES;
}



-(void)rateButtonAction:(UIButton*)sender
{
    
    [self.mContext playEffect:kSoundDing];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.mContext getItunesLink]]];
    
}




-(void)kiemrubyAction:(UIButton*)sender
{
    self.mContext.kiemruby = 1;

    
    KiemRubyViewController* kiemRuby = [[KiemRubyViewController alloc] init];
    
    [self presentViewController:kiemRuby animated:NO completion:nil];
}

-(void)choingayAction:(UIButton*)sender
{
/*
#ifdef DEBUG
    self.mContext.mLevel = 1610;
#endif*/
    
#ifdef BATCHU2
    [self batchu2Sync];
    
    if(self.mContext.mAllowSync != nil && [self.mContext.mAllowSync isEqualToString:@"1"] ){
        if(!self.mContext.mIsSync){
            
            return;
        }
    }
#endif
   

    
#ifdef BATCHU2
     if(self.mContext.mLevel < 900 )
     {
          [WPUtils alert:@"Bạn phải vượt qua 900 level của Bắt chữ 1 mới có thể tiếp tục!"];
         return;
     }
#endif
    
    
    if(self.mContext.levelDownloading<(MAX_BUNDLE_LEVEL+1))
    {
        self.mContext.levelDownloading = MAX_BUNDLE_LEVEL+1;
        
    }
    if(self.mContext.levelDownloading < self.mContext.mLevel && self.mContext.mLevel >=(MAX_BUNDLE_LEVEL+1))
        self.mContext.levelDownloading = self.mContext.mLevel;
    
    [self.mContext playEffect:kSoundDing];
    
    if(self.mContext.mLevel > self.mContext.mTotalLevels)
    {
        if(![self checkCurrentConnection]){
            [WPUtils alert:sConnectionError FromController:self];
            return;
        }
        //update max level
        if(!self.mContext.mIsLogin){ // if chua login
            [self deviceIDLogin];
        }
        if(self.mContext.mLevel >self.mContext.mTotalLevels)
        {
            
            
            if(self.mContext.promotion_asking != nil && ![self.mContext.promotion_asking isEqualToString:@""]){
                UIAlertView* dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:self];
                [dialog setTitle:@"Thông báo"];
                dialog.tag = 2;
                [dialog setMessage:[NSString stringWithFormat:@"Bạn thật xuất sắc đã vượt qua hết các level hiện có.\n %@",self.mContext.promotion_asking]];
                [dialog addButtonWithTitle:@"Đồng ý"];
                [dialog addButtonWithTitle:@"Bỏ qua"];
                [dialog show];
            }else{
                [WPUtils alert:sMaxLevelMesage FromController:self];
            }
            return;
        }
    }
    
    if (self.mContext.mLevel == self.mContext.levelDownloading){
        //loading level
        if(![self checkCurrentConnection]){
            [WPUtils alert:sConnectionError FromController:self];
            return;
        }
        
        [[AppDelegate getInstance].tracker
         send:[[GAIDictionaryBuilder createEventWithCategory:@"LoadData"
           action:@"choiphailoadlevel"
              label:nil        // Event label
                 value:nil] build]];
        

        [self showLoadingProgress];
        
        if(self.mContext.mUserID==nil){
            //device login
            [self deviceIDLogin];
        }
        //download
        NSString *sDataUrl = [self.mContext getDataUrlLevelDownload:YES];
        
        BM4Log(@"%@",sDataUrl);
        
        NSURL *url = [NSURL URLWithString:sDataUrl];
        //initialize a request from url
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   [self stopLoadingProgress];
                                   if(data==nil || ![self.mContext checkData:data withLevel:self.mContext.levelDownloading]){
                                       [WPUtils alert:sConnectionError FromController:self];
                                   }else{
                                       [data writeToFile:[self.mContext filename:self.mContext.levelDownloading] atomically:YES];
                                       [self.mContext loadLevel:data];
                                       self.mContext.levelDownloading++;
                                       [self.mContext DownloadLevel];
                                       [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gotoGamePlay) userInfo:nil repeats:NO];
                                   }
                                   
                               }];

        return;
        
    }else if(self.mContext.mLevel < self.mContext.levelDownloading){
        [self.mContext loadLevelData];
        [self gotoGamePlay];
    }
   
    
}





#pragma ACTION


-(void)changeSoundAction:(UIButton*)sender
{
    [self.mContext toggleSound];
    if(self.mContext.mSoundEnable){
        [sender setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"sound2"] forState:UIControlStateNormal];
    }
   [self.mContext playEffect: kSoundDing];
    
    [self.mContext saveLocalData];
}

-(void)infoAction
{
    
     [self.mContext playEffect: kSoundDing];
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Thông tin"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    //NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
   NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString* msg ;
#ifdef BATCHU2
    msg = [NSString stringWithFormat:@"\nBẮT CHỮ 2\nVersion: %@\nEmail: services@weplay.vn\n(C)2013-WePlay.vn",build];
#else
    msg = [NSString stringWithFormat:@"\nBẮT CHỮ\nVersion: %@\nEmail: services@weplay.vn\n(C)2013-WePlay.vn",build];
#endif
    
    [dialog setMessage:msg];
    
    [dialog addButtonWithTitle:@"Đóng"];
    /*
    if(self.mContext.mUserID != nil && ![self.mContext.mUserID isEqualToString:@""] ){
        [dialog addButtonWithTitle:@"Tài khoản"];
    }*/
    
    dialog.tag = 5;

    [dialog show];
    
   //dungpq remove tam [[FBSession activeSession] closeAndClearTokenInformation];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if(alertView.tag == 12 ){
            //thoat
            exit(0);
           
        }
        if(alertView.tag == 2){
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:self.mContext.promotion_url]];
        }
        if(alertView.tag == 10 || alertView.tag == 9){
            if (linkitunes == nil || [linkitunes isEqualToString:@""]){
                linkitunes = [self.mContext getItunesLink];
            }
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:linkitunes]];
        }
    }
    if (buttonIndex == 1)
    {
        if(alertView.tag == 10 ){
            //thoat
            exit(0);
           
        }else if(alertView.tag == 9 ){
        }
        
        if(alertView.tag == 12 ){
            //thoat
          //  bc_web_sync_batchu2.php
         
            userinfo = [[WebViewController alloc] init];
            [userinfo setBackViewController:self];
           // [userinfo viewWillAppear:NO];
            
            [self presentViewController:userinfo animated:YES completion:nil];
            
          /*  CGAffineTransform trans = CGAffineTransformScale(userinfo.view.transform, 0.01, 0.01);
            userinfo.view.transform = trans;
            [self.view addSubview:userinfo.view];
            [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                userinfo.view.transform = CGAffineTransformScale(userinfo.view.transform,100.0 , 100.0);
            } completion:^(BOOL finished){
                [userinfo.view removeFromSuperview];
                
                [self presentViewController:userinfo animated:NO completion:nil];
            }];
            */
        }
    }
}


-(void)userinfoButtonAction:(UIButton*)sender
{
    [sender setEnabled:NO];
    [self.mContext playEffect:kSoundDing];
    
    if(userinfo!=nil)
    {
        userinfo = nil;
    }
    
    
    userinfo = [[WebViewController alloc] init];
     [userinfo setBackViewController:self];

    
    [self presentViewController:userinfo animated:NO completion:^{
        [sender setEnabled:YES];
    }];
    
}

- (void)createUserIDifInternetReachable
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
           // BM4Log(@"Yayyy, we have the interwebs!");
             [self deviceIDLogin];
            
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            BM4Log(@"No internet connection!");
                       
        });
    };
    
    [internetReachableFoo startNotifier];
}

-(void) deviceIDLogin
{
    NSMutableURLRequest* request = [self.mContext createDeviceLoginRequest];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self stopLoadingProgress];
                               if(data == nil){
                                   UIAlertView* dialog = [[UIAlertView alloc] init];
                                   [dialog setTitle:@"Thông báo"];
                                   [dialog setMessage:@"Không đồng bộ được với server."];
                                   [dialog addButtonWithTitle:@"Đóng"];
                                   [dialog show];
                               }else{
                                   [self receiveLogin:data];
                               }
                               
                           }];
    
}

-(void) receivedLoginFail:(NSData*) data
{
    [self stopLoadingProgress];
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setTitle:@"Thông báo"];
    [dialog setMessage:@"Không đồng bộ được với server."];
    [dialog addButtonWithTitle:@"Đóng"];
    [dialog show];
}


- (void)receivedUrlData:(NSData*) data
{
    [self stopLoadingProgress];
    [self receiveLogin:data];
    
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
//#ifdef DEBUG
//    if(self.mContext.mLevel < (MAX_BUNDLE_LEVEL - 2)){
//     self.mContext.mLevel = MAX_BUNDLE_LEVEL - 2;
//    }
//   
//#endif
    GamePlayViewController* play;
    
    if(play!=nil)
    {
        play= nil;
    }
    
    play = [[GamePlayViewController alloc] init];
    [play reCreateUI];
   
    [self presentViewController:play animated:NO completion:nil];
    
}

-(void)receiveLogin:(NSData*) data
{
    BOOL loginOK = NO;
    
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
           
                loginOK = YES;
                NSString* lvUserID = [lvObjUserInfo objectForKey:TAG_USER_ID];
            
            if ( lvUserID != nil && [self.mContext.mUserID isEqualToString:@""]){
                self.mContext.mUserID = lvUserID;
                self.mContext.randomInt = 0;
                [self.mContext loadRandomData];
            }else{
                self.mContext.mUserID = lvUserID;
            }
            
            
                self.mContext.mUserID = lvUserID;
                self.mContext.mTotalLevels = [[lvObjUserInfo objectForKey:TAG_TOTALLEVEL] integerValue];
                self.mContext.mSessionID = [lvObjUserInfo objectForKey:TAG_SESSION_ID];
                self.mContext.installation_urlscheme = [lvObjUserInfo objectForKey:@"installation_urlscheme"];
                self.mContext.mIsLogin = YES;
                if(self.mContext.mLevel <= [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue]){
                    self.mContext.mLevel = [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue];
#ifdef BATCHU2
                    if( self.mContext.mLevel < 900)
                    {
                        self.mContext.mLevel = 900;
                    }
#endif

                    self.mContext.mScore = [[lvObjUserInfo objectForKey:TAG_RUBY] integerValue];
                }
            
            if((self.mContext.mTotalLevels+1) < self.mContext.mLevel){
                self.mContext.mLevel = self.mContext.mTotalLevels+1;
            }
                 
            self.mLevelLabel.text = [NSString stringWithFormat:@"%d",self.mContext.mLevel];
            
                [self.mContext saveLocalData];
            
        }
    }
    
    if(!loginOK){
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setTitle:@"Thông báo"];
        [dialog setMessage:@"Không đồng bộ được với server."];
        [dialog addButtonWithTitle:@"Đóng"];
        [dialog show];
    }else{
#ifdef BATCHU2
        if(self.mContext.mIsSync == YES){
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(downloadCustomAdv) userInfo:nil repeats:NO];
        }
#else
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(downloadCustomAdv) userInfo:nil repeats:NO];
#endif
        
        
        
    }
    
}




-(void)delayReloadRuby
{
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    BOOL networkCheck =  [app checkCurrentConnection];
    if(!networkCheck){
        return;
    }
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    //self.HUD.labelText = @"Lấy thông tin tài khoản...";
    self.HUD.labelText = @"Cập nhật tài khoản...";
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
   
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(reloadRuby) userInfo:nil repeats:NO];

}


-(void)reloadRuby
{
    if(_choingayButton.enabled == NO){
        _choingayButton.enabled = YES;
        [self deviceIDLogin];
    }
    else{
        
        
        NSMutableURLRequest* request = [self.mContext createGetUserDataRequest];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   [self stopLoadingProgress];
                                   if(data == nil){
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
                                           self.mContext.mScore = [[lvObjUserInfo objectForKey:TAG_RUBY] integerValue];
                                           self.mContext.mLevel = [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue];
                                           // self.mLevelLabel.text = [NSString stringWithFormat:@"%d",self.mContext.mLevel];
                                           [self.mContext saveLocalData];
                                       }
                                   }
                                   
                               }];
        
        
    }
}

/*-(void)reloadRuby
{
    if(_choingayButton.enabled == NO){
        _choingayButton.enabled = YES;
        [self deviceIDLogin];
    }
    else{
        NetworkManager* net = [NetworkManager sharedInstance];
        [net getUserData];
        net.delegate = self;
    }
}*/

-(void)receivedReloadData:(NSData*) data
{
    
    [self stopLoadingProgress];
    
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
            self.mContext.mScore = [[lvObjUserInfo objectForKey:TAG_RUBY] integerValue];
            self.mContext.mLevel = [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue];
#ifdef BATCHU2
            if( self.mContext.mLevel < 900)
            {
                self.mContext.mLevel = 900;
            }
#endif
            self.mLevelLabel.text = [NSString stringWithFormat:@"%d",self.mContext.mLevel];
            [self.mContext saveLocalData];
        }
    }
    
    
}

-(void) downloadCustomAdv
{
    
    NSURL *url = [NSURL URLWithString:@"http://advnetwork.weplay.vn/adv_v2/get_adv_info.php"];
   
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];

    [request setHTTPMethod:@"POST"];

    NSMutableString *sDataUrl = [self.mContext basicAdvData];
    BM4Log(@"%@",sDataUrl);

    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];

    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self handleDownloadCustomAdv:response withData:data withError:connectionError];
                           }];
    
    
    
}

- (void)handleDownloadCustomAdv:(NSURLResponse *)request withData:(NSData*) data withError:(NSError*)connectionError
{
    
    if(data != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:@"customadv.bin"];
        [data writeToFile:filePathAndDirectory atomically:YES];

        [self parseAdvData:data];
        
    }
  
}



- (void)loadLocalAdv
{
    
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:@"customadv.bin"];
    
        NSData* data = [NSData dataWithContentsOfFile:filePathAndDirectory];
 
        [self parseAdvData:data];
    
     
    
}
-(void)parseAdvData:(NSData*)data
{

    if(data == nil){
        return;
    }
    
    NSError* error;
    
    NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
    
    BM4Log(@"%@",[lvObjUserInfo description]);
    
    NSString* lvResult = [lvObjUserInfo objectForKey:TAG_RESULT];
    
    if (lvResult != nil)
    {
        lvResult =
        [lvResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([lvResult isEqualToString:@"OK"]){
            
            NSObject* ob = [lvObjUserInfo objectForKey:@"adv_detail"];
            NSArray* array = nil;
            if([ob isKindOfClass:[NSArray class]]){
                array = (NSArray*)ob;
            }
            
            if (array != nil && array.count > 0){
                
                if(self.mContext.advArrayOffline != nil){
                    [self.mContext.advArrayOffline removeAllObjects];
                }else{
                    self.mContext.advArrayOffline = [[NSMutableArray alloc] init];
                }
                
                if(self.mContext.advArrayOnline != nil){
                    [self.mContext.advArrayOnline removeAllObjects];
                }else{
                    self.mContext.advArrayOnline = [[NSMutableArray alloc] init];
                }
                
                self.mContext.bc_interstitial_positions = [lvObjUserInfo objectForKey:@"bc_interstitial_positions"];
                
                for (NSDictionary* item in array) {
                    NSString * adv_type = [item objectForKey:@"adv_type"];
                     NSString * is_online = [item objectForKey:@"is_online"];
                    NSString * click_url = [item objectForKey:@"click_url"];
                    NSArray * image_frames = [item objectForKey:@"image_frames"];
                    NSString * image = [item objectForKey:@"image"];
                    NSString * name = [item objectForKey:@"name"];
                    NSString * target_id = [item objectForKey:@"target_id"];
                    AdvItem* adv = [[AdvItem alloc] init];
                    adv.status = 0;
                    adv.download_count = 0;
                    adv.adv_type = adv_type;
                    adv.click_url = click_url;
                    adv.image_frames = image_frames;
                    adv.image = image;
                    adv.name = name;
                    adv.target_id = target_id;
                    
                    if(is_online != nil && [is_online isEqualToString:@"1"]){
                        [self.mContext.advArrayOnline addObject:adv];
                    }else{
                        [self.mContext.advArrayOffline addObject:adv];
                    }
                }
                if(self.scheduleDownloadAdvImage != nil)
                {
                    [self.scheduleDownloadAdvImage invalidate];
                    self.scheduleDownloadAdvImage = nil;
                }
                self.scheduleDownloadAdvImage = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scanCustomAdvImageToDownload) userInfo:nil repeats:NO];
                
            }
            
            
        }
    }
    

}
-(void)scanCustomAdvImageToDownload
{
    if(self.mContext.advArrayOffline != nil && self.mContext.advArrayOffline.count > 0){
        for (int i = 0; i < self.mContext.advArrayOffline.count; i++) {
            AdvItem* item = [self.mContext.advArrayOffline objectAtIndex:i];
            if(item.status == 0 && item.download_count <4){
                
                //check if download image
                if([self need_download_url:item.image]){
                    [self downloadCustomAdvImage:item.image];
                    item.download_count++;
                    return;
                }
                
                //check if download image frame
                if(item.image_frames!= nil){
                    
                    for (NSString* str in item.image_frames) {
                        if([self need_download_url:str]){
                            [self downloadCustomAdvImage:str];
                            item.download_count++;
                            return;
                        }
                    }
                }
                BM4Log(@"download thanh cong: %@",item.name);
                item.status = 1;
            }
        }
    }
    
   
    if(self.mContext.advArrayOnline != nil && self.mContext.advArrayOnline.count > 0){
        for (int i = 0; i < self.mContext.advArrayOnline.count; i++) {
            AdvItem* item = [self.mContext.advArrayOnline objectAtIndex:i];
            if(item.status == 0 && item.download_count <4){
                
                //check if download image
                if([self need_download_url:item.image]){
                    [self downloadCustomAdvImage:item.image];
                    item.download_count++;
                    return;
                }
                
                //check if download image frame
                if(item.image_frames!= nil){
                    
                    for (NSString* str in item.image_frames) {
                        if([self need_download_url:str]){
                            [self downloadCustomAdvImage:str];
                            item.download_count++;
                            return;
                        }
                    }
                }
                BM4Log(@"download thanh cong: %@",item.name);
                item.status = 1;
            }
        }
    }
    
}

-(void) downloadCustomAdvImage :(NSString*)urlString
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError)
     {
         if (data!=nil){
             UIImage* img = [UIImage imageWithData:data];
             
             if(img != nil)
             {
                
                 NSString *docsDir;
                 NSArray *dirPaths;
                 
                 dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                 docsDir = [dirPaths objectAtIndex:0];
                 
                 NSString * filename = [self.mContext cachedFileNameForKey:urlString];
                 
                 NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
                 
                 [data writeToFile:databasePath atomically:YES];
                 BM4Log(@" download thanh cong:%@",urlString);
                // [databasePath release];
             }else{
             
             }
         }else{
             
         }
         
         
         if(self.scheduleDownloadAdvImage != nil)
         {
             [self.scheduleDownloadAdvImage invalidate];
             self.scheduleDownloadAdvImage = nil;
         }
         
         self.scheduleDownloadAdvImage = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scanCustomAdvImageToDownload) userInfo:nil repeats:NO];
         
         
     }];
    
}

-(BOOL)need_download_url:(NSString*)urlString
{
    if(urlString == nil || urlString.length < 10){
        return NO;
    }
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString * filename = [self.mContext cachedFileNameForKey:urlString];
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
    
    return !fileExists;
}
-(void)updateUILevel:(NSNotification*)nt
{
   self.mLevelLabel.text = [NSString stringWithFormat:@"%d", self.mContext.mLevel ];
}

@end
