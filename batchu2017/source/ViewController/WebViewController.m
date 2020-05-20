
#import "WebViewController.h"
#import "WPUtils.h"
#import "ExtendNSString.h"
#import "Reachability.h"
#import "ALToastView.h"
#import "HomeViewController.h"
#import "GamePlayViewController.h"
#import "AppDelegate.h"
#import "config.h"

@interface WebViewController ()
{
    bool needloadRuby;
}
@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showsync
{
    CustomContext* mContext = [CustomContext getInstance];
    needloadRuby = false;
    long seconds = time(0);
    
    NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [mContext MD5:lvBaseChecksum];
    
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:WEB_USER_SYNC_URL];
    
    [sDataUrl appendString: @"?game_id="];
    [sDataUrl appendString:GAME_ID];
    
    [sDataUrl appendString: @"&device_os=iOS"];
    
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    

    [sDataUrl appendString: @"&refid="];

    [sDataUrl appendString:mContext.mRefID];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    
    NSURL* url = [NSURL URLWithString:sDataUrl];
    
    UIView* bg1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, 300)];
    bg1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:bg1];
    
   
    
    UIView* bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-300, screenW, 300)];
    bg2.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:bg2];
    
    
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.frame.size.height)];
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.scrollEnabled = NO;
    
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    webview.delegate = self;
    
    
    [self.view addSubview:webview];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
  
    CustomContext* mContext = [CustomContext getInstance];
#ifdef BATCHU2
    if(!mContext.mIsSync && [mContext.mAllowSync isEqualToString:@"1"])
    {
        [self showsync];
        return;
    }
#endif
    needloadRuby = false;
    long seconds = time(0);
    
    NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [mContext MD5:lvBaseChecksum];
    
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:WEB_USER_INFO_URL];
    
    [sDataUrl appendString: @"?game_id="];
    [sDataUrl appendString:GAME_ID];
    
    [sDataUrl appendString: @"&user_id="];
    [sDataUrl appendString:self.mContext.mUserID];
    
    [sDataUrl appendString: @"&device_os=iOS"];
    
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    
#ifdef TINHVAN
    [sDataUrl appendString: @"&refcode="];
#else
     [sDataUrl appendString: @"&refid="];
#endif
    [sDataUrl appendString:mContext.mRefID];
    
    if([backViewcontroller isKindOfClass:HomeViewController.class])
    {
        [sDataUrl appendString: @"&has_adv2ruby=0"];
    }else{
        [sDataUrl appendString: @"&has_adv2ruby=1"];
    }
    [sDataUrl appendString: @"&ruby="];
    [sDataUrl appendString:[NSString stringWithFormat:@"%d",(int)mContext.mScore] ];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    
    NSURL* url = [NSURL URLWithString:sDataUrl];

    UIView* bg1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW ,300)];
    bg1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:bg1];
    
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, screenW, 44)];
    l.backgroundColor = [UIColor clearColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.text = self.mContext.mDeviceID;
    l.font = [UIFont systemFontOfSize:8];
    l.textColor = [UIColor lightTextColor];
    [self.view addSubview:l];
    
    UIView* bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-300, screenW ,300)];
    bg2.backgroundColor = [UIColor grayColor];
   
    [self.view addSubview:bg2];
    
    mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.frame.size.height)];
    mScrollView.scrollEnabled = YES;
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.frame.size.height)];
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.scrollEnabled = NO;
    
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    webview.delegate = self;
    [mScrollView addSubview:webview];
    
    UIButton*closebutton = [[UIButton alloc] initWithFrame:CGRectMake( screenW-60,0, 60, 60)];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    imgview.image = [UIImage imageNamed:@"close"];
    imgview.contentMode = UIViewContentModeCenter;
    [closebutton addSubview:imgview];
    [closebutton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [webview.scrollView addSubview:closebutton];
    [self.view addSubview:mScrollView];
    

    

}

-(void) setBackViewController:(UIViewController*)controller
{
    backViewcontroller = (BaseViewController*)controller;
}
-(void) close:(UIButton*)sender
{
    if(sender != nil)
        [sender setEnabled:NO];
    
    if(needloadRuby){
#ifdef APPLE
        [backViewcontroller reloadRuby];
#else
         [backViewcontroller delayReloadRuby];
#endif
        
    }else if ([backViewcontroller isKindOfClass:GamePlayViewController.class]){
        [((GamePlayViewController*)backViewcontroller) refreshRuby];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BM4Log(@"inside : %@ ",[request.URL absoluteString] );
    CustomContext* mContext = [CustomContext getInstance];
    
    
    /*
    if([[request.URL absoluteString] indexOf:@"close.php?login=OK"]>0){
        self.mContext.mIsSync = YES;
        NSString * absoluteStringurl =  [request.URL absoluteString];
        
        NSString* textsearch = @"user_id=";
        int searchlen = textsearch.length;
        int startindex = [absoluteStringurl indexOf:textsearch]+searchlen;
        int endindex = [absoluteStringurl indexOf:@"&" fromIndex:startindex];
        int user_id = [[absoluteStringurl substringWithRange:NSMakeRange(startindex, endindex-startindex)] intValue];
       
        if(user_id > 0){
            mContext.mUserID = [[NSString alloc] initWithFormat:@"%d",user_id ];
            textsearch = @"device_id=";
            searchlen = textsearch.length;
            startindex = [absoluteStringurl indexOf:textsearch]+searchlen;
            endindex = [absoluteStringurl indexOf:@"&" fromIndex:startindex];
            mContext.mDeviceID = [absoluteStringurl substringWithRange:NSMakeRange(startindex, endindex-startindex)];
            [mContext saveLocalData];
        }
        
        needloadRuby = true;
        [self close:nil];
        return NO;
    }
     */
    if([[request.URL absoluteString] indexOf:@"close.php?exit="]>0){
        [self close:nil];
        return NO;
    }
    /*
    if([[request.URL absoluteString] indexOf:@"close.php?inputsms="]>0){
        
        [self sendInAppSMS];
        needloadRuby = true;
        return NO;
    }
    if([[request.URL absoluteString] indexOf:@"close.php?action=adv2ruby&addition_ruby="]>0){
        
        NSString* textsearch = @"addition_ruby=";
        int searchlen = textsearch.length;
        NSString * absoluteStringurl =  [request.URL absoluteString];
        int startindex = [absoluteStringurl indexOf:textsearch]+searchlen;
        int test = [[absoluteStringurl substringWithRange:NSMakeRange(startindex, 1)] intValue];
        if(test >0 && test < 100 && test != mContext.mScoreAds)
        {
            mContext.mScoreAds = [absoluteStringurl substringWithRange:NSMakeRange(startindex, 1)];
        }
        BM4Log(@"%d",test);
    }
    if([[request.URL absoluteString] indexOf:@"close.php?action=adv2ruby"]>0){
        
        long current_time = time(0);
        
        //int one_day = 3;
        int one_day = 16*60*60;
        if ((mContext.time_start_count_ads + one_day) < current_time)
        {
            mContext.time_start_count_ads = current_time;
             mContext.count_advs_a_day = 1;
            [mContext saveLocalData];
        }else{
        
        }
        
        if( mContext.count_advs_a_day > [mContext.total_advs_a_day intValue])
        {
            NSString * msg = [NSString stringWithFormat:@"Đã quá số lượng quảng cáo %d/ngày!",[mContext.total_advs_a_day intValue]];
            [ALToastView toastInView:self.view withText:msg];
            return NO;
        }
        

        
        if ((current_time - mContext.time_ads) > [mContext.delay_adv_in_second intValue])
            {
            
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus == NotReachable) {
                BM4Log(@"There is NO internet connection");
                [ALToastView toastInView:self.view withText:@"Không có kết nối mạng!"];
                return NO;
            }else{
               
                mContext.count_advs_a_day += 1;
                [self showAds];
            }
            
            
        }else{
            NSString * msg = [NSString stringWithFormat:@"Xem quảng cáo cách nhau %d giây!",[mContext.delay_adv_in_second intValue]];
            [ALToastView toastInView:self.view withText:msg];
            
        }
        return NO;
        
    }
    
    if([[request.URL absoluteString] indexOf:@"card.php"]>0){
        needloadRuby = true;
    }
    */
    
    
    
    return YES;
}

- (void) showGoogleAdMobView {
    if(interstitial_ != nil)
    {
        interstitial_ = nil;
    }
#ifdef K_AdMobPublicID
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = K_AdMobPublicID;
    interstitial_.delegate = self;
    [interstitial_ loadRequest:[GADRequest request]];
#endif
    
}

#ifdef K_AdMobPublicID
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self updateRubyAfterShowAds];
    [interstitial_ presentFromRootViewController:self];
}

#endif

-(void)updateRubyAfterShowAds
{
    
    /*
    NetworkManager* net = [NetworkManager sharedInstance];
    [net updateRubyViewAdd];
    net.delegate = nil;
    */
    
    [self.mContext updateRubyViewAdd];
    
    long current_time = time(0);
    self.mContext.time_ads = current_time;
    
    self.mContext.countShowAsd = self.mContext.countShowAsd + 1;
    self.mContext.mScore = self.mContext.mScore + [self.mContext.mScoreAds intValue];
    [self.mContext saveLocalData];
    
}


/*

- (void)sendInAppSMS
{
    [[AppDelegate getInstance] setSuspend:YES];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
#ifdef CLEVERADS
        self.mContext.mRefID = nil;
#endif
        controller.recipients = [NSArray arrayWithObjects:self.mContext.mSmsNumber, nil];
        if(self.mContext.mRefID != nil && ![self.mContext.mRefID isEqualToString:@""]){
            controller.body = [NSString stringWithFormat:@"%@%@ %@",self.mContext.sms_syntax,self.mContext.mUserID,self.mContext.mRefID];
        }else{
            controller.body = [NSString stringWithFormat:@"%@%@",self.mContext.sms_syntax,self.mContext.mUserID];
        }
        
        
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
        
        
    }
}
 

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            BM4Log(@"Cancelled");
            break;
        case MessageComposeResultFailed:
        {
            UIAlertView* alert ;//= [[[UIAlertView alloc] initWithTitle:@"MyApp" message:@"Unknown Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            alert = [[UIAlertView alloc] initWithTitle:@"Bat chu" message:@"không gửi được" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    mScrollView.contentSize =   webview.scrollView.contentSize;
    webview.frame = CGRectMake(0, 0, webview.scrollView.contentSize.width, webview.scrollView.contentSize.height);
    
}



- (void) showAds
{
    [self showGoogleAdMobView];
     self.mContext.countShowAsd = self.mContext.countShowAsd + 1;
    
    
}







@end
