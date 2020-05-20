//
//  Context.h
//  FastTaxi
//
//  Created by Thuy Pham on 8/10/13.
//  Copyright (c) 2013 Bình Anh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class HomeViewController,GamePlayViewController,WinViewController,AudioController,GADBannerView,AdvItem,CustomAdvBannerOffline;
@interface CustomContext : NSObject

{
     NSString* currentUrl;
}
@property () BOOL isLevelDownloading;
@property () NSInteger levelDownloading;
@property () NSInteger levelCount;
@property () NSInteger mSoundEnable;
@property () NSInteger mScore;
@property () int lastofflineBanner;

@property (strong) NSMutableArray* mOpenCharCounts;

@property () int mLevel;
@property () int mWinTextIndex;
@property () int mWinColorIndex;
@property () int mImgType;
@property (strong)  NSString* mRandKey;
@property (strong)  NSString* mAnswerString;
@property (strong)  NSString* mAnswerStringBodau;
@property (strong)  NSArray* mSuggestionArray;
@property (strong)  UIImage* mImage;
@property (strong)  NSArray* mWinColors;
@property (strong)  NSArray* mWinTexts;
@property (strong)  AudioController* audioController;

@property (strong)  NSMutableArray* mRandomLevel;
//@property (weak)  HomeViewController* home;
//@property (weak)  GamePlayViewController* play;
@property (weak)  WinViewController* win;


@property (strong)  NSString* mUserID;
@property ()  NSInteger mTotalLevels;
@property (strong)  NSString* mSessionID;
@property (strong)  NSString* mDeviceID;
@property (strong) NSString* mAdmodID;
@property (strong) NSString* mSmsNumber;
@property (strong) NSString*  mScoreAds;
@property (strong) NSString*  delay_adv_in_second;
@property (strong) NSString*  total_advs_a_day;
@property (strong) NSString*  sms_syntax;
@property (strong) NSString*  mRefID;
@property (strong) NSString*  mAllowSync;
@property (strong) NSString*  push_message;

@property ()  BOOL mIsSyncNative;

@property ()  BOOL mIsSync;
//@property () BOOL startAppOption;
@property () long  time_push;
@property () long  time_ads;
@property ()  BOOL mIsLogin;
@property () int  count_advs_a_day;
@property () long  time_start_count_ads;
@property () int  countShowAsd;
@property () int  kiemruby;

@property () int  is_release_version;
@property () int  request_network_level;
@property () int  level_mod_to_adv;
@property () int  is_blocked;
@property () int  randomInt;


@property (strong) NSString*  promotion_icon;
@property (strong) NSString*  promotion_url;
@property (strong) NSString*  promotion_asking;
@property (strong) NSString*  more_app_link;

@property (strong) NSString*  installation_urlscheme;
@property () int registerOpenchar;

@property (strong) NSString* bc_interstitial_positions;

@property (strong) NSMutableArray  *advArrayOnline;
@property (strong) NSMutableArray  *advArrayOffline;

@property (strong) CustomAdvBannerOffline* gameOfflineBanner;

@property (strong) GADBannerView  *gameBannerView;
@property (strong) GADBannerView  *winBannerView;
@property () int  show_banner_in_game;
@property () int  showAdsCount;
@property () int showCustomAdsCount;
@property () int miniAppFullPageAdsCount;
@property () long long mRequestID;

+ (id)getInstance;

-(NSString*) getPictureUrl;
-(void)DownloadLevel;
-(void)  getLevelDataFromServer:(int)Level;
-(BOOL)loadLevel:(NSData*)_data;
-(void) saveLocalData;
-(void)loadLevelData;
-(void)toggleSound;
-(void)setScore:(int)score;
-(void)setLevel:(int)level;

-(void)setWinTextIndex:(int)index;
-(void)setWinColorIndex:(int)index;

-(int) getBonusForWin:(int)level;
-(void) playEffect: (NSString*)sound;

-(void) stopSound;

-(NSString*)filename:(int)realLevel;
-(BOOL)checkData:(NSData*)_data withLevel:(int)level;
-(NSString*)MD5:(NSString*)inString;

-(NSString*)cachedFileNameForKey:(NSString *)key ;
-(NSData*)loadCachedUrl:(NSString*)url;

-(void) LogClick:(AdvItem*)advCurrent;
-(void) LogView:(AdvItem*)advCurrent;

-(NSMutableString*)basicAdvData;



-(AdvItem*)getOfflineFullAdv;
-(BOOL)checkOfflineFullAdvExists;

-(AdvItem*)getOfflineBanner;

-(BOOL)checkOfflineBannerExists;
- (void)loadRandomData;

-(BOOL)checkShowFullAdv;

-(NSMutableString*)basicGetData;
-(NSMutableString*)basicPostData;
-(NSMutableString*)getDataUrlLevelDownload:(BOOL)isGet;
-(NSMutableURLRequest*)createDeviceLoginRequest;
-(NSMutableURLRequest*)createGetUserDataRequest;
-(void)updateRubyViewAdd;
- (void)winlevel;
- (void)openchar;
-(NSString*)getItunesLink;

-(void)increaseFullPageAdsCount;
-(BOOL)needToShowFullPageAds;
-(void)resetFullPageAdsCount;

//-(NSString*)getURL:(NSString*)url;

@end
