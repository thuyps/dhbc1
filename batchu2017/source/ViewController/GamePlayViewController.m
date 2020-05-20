//
//  GamePlayViewController.m
//  batchu
//
//  Created by Pham Quang Dung on 9/25/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVMetadataItem.h>

#import "HomeViewController.h"
#import "GamePlayViewController.h"
#import "config.h"
#import "WPUtils.h"

#import "AlphabetButton.h"
#import "WinViewController.h"
#import "ALToastView.h"
#import "AppDelegate.h"

#import "UIView+Animation.h"


#import "CustomAdvBannerOffline.h"

@interface GamePlayViewController ()

@end

@implementation GamePlayViewController

-(void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reCreateUI) name:@"GAME_RE_CREATE_UI" object:nil];
    
    
    
    
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
	  
    self.opencharTimer = nil;
    self.opencharButton = nil;
 
#ifdef DEBUG
   // self.mContext.show_banner_in_game = 1;
#endif
   
}


-(void)addOfflineBanner : (CGFloat) posY
{
    if(self.mContext.gameOfflineBanner == nil){
        self.mContext.gameOfflineBanner = [[CustomAdvBannerOffline alloc] initWithFrame:CGRectMake(0, posY, screenW, 50)] ;
    }
    
    [self.mContext.gameOfflineBanner setAdvItem:[self.mContext getOfflineBanner]];
    
    [self.mContext.gameOfflineBanner removeFromSuperview];
    self.mContext.gameOfflineBanner.frame = CGRectMake(0, posY, screenW, 50);
    [self.view addSubview:self.mContext.gameOfflineBanner];
}


-(void)addOficialBanner : (CGFloat) posY
{
    if(self.mContext.gameBannerView == nil){
        self.mContext.gameBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner] ;
        
        self.mContext.gameBannerView.adUnitID = INGAME_ADV_BANNER;
        self.mContext.gameBannerView.rootViewController = self;
        
        self.mContext.gameBannerView.frame = CGRectMake((screenW-self.mContext.gameBannerView.frame.size.width)/2, posY, self.mContext.gameBannerView.frame.size.width, self.mContext.gameBannerView.frame.size.height);
        
        GADRequest *request = [GADRequest request];
#ifdef DEBUG
        request.testDevices = @[ kGADSimulatorID ];
#endif
        [self.mContext.gameBannerView loadRequest:request];
        
     
    }
    
    [self.view addSubview:self.mContext.gameBannerView];
    
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view;
{

}

-(UIView*)addTopBar
{
   UIImageView*  play_topbar = [WPUtils createViewFromImage:@"play_topbar" Scale:screenW/320];
    
    UIView* container = [[UIView alloc] initWithFrame:play_topbar.frame];
    
    [WPUtils addView:play_topbar withPoint:CGPointMake(0, 0) withAlignment:CustomAlignTopLeft toView:container];

    
    
    UIFont* font = [UIFont fontWithName:kLevelFont size:kLevelFontSize*screenH/568];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    ;
    
    titleLabel.textColor = [WPUtils colorFromString:@"0000fe"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = font;
    titleLabel.text = [NSString stringWithFormat:@"%d", self.mContext.mLevel];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
    titleLabel.layer.shadowOffset = CGSizeMake(3, 3);
    titleLabel.layer.shadowRadius = 1.0;
    titleLabel.layer.shadowOpacity = 0.65;
    [titleLabel sizeToFit];
    
    [WPUtils addView:titleLabel withPoint:CGPointMake(141.0*screenW/320.0, 28*screenW/320) withAlignment:CustomAlignMidleCenter toView:container];
    
    
    UIFont* fontScore = [UIFont fontWithName: kScoreFont size:kScoreFontSize];
    
    UILabel* scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 40, 0)];
    scoreLabel.textColor = [WPUtils colorFromString:@"431900"];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.font = fontScore;
    NSString* scoreText = [NSString stringWithFormat:@"%ld", self.mContext.mScore];
    scoreLabel.backgroundColor = [UIColor clearColor];
    
    scoreLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    scoreLabel.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    scoreLabel.layer.shadowRadius = 1.0;
    scoreLabel.layer.shadowOpacity = 0.65;
    self.mScoreLabel = scoreLabel;
    
    
    if(scoreText.length < 5){
        scoreLabel.text = @"44444";
    }else{
        scoreLabel.text = scoreText;
    }
    
    [scoreLabel sizeToFit];
    scoreLabel.text = scoreText;
    
    [WPUtils addView:scoreLabel withPoint:CGPointMake(270.0*screenW/320.0, 28*screenW/320) withAlignment:CustomAlignMidleCenter toView:container];

    
    if(self.mContext.mUserID != nil && ![self.mContext.mUserID isEqualToString:@""] ){
        UIButton* userinfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [userinfoButton addTarget:self action:@selector(userinfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [userinfoButton setExclusiveTouch:YES];
        [WPUtils addView:userinfoButton withPoint:CGPointMake(270.0*screenW/320.0, CGRectGetHeight(container.frame)/2) withAlignment:CustomAlignMidleCenter toView:container];
    }
    
    
    UIButton *backButton = [WPUtils createButtonFromImage:@"back.png" Text:nil Scale:screenW/320.0];
    
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [WPUtils addView:backButton withPoint:CGPointMake(0, 0) withAlignment:CustomAlignTopLeft toView:container];
    
    
    UIButton *opencharButton = [WPUtils createButtonFromImage:@"openchar" Text:nil Scale:screenW/320.0] ;
    [opencharButton addTarget:self action:@selector(opencharButtonAction) forControlEvents:UIControlEventTouchUpInside];
   self.opencharButton =  opencharButton;
   
    [WPUtils addView:opencharButton withPoint:CGPointMake(CGRectGetMaxY(backButton.frame)+CGRectGetWidth(opencharButton.frame)/2, 26*screenW/320) withAlignment:CustomAlignMidleCenter toView:container];
    
    
    self.opencharTimer = [NSTimer scheduledTimerWithTimeInterval:70 target:opencharButton selector:@selector(rotateShakeView) userInfo:nil repeats:YES];
    
    
   
    UIButton *facebookButton = [WPUtils createButtonFromImage:@"facebook" Text:nil Scale:screenW/320.0] ;
    [facebookButton addTarget:self action:@selector(facebookButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [WPUtils addView:facebookButton withPoint:CGPointMake(211*screenW/320, 27*screenW/320) withAlignment:CustomAlignMidleCenter toView:container];
    
    
    [self.view addSubview:container];
    return container;
}

-(void)opencharButtonShake
{
    [self.opencharButton rotateShakeView];
}

-(void) reCreateUIForNextLevel:(NSNotification*)nt
{
    for (UIView* v in self.view.subviews) {
        [v removeFromSuperview];
    }
    [self reCreateUI];
}
-(void) reCreateUI
{
    [self addBackGroundScaleFill:@"bg"];
    
    UIView *topbar = [self addTopBar];
    
    UIImageView* mainImageView = nil;
    
    if(IDIOM == IPAD){
        
        mainImageView = [WPUtils createViewFromImage:@"imgtest" Scale:screenH/568];

    }else{
        mainImageView = [WPUtils createViewFromImage:@"imgtest" Scale:screenW/320];
    
    }
    
    [WPUtils addView:mainImageView withPoint:CGPointMake(screenW/2, CGRectGetMaxY(topbar.frame)+8*SCALE) withAlignment:CustomAlignTopCenter toView:self.view];
    
    mainImageView.image = self.mContext.mImage;
    
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    BOOL networkCheck =  [app checkCurrentConnection];
    
    BOOL offlineAdvExist =  [self.mContext checkOfflineBannerExists];
    
    CGFloat posAdvY = CGRectGetMaxY(mainImageView.frame) +15*SCALE;
  

    
    if ( IDIOM == IPAD ) {
         posAdvY = CGRectGetMaxY(mainImageView.frame) +5*SCALE;
    } else {
        /* do something specifically for iPhone or iPod touch. */
    }
    
    
    
    BOOL advExists = NO;
    if ((self.mContext.mAnswerStringBodau.length <=8) || (screenH > 490))
    {
        if (self.mContext.show_banner_in_game == 1 && networkCheck){
            [self addOficialBanner:posAdvY];
            advExists = YES;
        }else if (self.mContext.show_banner_in_game == 1 && !networkCheck && offlineAdvExist){
            [self addOfflineBanner:posAdvY];
            advExists = YES;
        }
    }
    
    
    self.mAnswerButtons = [[NSMutableArray alloc] init];
    
    self.mOfferButtons = [[NSMutableArray alloc] init];
   
    
    CGFloat posY ;
    if(advExists)
    {
        posY = CGRectGetMaxY(mainImageView.frame) + 30*SCALE + 50;
    }else{
        posY = CGRectGetMaxY(mainImageView.frame) + 15*SCALE ;
    }
    
    /*
    if(self.mContext.mAnswerStringBodau.length<9){
        posY = 332;
    }
    
    if(!advExists){
        posY = 280;
        if(self.mContext.mAnswerStringBodau.length<9){
            posY = 300;
        }
    }
    
    
    posY = posY*screenH/568;*/
    /*
    if(posY < (CGRectGetMaxY(mainImageView.frame) + 8*SCALE)){
        posY = CGRectGetMaxY(mainImageView.frame) + 8*SCALE;
    }*/
    
    UIButton* bt;
    
    for (int i = 0; i<self.mContext.mAnswerStringBodau.length; i++) {
        bt = [[AlphabetButton alloc] createAnswerAtIndex:i withPosY:posY];
        [bt addTarget:self action:@selector(answerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bt];
        [self.mAnswerButtons addObject:bt];
    }

    
    
    
    for (int i = 0; i<self.mContext.mSuggestionArray.count; i++) {
  
        
        AlphabetButton* bt;

        bt = [[AlphabetButton alloc] createOfferAtIndex:i withPosY:390*MODIFY_POS];
   
        
        
        bt.alphabet= [self.mContext.mSuggestionArray objectAtIndex:i];
        bt.alphabetLb.text = [self.mContext.mSuggestionArray objectAtIndex:i];
        [bt addTarget:self action:@selector(offerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bt];
        [self.mOfferButtons addObject:bt];
    }
    
    
    if(self.mContext.mOpenCharCounts != nil)
    {
        for (int j1=0; j1<self.mContext.mOpenCharCounts.count; j1++)
        {
            int index = [[self.mContext.mOpenCharCounts objectAtIndex:j1] intValue];
            AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:index];
            
            answerbutton.alphabet = [self.mContext.mAnswerStringBodau substringWithRange:NSMakeRange(index, 1)];
            answerbutton.alphabetLb.text = answerbutton.alphabet;
            answerbutton.alphabetLb.textColor = [WPUtils colorFromString:OPEN_COLOR];
            answerbutton.state = kDidOpen;
            
            
            for (int j=0; j<self.mOfferButtons.count; j++)
            {
                AlphabetButton* offerbutton = [self.mOfferButtons objectAtIndex:j];
                if([offerbutton.alphabet isEqualToString:answerbutton.alphabet])
                {
                    [offerbutton removeFromSuperview];
                    break;
                }
            }
            
            
            
        }
        
        
    }
    
 
    

     self.mContext.levelCount ++;
    


    
    
}

- (void) zoomAnimationKeyBoard {
    float timeTotal = 1;
    float step = timeTotal/(self.mOfferButtons.count/2);
    float startTime = 0;
    for (int i= 0; i<7; i++) {
        AlphabetButton * aBtn = [self.mOfferButtons objectAtIndex:i];
        [UIView animateWithDuration:step/6 delay:startTime options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionRepeat animations:^{
            [UIView setAnimationRepeatCount:2.0];
            aBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:step/3 animations:^{
                aBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            } completion:nil];
        }];
        startTime = step +startTime;
    }
    
    startTime = 0;
    for (int i= 7; i<14; i++) {
        AlphabetButton * aBtn = [self.mOfferButtons objectAtIndex:i];
        [UIView animateWithDuration:step/3 delay:startTime options:UIViewAnimationCurveEaseInOut animations:^{
            aBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:step*2/3 animations:^{
                aBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            } completion:nil];
        }];
        startTime = step +startTime;
    }
}

-(void)backButtonAction
{
    [self.mContext playEffect:kSoundDing];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_HOME_LEVEL" object:self];
    

    
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.mContext.gameBannerView removeFromSuperview];
    }];

    
}





-(void) offerButtonAction:(AlphabetButton*)bt
{
    if(self.mState == GameStateOpenningChar){
        return;
    }
    
    [self.mContext playEffect:kSoundDing];
    
    for (int i=0; i<self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if([answerbutton.alphabet isEqualToString:@""])
        {
            [((AlphabetButton*) bt.superview) removeFromSuperview];
            answerbutton.alphabet =((AlphabetButton*) bt.superview).alphabet;
            answerbutton.alphabetLb.text = ((AlphabetButton*) bt.superview).alphabet;
            answerbutton.ref = ((AlphabetButton*) bt.superview);
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkAnswer) userInfo:nil repeats:NO];
            break;
        }
    }
}



-(void)checkAnswer
{
    for (int i=0; i<self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if([answerbutton.alphabet isEqualToString:@""])
        {
            return;
        }
    }
    
    
    NSMutableString* temp = [[NSMutableString alloc] initWithString:@""];
    
    for (int i=0; i<self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        [temp appendString:answerbutton.alphabet];
    }
    
    if([temp isEqualToString:self.mContext.mAnswerStringBodau])
    {
        if(self.mContext.mSoundEnable == 1)
        {
            [self.mContext playEffect:kSoundPass];
        }
        
        
        for (AlphabetButton *aBtn in self.mAnswerButtons) {
            CGAffineTransform translateRight  = CGAffineTransformMakeRotation(0.2);
            CGAffineTransform translateLeft = CGAffineTransformMakeRotation(-0.2);
            aBtn.transform = translateLeft;
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
                [UIView setAnimationRepeatCount:3.0];
                aBtn.transform = translateRight;
            } completion:^(BOOL finished) {
                if (finished) {
                    aBtn.transform = CGAffineTransformIdentity;
                }
            }];
        }
        
        float t = 1.880817;
        [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(winAction) userInfo:nil repeats:NO];
        
        
    }else{
        
       if(self.mContext.mSoundEnable == 1)
       {
        
        [self.mContext playEffect:kSoundFail];
       }
        
       
        
        
        for (AlphabetButton *aBtn in self.mAnswerButtons) {
            CGAffineTransform translateRight  = CGAffineTransformMakeRotation(0.2);
            CGAffineTransform translateLeft = CGAffineTransformMakeRotation(-0.2);
            
            //UILabel *label  = [aBtn getAlphabetTitleLabel];
            UILabel *label  = aBtn.alphabetLb;
            
            UILabel *tempLabel = [[UILabel alloc] init];
            tempLabel.backgroundColor  = [UIColor clearColor];
            tempLabel.textColor = [UIColor redColor];
            tempLabel.font = label.font;
            tempLabel.alpha = 0;
            tempLabel.textAlignment = label.textAlignment;
            tempLabel.text = label.text;
            [label.superview addSubview:tempLabel];
            tempLabel.frame = label.frame;
            
            
            aBtn.transform = translateLeft;
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
                [UIView setAnimationRepeatCount:3.0];
                aBtn.transform = translateRight;
                label.alpha = 0;
                tempLabel.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    label.alpha = 1;
                    [tempLabel removeFromSuperview];
                    aBtn.transform = CGAffineTransformIdentity;
                }
            }];
        }
        
        float t = 1.16244996;
        
        [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(wrongAction) userInfo:nil repeats:NO];
   
        
    }
}
-(void)wrongAction
{
   [ALToastView toastInView:self.view withText:@"Câu trả lời của bạn chưa đúng!"];
}

-(void)winAction
{
    
    [self.mContext playEffect:kSoundWin];
    
    if(win!=nil)
    {
        win = nil;
    }
    
    self.mContext.win = win;
    win = [[WinViewController alloc] init];

   
    [self presentViewController:win animated:NO completion:^{
        [self.mContext.gameBannerView removeFromSuperview];
    }];
    
    
}



-(void) answerButtonAction:(AlphabetButton*)bt1
{
    AlphabetButton* bt = ((AlphabetButton*) bt1.superview);
   [self.mContext playEffect:kSoundDing];
    
    if(bt.state == kDidOpen)
    {
        return;
    }
    if(![bt.alphabet isEqualToString:@""])
    {
        
        [self.view addSubview:bt.ref];
        bt.ref = nil;
        
        bt.alphabet = @"";
        bt.alphabetLb.text = @"";
        
    }
    
    if (self.mState == GameStateOpenningChar) {
        
        self.mContext.registerOpenchar = bt.mIndex;
        
       [self openCharAtIndex:bt.mIndex];
        
        [self.mContext openchar];
        
    
        
        return;
    }
    
}







-(void)opencharButtonAction
{

    if (self.mContext.mScore >= 20) {
        
        [self.mContext playEffect:kSoundDing];
   
    
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:self];
        [dialog setTitle:@"Mở ô đáp án"];
    
        [dialog setMessage:@"Mở một ô chữ trong đáp án, bạn sẽ bị trừ 20 Ruby. Bạn có chắc chắn mở không?"];
        [dialog addButtonWithTitle:@"Đồng ý"];
        [dialog addButtonWithTitle:@"Bỏ qua"];
        [dialog show];
    }else{
        
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:nil];
        [dialog setTitle:@"Thông báo"];
        [dialog setMessage:@"Không đủ Ruby! Bạn hãy nạp Ruby để tiếp tục."];
        [dialog addButtonWithTitle:@"Đóng"];
        [dialog show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BM4Log(@"%d",(int)buttonIndex);
    if(buttonIndex==0){
        [self startOpenningChar];
    }
}


/*
-(void)opencharContinue1
{

    for (int i=0; i<self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen)
        {
            if(![answerbutton.alphabet isEqualToString:@""])
            {
                
                [self.view addSubview:answerbutton.ref];
                answerbutton.ref = nil;
                
                answerbutton.alphabet = @"";
                answerbutton.alphabetLb.text = @"";
                
            }
            
        }
    }
    
    for (int i=0; i<self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if([answerbutton.alphabet isEqualToString:@""])
        {
            
            answerbutton.alphabet = [self.mContext.mAnswerStringBodau substringWithRange:NSMakeRange(i, 1)];
            answerbutton.alphabetLb.text = answerbutton.alphabet;
            answerbutton.alphabetLb.textColor = [WPUtils colorFromString:OPEN_COLOR];
            answerbutton.state = kDidOpen;
            [self.mContext setScore:(self.mContext.mScore-20)];
            
           // self.mContext.mOpenCharCount++;
            
            self.mScoreLabel.text = [NSString stringWithFormat:@"%d",self.mContext.mScore];
            
            for (int j=0; j<self.mOfferButtons.count; j++)
            {
                AlphabetButton* offerbutton = [self.mOfferButtons objectAtIndex:j];
                if([offerbutton.alphabet isEqualToString:answerbutton.alphabet])
                {
                    [offerbutton removeFromSuperview];
                    break;
                }
            }
            
            [self.mContext saveLocalData];
            NetworkManager* net = [NetworkManager sharedInstance];
            [net openchar];
            net.delegate = nil;
            
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkAnswer) userInfo:nil repeats:NO];
            break;
        }
    }
 
}*/


-(void)startOpenningChar
{
    
    
    self.mContext.registerOpenchar = -1;
    
    if([self countNotOpen] <=1)
    {
      /*  NetworkManager* net = [NetworkManager sharedInstance];
        [net openchar];
        net.delegate = nil;
        */
        [self.mContext openchar];
        
        int index = [self searchFirstNotOpenChar];
        self.mContext.registerOpenchar = index;
        [self openCharAtIndex:index];
        return;
    }
    
    self.mState = GameStateOpenningChar;
    
    [ALToastView toastInView:self.view withText:@"Chọn 1 ô chữ để mở!"];
    
    startBlinkTime = time(0);
    lastBlink = (int)self.mAnswerButtons.count - 1;
    AlphabetButton* answerbutton;
    
    
    for (int i = lastBlink; i >=0; i--) {
        answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen){
            lastBlink = i;
            break;
        }
    }
    
    if(answerbutton.state != kDidOpen){
        [self blinkAnswer];
    }
}



-(void)facebookButtonAction
{
    
    [self.mContext playEffect:kSoundDing];
   
    [[AppDelegate getInstance] setSuspend:YES];
    
    [[AppDelegate getInstance].tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"button"     // Event category (required)
                                                                                    action:@"sharefacebook"  // Event action (required)
                                                                                     label:nil        // Event label
                                                                                     value:nil] build]];
    
    
    NSMutableString* text =[[NSMutableString alloc] initWithString:@"(BẮT CHỮ) ĐÂY LÀ GÌ?\n Chuỗi gợi ý:\n"];
    
    for (int i=0; i< self.mContext.mSuggestionArray.count; i++) {
        [text appendFormat:@"%@ ",[self.mContext.mSuggestionArray objectAtIndex:i] ];
    }
    
    [text appendString:@"\n"];
    
    
    [WPUtils shareText:@"Bắt Chữ - WePlay" andImage:self.mContext.mImage andUrl:nil fromController:self];//[WPUtils imageWithView:self.view]
    
    /*
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    if (appDelegate.session.isOpen) {
        
        [appDelegate.session closeAndClearTokenInformation];
        
    }
    
    if (!appDelegate.session.isOpen) {
        
        appDelegate.session = [[FBSession alloc] initWithPermissions:@[@"public_profile"]];
        
        
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            
            
            if (appDelegate.session.isOpen) {
                 [self postFacebook];
            }
        }];
        
    }else{
    
        [self postFacebook];
    }
    
    */
    
     [ self requestPermissionForImage];
    
}



- (void)requestPermissionForImage
{
  /* dungpq remove tam
    [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions",nil]
                                       defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES
                                     completionHandler:^(FBSession *session,FBSessionState s, NSError *error) {
                                         if (!error) {
                                             // Now have the permission
                                             [self processPostingImage];
                                         } else {
                                             // Facebook SDK * error handling *
                                             // if the operation is not user cancelled
                                            
                                             
                                             [self postFacebook];
                                             
                                         }
                                     }];*/
}

- (void)processPostingImage
{
  /*dungpq remove tam  UIImage * img = self.mContext.mImage;
    
    
    NSMutableString* text =[[NSMutableString alloc] initWithString:@"(BẮT CHỮ) ĐÂY LÀ GÌ?\n Chuỗi gợi ý:\n"];
    
    for (int i=0; i< self.mContext.mSuggestionArray.count; i++) {
        [text appendFormat:@"%@ ",[self.mContext.mSuggestionArray objectAtIndex:i] ];
    }
    
    [text appendString:@"\n"];
    
    NSString *messag = text;
    
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection forFbID:@"me" result:result error:error];
    };
   
    FBRequest *request=[[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/photos" parameters:[NSDictionary dictionaryWithObjectsAndKeys:UIImageJPEGRepresentation(img, 0.7),@"source",messag,@"message",@"{'value':'EVERYONE'}",@"privacy", nil] HTTPMethod:@"POST"];
    
    
    [newConnection addRequest:request completionHandler:handler];
    [self.requestConnection cancel];
    self.requestConnection = newConnection;
    [newConnection start];*/
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
/*- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:fbID
                  result:(id)result
                   error:(NSError *)error
{
    NSLog(@"request completed");
    [WPUtils alert:@"Gửi thành công"];
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection)
    {
        NSLog(@"Request Sent But not compleated Yet");
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    if (error)
    {
        NSLog(@"    error");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        // error contains details about why the request failed
        [alert show];
    }
    else
    {
        NSLog(@"   ok");
        NSLog(@"%@",result);
        //[self doCheckIn];
        
    };
}
- (void) presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When fberrorShouldNotifyUser is YES, a fberrorUserMessage can be
    // presented as a user-ready message
    if (error.fberrorShouldNotifyUser) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected error:%@", error);
    }
}


-(void)postFacebook
{

    NSMutableString* text =[[NSMutableString alloc] initWithString:@"(BẮT CHỮ) ĐÂY LÀ GÌ?\n Chuỗi gợi ý:\n"];
    
    for (int i=0; i< self.mContext.mSuggestionArray.count; i++) {
        [text appendFormat:@"%@ ",[self.mContext.mSuggestionArray objectAtIndex:i] ];
    }
    
    [text appendString:@"\n"];

    BOOL check = NO;
    if ([FBSession activeSession] != nil ) {
        
        check = [FBDialogs canPresentOSIntegratedShareDialogWithSession:[FBSession activeSession]];
        
        if(check)
        {
            [FBDialogs presentOSIntegratedShareDialogModallyFrom:self session:[FBSession activeSession] initialText:text images: @[self.mContext.mImage] urls:nil handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                if (error) {
                    BM4Log(@"Error: %@", error.description);
                } else {
                    BM4Log(@"Success!");
                }
            }];
            
            
        }else{
            
            check = [FBDialogs canPresentShareDialogWithPhotos];
            FBPhotoParams *params = [[FBPhotoParams alloc] init];
            params.photos = @[self.mContext.mImage];
            
            if(check){
                //FBAppCall *appCall =
                [FBDialogs presentShareDialogWithPhotoParams:params
                                                 clientState:nil
                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                         if (error) {
                                                             NSLog(@"Error: %@", error.description);
                                                         } else {
                                                             NSLog(@"Success!");
                                                         }
                                                     }];
                
                //   check = (appCall  != nil);
            }
            
            
        }
        
    }
    
    if(!check){
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:nil];
        [dialog setTitle:@"Thông tin"];
        [dialog setMessage:@"Bạn hãy cài đặt ứng dụng Facebook để dùng được chức năng này."];
        // [dialog setMessage:@"Chưa cài đặt thông số cho facebook"];
        [dialog addButtonWithTitle:@"Đóng"];
        
        
        [dialog show];
    }

}
*/


/*
- (void)adViewDidReceiveAd:(GADBannerView *)view {
   [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         view.frame = CGRectMake(0,0, kScreenWidth ,kScreenHeight);
                     }
                     completion:nil];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(bannerView_.frame.size.width - 35, 0, 35, 35);
    [btn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeAdMobView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
}

- (void) closeAdMobView:(id)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         bannerView_.frame = CGRectMake(0,kScreenHeight, kScreenWidth ,kScreenHeight);
                     }
                     completion:^(BOOL finished){
                         //if (adMobCount == 3)
                         {
                             [bannerView_ removeFromSuperview];
                         }
                     }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
 
}
*/


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


-(void)refreshRuby
{
    self.mScoreLabel.text =  [NSString stringWithFormat:@"%d",self.mContext.mScore];
    
}

-(void)delayReloadRuby
{
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.labelText = @"Cập nhật tài khoản...";
    //self.HUD.detailsLabelText = @"Loading level data...";
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(reloadRuby) userInfo:nil repeats:NO];
    
}

-(void)reloadRuby
{
    
    NSMutableURLRequest* request = [self.mContext createGetUserDataRequest];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self receivedReloadData:data];
                               
                           }];
    
}

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
            [self.mContext saveLocalData];
            self.mScoreLabel.text =  [NSString stringWithFormat:@"%d",self.mContext.mScore];
        }
    }
    
    
}






int lastBlink = 0;
long startBlinkTime = 0;
long timeoutBlink = 30;

-(void)clearLastBlink
{
    UIButton* bt = [self.mAnswerButtons objectAtIndex:lastBlink];
    bt.layer.borderWidth = 0;
    bt.layer.cornerRadius = 0;
    bt.layer.masksToBounds = YES;
    bt.layer.borderColor = [UIColor clearColor].CGColor;
    
    
}


-(int) countNotOpen
{
    int count = 0;
    for (int i = 0; i < self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen){
            count++;
            
        }
    }
    return count;
}

-(int) searchFirstNotOpenChar
{
    for (int i = 0; i < self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen){
            return i;
        }
    }
    return -1;
}

-(int) searchNexttNotOpenChar:(int)start
{
    for (int i = start; i < self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen){
            return i;
        }
    }
    
    for (int i = 0; i < self.mAnswerButtons.count; i++) {
        AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:i];
        if(answerbutton.state != kDidOpen){
            return i;
        }
    }
    
    return -1;
}


-(void) blinkAnswer
{
    [self clearLastBlink];
    
    if(self.mState != GameStateOpenningChar){
        
        return;
    }
    

    UIButton* bt;
    long currentTime = time(0);
    
    if ( (currentTime - startBlinkTime) > timeoutBlink ) {
        
        self.mContext.registerOpenchar = lastBlink;
        
        [self openCharAtIndex:lastBlink];

        
        return;
    }
    
    
    
    if(lastBlink == (self.mAnswerButtons.count - 1)){
        lastBlink = 0;
    }else{
        lastBlink = lastBlink + 1;
    }
    
    lastBlink = [self searchNexttNotOpenChar:lastBlink];
    
    if(lastBlink >= 0 && lastBlink < self.mAnswerButtons.count){
        bt = [self.mAnswerButtons objectAtIndex:lastBlink];
        
        bt.layer.borderWidth = 2;
        bt.layer.cornerRadius = 2;
        bt.layer.masksToBounds = YES;
        
        bt.layer.borderColor = [UIColor yellowColor].CGColor;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(blinkAnswer) userInfo:nil repeats:NO];
    }else{
        BM4Log(@"sai index:%d",lastBlink);
        self.mState = GameStatePlaying;
    }
    
    
}

-(BOOL)offerSelected:(AlphabetButton*)bt
{
    for (int j=0; j<self.mAnswerButtons.count; j++)
    {
        AlphabetButton* anserButton = [self.mAnswerButtons objectAtIndex:j];
        if(anserButton.ref == bt){
            return YES;
            break;
        }
    }
    return NO;
}


-(void) openCharAtIndex:(int)index
{
    self.mState = GameStatePlaying;
    self.mContext.mScore -= 20;
    
    self.mScoreLabel.text = [NSString stringWithFormat:@"%d",(int)self.mContext.mScore];
    
    if(self.mContext.mOpenCharCounts == nil){
        self.mContext.mOpenCharCounts = [[NSMutableArray alloc] init];
    }
    
    [self.mContext.mOpenCharCounts addObject:[NSString stringWithFormat:@"%d",index]];
    
    
    NSString *alphabet = [self.mContext.mAnswerStringBodau substringWithRange:NSMakeRange(index, 1)];
    
    //find alphabet and remove from offer
    BOOL found = NO;
    for (int j=0; j<self.mOfferButtons.count; j++)
    {
        AlphabetButton* offerbutton = [self.mOfferButtons objectAtIndex:j];
        if([offerbutton.alphabet isEqualToString:alphabet] && ![self offerSelected:offerbutton])
        {
            [offerbutton removeFromSuperview];
            found = YES;
            break;
        }
    }
    
    if(!found){
        
        for (int j=((int)self.mAnswerButtons.count-1); j>=0; j--)
        {
            AlphabetButton* bt = [self.mAnswerButtons objectAtIndex:j];
            if([bt.alphabet isEqualToString:alphabet] && bt.state != kDidOpen)
            {
                
                bt.ref = nil;
                bt.alphabet = @"";
                bt.alphabetLb.text = @"";
                break;
                
            }
        }
        
    }
    
    
    
    
    
    AlphabetButton* answerbutton = [self.mAnswerButtons objectAtIndex:index];
        
    answerbutton.alphabet = [self.mContext.mAnswerStringBodau substringWithRange:NSMakeRange(index, 1)];
    answerbutton.alphabetLb.text = answerbutton.alphabet;
    answerbutton.alphabetLb.textColor = [WPUtils colorFromString:OPEN_COLOR];
    answerbutton.state = kDidOpen;
    
    for (int j=0; j<self.mOfferButtons.count; j++)
    {
        AlphabetButton* offerbutton = [self.mOfferButtons objectAtIndex:j];
        if([offerbutton.alphabet isEqualToString:answerbutton.alphabet])
        {
            [offerbutton removeFromSuperview];
            break;
        }
    }
    
    [self.mContext saveLocalData];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkAnswer) userInfo:nil repeats:NO];
    
    
    
    
}

@end
