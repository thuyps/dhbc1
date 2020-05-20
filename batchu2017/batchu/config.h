

#ifndef configed
#define APPLE 1
#define MAX_BUNDLE_LEVEL 150

#define  kTrackingId  @"UA-53226140-1"

#define K_AdMobPublicID @"ca-app-pub-7914522602626032/9634374309"
#define GA_INCLUDE 1
#define OPEN_COLOR @"00ffff"

//UI defines

#define SCALE [UIScreen mainScreen].bounds.size.height/568

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define MODIFY_POS self.view.frame.size.height/480
#define screenH  [UIScreen mainScreen].bounds.size.height
#define screenW  [UIScreen mainScreen].bounds.size.width


#define INGAME_ADV_BANNER @"ca-app-pub-7914522602626032/2351327106"
#define WIN_ADV_BANNER @"ca-app-pub-7914522602626032/9874593905"
//font
#define kDefaultFont @"Arial-BoldMT" 
#define kLevelFont @"Arial-BoldMT"
#define kScoreFont @"ArialMT"

#define kDefaultFontSize 12
#define kLevelFontSize 30
#define kScoreFontSize 17

#define kFontText [UIFont fontWithName:@"UTM_Aptima" size:16.0]
#define kFontAlphabet [UIFont fontWithName:@"Helvetica-Bold" size:23.0]

//audio defines
#define kSoundDing  @"click.wav"
#define kSoundFail @"over.mp3"
#define kSoundWin   @"bravo2.mp3"
#define kSoundPass @"sfx_pass.mp3"

#define kAudioEffectFiles @[kSoundDing, kSoundPass, kSoundWin,kSoundFail]
//#define kAudioEffectFiles @[kSoundDing]



#define SP_GAME_DATA @"game_data"
#define SP_LEVEL_DATA @"level_data"
#define SP_USER_RUBY @"user_ruby"



#define  SP_TOTALADMOB @"total_admob"
#define  SP_RELOAD_RUBY @"reload_ruby"
#define  SP_ADV_SETTING @"has_adv"
#define  SP_FB_LEVELS @"fb_levels"
#define  SP_POSTING_TIMES @"posting_times"

#define  SP_ANSWER_BUFFER_BOUGHT_CHARS @"answer_buffer_boought_chars"

#define  SP_INDEX_OF_BOUGHT_CHARS @"index_bought_chars"
#define  SP_POSITION_OF_BOUGHT_CHARS @"position_bought_chars"
#define  SP_POSITION_OF_VISIBLE_BOUGHT_CHARS @"position_visible_bought_chars"
#define  SP_BOUGHT_CHARS @"bought_chars"

#define  SP_VERSION @"version_game"

#define  ACTION_DID_LOGIN @"bc_login"
#define  ACTION_GET_USER_DATA @"bc_userdata"
#define  ACTION_GET_LEVEL_DATA @"bc_leveldata"
#define  ACTION_GET_VERSION_INFO @"bc_versioninfo"
#define  ACTION_LEVEL_WIN @"bc_levelwin"
#define  ACTION_BUY_ITEM @"bc_buyitem"
#define ADV_APP_ID @"111"
#define ADV_SECRET_KEY @"L7KH3DLXIROE1HK9SR2F4"

#define GET_VERSION_INFO_URL @"http://batchu-versioninfo.weplay.vn/bc_api_versioninfo.php"
#define LOGIN_URL @"http://batchu-login.weplay.vn/bc_api_login.php"
#define USER_DATA_URL @"http://batchu-userinfo.weplay.vn/bc_api_userinfo.php"
#define LEVEL_DATA_URL @"http://batchu-getlevel.weplay.vn/bc_api_getlevel.php"
#define WIN_LEVEL_URL @"http://batchu-winlevel.weplay.vn/bc_api_winlevel.php"
#define OPEN_CHAR_URL @"http://batchu-buyitem.weplay.vn/bc_api_buyitem.php"

#define WEB_USER_INFO_URL @"http://batchu-userinfo.weplay.vn/bc_web_userinfo_ios.php"
#define UPDATE_RUBY_URL @"http://batchu-buyitem.weplay.vn/bc_api_adv2ruby.php"

#define REQUIRE_INSTALL @"http://batchu-login.weplay.vn/bc_api_require_installation.php"
#define OPEN_APP @"http://batchu-login.weplay.vn/bc_api_submit_app_opened.php"

#define WEB_USER_SYNC_URL @""
#define URL_WEB_IMAGE0 @"http://weplay.vn/games/batchu/images/"
#define URL_WEB_IMAGE1 @"http://gamevh.vn/games/batchu/images/"

#define  GAME_ID @"11"
#define GAME_NAME  @"BẮT CHỮ"
#define SECRET_KEY  @"R26SFL6OHQ3OA98KD1P6W"
#define DEVICE_OS  @"iOS"

 #define SMS_SYNTAX @"VAS IBATCHU "
 #define SMS_NUMBER @"8785"

#define TAG_RESULT 		@"result"
#define TAG_USER_ID 	@"user_id"
#define TAG_RUBY 		@"ruby"
#define TAG_SESSION_ID 	@"session_id"

#define TAG_LEVEL @"curr_level"
#define TAG_TOTALLEVEL @"total_levels"
#define MIN_LEVEL_MODE_TO_ADV 3

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#ifdef DEBUG
#define BM_DEBUG_MODE 0
#endif

#ifdef BM_DEBUG_MODE
#define BM4Log( fmt, ... ) NSLog(fmt, ## __VA_ARGS__)
#else
#define BM4Log( fmt, ... )
#endif





#define CLEAR_COLOR [UIColor clearColor]

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define screenH  [UIScreen mainScreen].bounds.size.height
#define screenW  [UIScreen mainScreen].bounds.size.width

#ifdef DEBUG
#define BM_DEBUG_MODE 0
#endif

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#ifdef BM_DEBUG_MODE
#define BM4Log( fmt, ... ) NSLog(fmt, ## __VA_ARGS__)
#else
#define BM4Log( fmt, ... )
#endif


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)




typedef enum CharacterState : int {
    kActive = 1,
    kInActive,
    kDidOpen
}CharacterState;

typedef enum CustomAlign : int {
    CustomAlignTopLeft = 1,
    CustomAlignTopCenter,
    CustomAlignTopRight,
    
    CustomAlignMidleCenter,
    
    CustomAlignBottomCenter,
    CustomAlignBottomRight,
    CustomAlignBottomLeft
} CustomAlign;


#define sLoadLevelError @"Có lỗi khi nạp câu hỏi. Bạn hãy email cho nhà phát triển để được trợ giúp."
#define sConnectionError @"Lỗi truy cập mạng! Bạn hãy kiểm tra kết nối Internet."
#define sTimeOut @"Timeout! Bạn hãy kiểm tra kết nối Internet."
#define sMaxLevelMesage @"Bạn thật xuất sắc đã vượt qua hết các level hiện có. Các level mới sẽ được cập nhật sớm. Bạn quay lại sau nhé."
#define sMaxLevelChecking @"Bạn đã vượt qua hết các câu hỏi hiện có.\nHãy kiểm tra kết nối mạng để cập nhật dữ liệu mới nhất."


#define MSG_NETWORK_ERROR @"kết nối mạng bị lỗi!"


#define GAME_SCREEN_BATCHU_ANSWER_HOLDER @"black_placeholder.png"
#define GAME_SCREEN_BATCHU_OFFER_HOLDER @"white_placeholder.png"

#define kAppStoreAddress1 @"https://itunes.apple.com/vn/app/bat-chu/id765366168"
#define kAppStoreAddress2 @"https://itunes.apple.com/vn/app/bat-chu-2/id916170376"

//  ThuyPS:
#define IS_FREE_VERSION

#endif
