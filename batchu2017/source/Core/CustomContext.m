
#import "CustomContext.h"
#import "TextUtils.h"
#import "xInputStream.h"
#import "AudioController.h"
#import "config.h"
#import "xOutputStream.h"

#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import <AdSupport/AdSupport.h>

#import "AdvItem.h"

@implementation CustomContext


#define OPENCHARCOUNT_KEY @"opencharcount"
#define SOUND_KEY @"SoundEnable"
#define LEVEL_KEY @"level"
#define SCORE_KEY @"score"
#define WINTEXT_INDEX_KEY @"wintextindex"
#define WINCOLOR_INDEX_KEY @"wincolorindex"
#define USERID_KEY @"userid"
#define TOTAL_LEVEL_KEY @"totallevel"
#define SESSIONID_KEY @"sessionid"
#define DEVICEID_KEY @"deviceid"


id _instance = nil;

//==============================
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _instance = self;
       // self.startAppOption = NO;
        self.mIsSync = NO;
        self.mWinTexts = [NSArray arrayWithObjects:@"CHÚC MỪNG!", @"TUYỆT VỜI!", @"XUẤT SẮC!", @"QUÁ GIỎI!", @"THIÊN TÀI!", @"CAO THỦ!",
                          @"SIÊU ĐẲNG!", @"QUÁ CHUẨN!", @"HOÀN HẢO!",@"HOAN HÔ!", @"THÚ VỊ!", @"SIÊU HẠNG!", @"ĐỈNH CAO!",
                          @"PHI THƯỜNG!", @"KỲ DIỆU!", @"QUÁ HAY!", @"KHÂM PHỤC!", @"TÀI NĂNG!", @"THÔNG MINH!", @"TRÍ TUỆ!",
                          @"THẦN ĐỒNG!", @"TUYỆT HẢO!", @"BÁI PHỤC!", @"NGƯỠNG MỘ!", @"XINH ĐẸP!", @"CHIẾN THẮNG!", @"SIÊU NHÂN!",
                          @"QUÁ TỐT!", @"KINH NGẠC!", @"THẬT KHỦNG!", nil];
        
        
        self.mWinColors = [NSArray arrayWithObjects:[UIColor blueColor],[UIColor whiteColor],[UIColor cyanColor],[UIColor greenColor],[UIColor magentaColor],[UIColor redColor],[UIColor yellowColor],nil];
        
        self.mIsLogin = NO;
        
        [self loadLocalData];
        
        [self loadRandomData];
        
        if(self.mLevel==0){
            self.mLevel = 1;
#ifdef BATCHU2
            self.mLevel = 900;
#endif
            
            self.mSoundEnable = 1;
            NSInteger ranInt = arc4random();
            self.mWinTextIndex = ranInt %self.mWinTexts.count;
            self.mWinColorIndex = arc4random() % self.mWinColors.count;
            self.mScore = 120;
        }
        
        
        
        self.audioController = [[AudioController alloc] init] ;
        [self.audioController preloadAudioEffects:kAudioEffectFiles];
        self.mRefID = @"";
#ifndef APPOTA
#ifndef CLEVERADS
        @try{
            
#ifdef VCC
            NSString *path = [[NSBundle mainBundle] pathForResource: @"refid" ofType: @"txt"];
            
#else
            NSString *path = [[NSBundle mainBundle] pathForResource: @"refcode" ofType: @"txt"];
#endif
            NSError *errorReading;
            NSString *ref = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:&errorReading];
            if(ref != nil){
                ref = [ref stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self.mRefID = ref;
            }
            
            
            
        }@catch (NSException *e) {
            
        }
#endif
#endif
        
    }
    
    return self;
}

-(void) DownloadLevel
{
    if(!self.isLevelDownloading)
    {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getLevelDataFromServer) userInfo:Nil repeats:NO];
    }
}

-(NSMutableURLRequest*)createDeviceLoginRequest
{
    
    NSURL *url = [NSURL URLWithString:LOGIN_URL];
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    NSMutableString *sDataUrl = [self basicPostData];
    [sDataUrl appendFormat:@"&action=%@",ACTION_DID_LOGIN];
    [sDataUrl appendFormat:@"&ruby=%ld",(long)self.mScore];
    [sDataUrl appendFormat:@"&curr_level=%ld",(long)self.mLevel];
    
    BM4Log(@"%@",sDataUrl);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}


-(void)DeviceLogin
{
    NSMutableURLRequest* request = [self createDeviceLoginRequest];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self receiveLogin:data];
                           }];
}

-(NSString*)getRequestID
{
    long seconds = time(0);
    if(seconds < self.mRequestID){
        self.mRequestID++;
    }else{
        self.mRequestID = seconds;
    }
    
    NSString* lvRequestID = [NSString stringWithFormat:@"%lld",self.mRequestID];
    return lvRequestID;
}

-(NSMutableString*)basicGetData
{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString* lvRequestID = [self getRequestID];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [self MD5:lvBaseChecksum];
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:@""];
    
    [sDataUrl appendString: @"?game_id="];
    [sDataUrl appendString:GAME_ID];
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    [sDataUrl appendString: @"&device_id="];
    [sDataUrl appendString:self.mDeviceID];
    [sDataUrl appendFormat:@"&device_os=%@",DEVICE_OS];
    
    
#ifdef PARTNER
    if(self.mRefID != nil && ![self.mRefID isEqualToString:@""]){
        [sDataUrl appendString: @"&ref_id="];
        [sDataUrl appendString:self.mContext.mRefID];
    }
#endif
    
    
    
    return sDataUrl;
}

-(NSMutableString*)basicPostData
{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString* lvRequestID = [self getRequestID];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [self MD5:lvBaseChecksum];
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:@""];
    
    [sDataUrl appendString: @"game_id="];
    [sDataUrl appendString:GAME_ID];
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    [sDataUrl appendString: @"&device_id="];
    [sDataUrl appendString:self.mDeviceID];
    [sDataUrl appendFormat:@"&device_os=%@",DEVICE_OS];
    
    
#ifdef PARTNER
    if(self.mRefID != nil && ![self.mRefID isEqualToString:@""]){
        [sDataUrl appendString: @"&ref_id="];
        [sDataUrl appendString:self.mContext.mRefID];
    }
#endif
    
    
    
    return sDataUrl;
}

-(NSMutableString*)getDataUrlLevelDownload:(BOOL)isGet
{
    NSString* pChecksum = [NSString stringWithFormat:@"%@%@%d%@",GAME_ID ,self.mUserID , self.levelDownloading , SECRET_KEY];
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:LEVEL_DATA_URL];
    
    if(isGet){
        [sDataUrl appendString: @"?"];
    }
    [sDataUrl appendString: @"game_id="];
    [sDataUrl appendString:GAME_ID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:[self MD5:pChecksum ]];
    
    [sDataUrl appendString: @"&user_id="];
    [sDataUrl appendString:self.mUserID];
    
    [sDataUrl appendString: @"&device_id="];
    [sDataUrl appendString:self.mDeviceID];
    
    [sDataUrl appendString: @"&device_os=iOS"];
    
    [sDataUrl appendString: @"&level_id="];
    [sDataUrl appendString:[NSString stringWithFormat:@"%d",self.levelDownloading]];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    return sDataUrl;
}

-(void) getLevelDataFromServer
{
    
    if(self.mUserID==nil){
        //just login and return
        [self DeviceLogin];
        return;
    }
    
    if(self.mUserID!=nil){
        
        if(self.levelDownloading < MAX_BUNDLE_LEVEL){
            self.levelDownloading = MAX_BUNDLE_LEVEL;
        }
        
        if(self.levelDownloading < self.mLevel){
            self.levelDownloading = self.mLevel;
        }
        
        if(self.mLevel+14 < self.levelDownloading)
        {
            return ;
        }
        
        NSString* sDataUrl = [self getDataUrlLevelDownload:YES];
        
        [self getUrl:sDataUrl];
        
    }
    
}

/*-(void) getLevelDataFromServer
{
    
    if(self.mUserID==nil){
        NetworkManager* net = [NetworkManager sharedInstance];
        [net deviceIDLogin];
        net.delegate = self;
        return;
    }
    if(self.mUserID!=nil){
        
        if(self.levelDownloading < MAX_BUNDLE_LEVEL){
            self.levelDownloading = MAX_BUNDLE_LEVEL;
        }
        
        if(self.levelDownloading < self.mLevel){
            self.levelDownloading = self.mLevel;
        }
        
        if(self.mLevel+14 < self.levelDownloading)
        {
            return ;
        }
        NSString* pChecksum = [NSString stringWithFormat:@"%@%@%d%@",GAME_ID ,self.mUserID , self.levelDownloading , SECRET_KEY];
        
        NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:LEVEL_DATA_URL];
        [sDataUrl appendString: @"?game_id="];
        [sDataUrl appendString:GAME_ID];
        
        [sDataUrl appendString: @"&user_id="];
        [sDataUrl appendString:self.mUserID];
        
        [sDataUrl appendString: @"&device_id="];
        [sDataUrl appendString:self.mDeviceID];
        
        [sDataUrl appendString: @"&device_os=iOS"];
        
        [sDataUrl appendString: @"&level_id="];
        [sDataUrl appendString:[NSString stringWithFormat:@"%d",self.levelDownloading]];
        [sDataUrl appendString: @"&checksum="];
        
        [sDataUrl appendString:[self MD5:pChecksum ]];
        
        
        NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        [sDataUrl appendString: @"&game_version="];
        [sDataUrl appendString:version];
        
        [self getUrl:sDataUrl];
        
    }
    
}
*/
/*
-(void) getUrl:(NSString*)urlString
{
    if(!self.isLevelDownloading)
    {
        self.isLevelDownloading = YES;
        BM4Log(@"%@",urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request setDidFinishSelector:@selector(requestCompleted:)];
        [request setDidFailSelector:@selector(requestError:)];
        
        [request setDelegate:self];
        
        [request startAsynchronous];
    }
}
*/

-(void) getUrl:(NSString*)urlString
{
    if(!self.isLevelDownloading)
    {
        
        self.isLevelDownloading = YES;
        BM4Log(@"%@",urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        //initialize a request from url
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   [self requestCompleted:data];
                               }];
    }
}


- (void)requestCompleted:(NSData *)data
{
    
    self.isLevelDownloading = NO;
    
    if (data==nil){
        return;
    }
    
    
    if([self checkData:data withLevel:self.levelDownloading])
    {
        
        [data writeToFile:[self filename:self.levelDownloading] atomically:YES];
        
        self.levelDownloading = self.levelDownloading +1;
        
        [self saveLocalData];
        
        if(self.mLevel+14 > self.levelDownloading)
        {
            BM4Log(@"continue download");
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getLevelDataFromServer) userInfo:Nil repeats:NO];
        }
        
    }
    
}

/*
- (void)requestCompleted:(ASIHTTPRequest *)request
{
    self.isLevelDownloading = NO;
    NSData *data = [request responseData];
    
    if (data==nil){
        [[AppDelegate getInstance].tracker trackEventWithCategory:@"download nil" withAction:[NSString stringWithFormat:@"%d",self.mLevel]  withLabel:[NSString stringWithFormat:@"%d",self.mScore] withValue:[NSNumber numberWithInt:self.mLevel]];
        return;
    }
    
    
    if([self checkData:data withLevel:self.levelDownloading])
    {
        BM4Log(@"download thanh cong %d",self.levelDownloading);
        
        [[AppDelegate getInstance].tracker trackEventWithCategory:@"download success" withAction:[NSString stringWithFormat:@"%d",self.mLevel]  withLabel:[NSString stringWithFormat:@"%d",self.mScore] withValue:[NSNumber numberWithInt:self.mLevel]];
        
        [data writeToFile:[self filename:self.levelDownloading] atomically:YES];
        
        self.levelDownloading = self.levelDownloading +1;
        
        [self saveLocalData];
        
        if(self.mLevel+14 > self.levelDownloading)
        {
            BM4Log(@"continue download");
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getLevelDataFromServer) userInfo:Nil repeats:NO];
        }
        
    }
    
}


- (void)requestError:(ASIHTTPRequest *)request
{
    self.isLevelDownloading = NO;
    
    NSError *error = [request error];
    BM4Log(@"%@",[error description]);
}*/

+ (id)getInstance
{
    if(_instance==nil){
        [[CustomContext alloc] init];
    }
    return _instance;
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

-(NSString*)filename:(int)realLevel
{
    if (realLevel<=MAX_BUNDLE_LEVEL){
        int level = [[self.mRandomLevel objectAtIndex:(realLevel-1)] intValue];
        NSString* filename = [NSString stringWithFormat:@"lv%04d",level];
        NSString *path = [[NSBundle mainBundle] pathForResource: filename ofType: @"dat"];
        return path;
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString* filename = [NSString stringWithFormat:@"lv%04d",realLevel];
        NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:filename];
        return filePathAndDirectory;
    }
}


-(void)loadLevelData
{
    NSMutableData* _data = nil;
#ifdef BATCHU2
    
    if(![self.mAllowSync isEqualToString:@"1"]){
        
        NSString* filename = [NSString stringWithFormat:@"lv%04d",self.mLevel];
        NSString *path = [[NSBundle mainBundle] pathForResource: filename ofType: @"dat"];
        _data = [[NSMutableData alloc] initWithContentsOfFile:path];
        
    }
    
    if(_data == nil)
    {
        _data = [[NSMutableData alloc] initWithContentsOfFile:[self filename:self.mLevel]];
    }
    
#else
    _data = [[NSMutableData alloc] initWithContentsOfFile:[self filename:self.mLevel]];
#endif
    
    if(![self loadLevel:_data])
    {
        if(self.mUserID==nil)
            return;
        self.levelDownloading = self.mLevel;
        
        NSString* pChecksum = [NSString stringWithFormat:@"%@%@%d%@",GAME_ID ,self.mUserID , self.levelDownloading , SECRET_KEY];
        
        NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:LEVEL_DATA_URL];
        [sDataUrl appendString: @"?game_id="];
        [sDataUrl appendString:GAME_ID];
        
        [sDataUrl appendString: @"&user_id="];
        [sDataUrl appendString:self.mUserID];
        
        [sDataUrl appendString: @"&device_id="];
        [sDataUrl appendString:self.mDeviceID];
        
        [sDataUrl appendString: @"&device_os=iOS"];
        
        [sDataUrl appendString: @"&level_id="];
        [sDataUrl appendString:[NSString stringWithFormat:@"%d",self.levelDownloading]];
        [sDataUrl appendString: @"&checksum="];
        [sDataUrl appendString:[self MD5:pChecksum ]];
        NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        [sDataUrl appendString: @"&game_version="];
        [sDataUrl appendString:version];
        
        NSURL* url = [NSURL URLWithString:sDataUrl];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        
        if(![self loadLevel:data])
        {
            BM4Log(@"network error");
        }else{
            
            BM4Log(@"download thanh cong %d",self.levelDownloading);
            [data writeToFile:[self filename:self.levelDownloading] atomically:YES];
            
            self.levelDownloading = self.levelDownloading +1;
            
            [self saveLocalData];
        }
    }
}

-(NSString*)GetAnswerStringFromData:(NSData*)_data
{
    @try{
        if(_data==nil)
            return nil;
        
        const uint8_t *bytes = (const uint8_t *)[_data bytes];
        int pos=0;
        int8_t byte1 = bytes[0];
        int8_t byte2 = bytes[1];
        int8_t byte3 = bytes[2];
        int8_t byte4 = bytes[3];
        
        int i1 = (int)(byte1 << 24) & 0xFF000000;
        int i2 = (int)(byte2 << 16) & 0x00FF0000;
        int i3 = (int)(byte3 << 8) & 0x0000FF00;
        int i4 = (int)(byte4 & 0xFF);
        pos=4;
        int AnswerLength =  i1 | i2 | i3 | i4;
        
        //2. Lấy chuỗi đáp án (theo bytes)
        NSData *arrAnswer = [_data subdataWithRange:NSMakeRange(4,AnswerLength)];
        
        
        NSString* sEncodedAnswer = [[NSString alloc] initWithData:arrAnswer
                                                          encoding:NSUTF8StringEncoding];
        
        pos+=AnswerLength;
        //3. Đọc độ dài (theo bytes) của chuỗi Rand-Key
        
        byte1 = bytes[pos];
        byte2 = bytes[pos+1];
        byte3 = bytes[pos+2];
        byte4 = bytes[pos+3];
        
        i1 = (int)(byte1 << 24) & 0xFF000000;
        i2 = (int)(byte2 << 16) & 0x00FF0000;
        i3 = (int)(byte3 << 8) & 0x0000FF00;
        i4 = (int)(byte4 & 0xFF);
        
        int RanKeyLen =  i1 | i2 | i3 | i4;
        pos+=4;
        
        NSData *RanKeyData = [_data subdataWithRange:NSMakeRange(pos,RanKeyLen)];
        
        NSString* RanKeyString = [[NSString alloc] initWithData:RanKeyData
                                                        encoding:NSUTF8StringEncoding] ;
        pos+=RanKeyLen;
        pos+=1;
        int len = _data.length-pos;
        
        
        
        NSString* s = sEncodedAnswer;
        
        //1. Đọc độ dài chuỗi ngẫu nhiên
        //int num1 = Integer.parseInt("" + );
        int num1 = [[s substringWithRange:NSMakeRange(0, 1)] intValue];
        num1+=2;
        
        int num3 = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
        num1+=2;
        
        NSInteger iArrPosition[num3];
        
        //5. Đọc giá trị các vị trí của chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //iArrPosition[i] = Integer.parseInt("" + s.charAt(2 * i) + s.charAt(2 * i + 1));
            int value = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
            iArrPosition[i] = value;
            num1+=2;
        }
        
        s = [s substringFromIndex:num1];
        
        NSMutableString* sOut = [[NSMutableString alloc] initWithString:@""];
        //6. Lấy chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //sOut += s.charAt(iArrPosition[i]);
            [sOut appendString:[s substringWithRange:NSMakeRange(iArrPosition[i],1)]];
        }
        
        return sOut;
        
    }@catch (NSException *e) {
        return nil;
    }
}


-(BOOL)checkData:(NSData*)_data withLevel:(int)level
{
    @try{
        if(_data==nil)
            return NO;
        
        const uint8_t *bytes = (const uint8_t *)[_data bytes];
        int pos=0;
        int8_t byte1 = bytes[0];
        int8_t byte2 = bytes[1];
        int8_t byte3 = bytes[2];
        int8_t byte4 = bytes[3];
        
        int i1 = (int)(byte1 << 24) & 0xFF000000;
        int i2 = (int)(byte2 << 16) & 0x00FF0000;
        int i3 = (int)(byte3 << 8) & 0x0000FF00;
        int i4 = (int)(byte4 & 0xFF);
        pos=4;
        int AnswerLength =  i1 | i2 | i3 | i4;
        
        //2. Lấy chuỗi đáp án (theo bytes)
        NSData *arrAnswer = [_data subdataWithRange:NSMakeRange(4,AnswerLength)];
        
        
        NSString* sEncodedAnswer = [[NSString alloc] initWithData:arrAnswer
                                                          encoding:NSUTF8StringEncoding] ;
        
        pos+=AnswerLength;
        //3. Đọc độ dài (theo bytes) của chuỗi Rand-Key
        
        byte1 = bytes[pos];
        byte2 = bytes[pos+1];
        byte3 = bytes[pos+2];
        byte4 = bytes[pos+3];
        
        i1 = (int)(byte1 << 24) & 0xFF000000;
        i2 = (int)(byte2 << 16) & 0x00FF0000;
        i3 = (int)(byte3 << 8) & 0x0000FF00;
        i4 = (int)(byte4 & 0xFF);
        
        int RanKeyLen =  i1 | i2 | i3 | i4;
        pos+=4;
        
        NSData *RanKeyData = [_data subdataWithRange:NSMakeRange(pos,RanKeyLen)];
        
        NSString* RanKeyString = [[NSString alloc] initWithData:RanKeyData
                                                        encoding:NSUTF8StringEncoding] ;
        pos+=RanKeyLen;
        pos+=1;
        int len = _data.length-pos;
        NSData *tempdata = [_data subdataWithRange:NSMakeRange(pos,len)];
        UIImage* mImage = [[UIImage alloc] initWithData:tempdata] ;
        
        if(mImage.size.width==0){
            return NO;
        }
        
        
        NSString* s = sEncodedAnswer;
        
        //1. Đọc độ dài chuỗi ngẫu nhiên
        //int num1 = Integer.parseInt("" + );
        int num1 = [[s substringWithRange:NSMakeRange(0, 1)] intValue];
        num1+=2;
        
        int num3 = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
        num1+=2;
        
        NSInteger iArrPosition[num3];
        
        //5. Đọc giá trị các vị trí của chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //iArrPosition[i] = Integer.parseInt("" + s.charAt(2 * i) + s.charAt(2 * i + 1));
            int value = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
            iArrPosition[i] = value;
            num1+=2;
        }
        
        s = [s substringFromIndex:num1];
        
        NSMutableString* sOut = [[NSMutableString alloc] initWithString:@""];
        //6. Lấy chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //sOut += s.charAt(iArrPosition[i]);
            [sOut appendString:[s substringWithRange:NSMakeRange(iArrPosition[i],1)]];
        }
        
        BM4Log(@"level download: %d = %@",self.levelDownloading,sOut);
        
        NSMutableData* preLevelData = [[NSMutableData alloc] initWithContentsOfFile:[self filename:(self.levelDownloading-1)]];
        NSMutableString* sOut1 = [self GetAnswerStringFromData:preLevelData];
        if([sOut isEqualToString:sOut1])
        {
            return NO;
        }
        return YES;
    }@catch (NSException *e) {
        return NO;
    }
}

-(BOOL)loadLevel:(NSData*)_data
{
    if(_data==nil) return NO;
    @try{
        
        const uint8_t *bytes = (const uint8_t *)[_data bytes];
        int pos=0;
        int8_t byte1 = bytes[0];
        int8_t byte2 = bytes[1];
        int8_t byte3 = bytes[2];
        int8_t byte4 = bytes[3];
        
        int i1 = (int)(byte1 << 24) & 0xFF000000;
        int i2 = (int)(byte2 << 16) & 0x00FF0000;
        int i3 = (int)(byte3 << 8) & 0x0000FF00;
        int i4 = (int)(byte4 & 0xFF);
        pos=4;
        int AnswerLength =  i1 | i2 | i3 | i4;
        
        //2. Lấy chuỗi đáp án (theo bytes)
        NSData *arrAnswer = [_data subdataWithRange:NSMakeRange(4,AnswerLength)];
        //NSString*  mEncodedAnswer =  [NSString stringWithUTF8String:(const char*)[arrAnswer bytes]];
        
        
        NSString* sEncodedAnswer = [[NSString alloc] initWithData:arrAnswer
                                                          encoding:NSUTF8StringEncoding];
        BM4Log(@"%@",sEncodedAnswer);
        pos+=AnswerLength;
        //3. Đọc độ dài (theo bytes) của chuỗi Rand-Key
        
        byte1 = bytes[pos];
        byte2 = bytes[pos+1];
        byte3 = bytes[pos+2];
        byte4 = bytes[pos+3];
        
        i1 = (int)(byte1 << 24) & 0xFF000000;
        i2 = (int)(byte2 << 16) & 0x00FF0000;
        i3 = (int)(byte3 << 8) & 0x0000FF00;
        i4 = (int)(byte4 & 0xFF);
        
        int RanKeyLen =  i1 | i2 | i3 | i4;
        pos+=4;
        //4. Lấy chuỗi đáp án (theo bytes)
        
        NSData *RanKeyData = [_data subdataWithRange:NSMakeRange(pos,RanKeyLen)];
        
        
        
        NSString* RanKeyString = [[NSString alloc] initWithData:RanKeyData
                                                        encoding:NSUTF8StringEncoding];
        BM4Log(@"%@",RanKeyString);
        pos+=RanKeyLen;
        
        self.mRandKey = RanKeyString;
        //5. Lấy kiểu dữ liệu ảnh (jpg/png)
        
        self.mImgType = bytes[pos];
        
        pos+=1;
        
        
        //6. Lấy dữ liệu ảnh
        int len = _data.length-pos;
        NSData *tempdata = [_data subdataWithRange:NSMakeRange(pos,len)];
        
        if( self.mImage !=nil){
            self.mImage;
            self.mImage=nil;
        }
        
#ifdef DEBUG
        /*
         NSData *tempdata1 = [_data subdataWithRange:NSMakeRange(pos,len)];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         
         NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
         [tempdata1 writeToFile:filePathAndDirectory atomically:YES];
         */
        
#endif
        self.mImage = [[UIImage alloc] initWithData:tempdata];
        
        
        
        NSString* s = sEncodedAnswer;
        
        //1. Đọc độ dài chuỗi ngẫu nhiên
        //int num1 = Integer.parseInt("" + );
        int num1 = [[s substringWithRange:NSMakeRange(0, 1)] intValue];
        num1+=2;
        
        int num3 = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
        num1+=2;
        
        NSInteger iArrPosition[num3];
        
        //5. Đọc giá trị các vị trí của chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //iArrPosition[i] = Integer.parseInt("" + s.charAt(2 * i) + s.charAt(2 * i + 1));
            int value = [[s substringWithRange:NSMakeRange(num1, 2)] intValue];
            iArrPosition[i] = value;
            num1+=2;
        }
        
        s = [s substringFromIndex:num1];
        
        NSMutableString* sOut = [[NSMutableString alloc] initWithString:@""];
        //6. Lấy chuỗi đáp án
        for (int i = 0; i < num3; i++) {
            //sOut += s.charAt(iArrPosition[i]);
            [sOut appendString:[s substringWithRange:NSMakeRange(iArrPosition[i],1)]];
        }
        
        BM4Log(@"%@",sOut);
        
#ifdef DEBUG
        //sOut = [[NSMutableString alloc] initWithString:@"cau dai hai dong"];
#endif
        self.mAnswerString = sOut;
        
        TextUtils *textUtils = [[TextUtils alloc] init];
        NSString* lvAnswerShort = [textUtils getNoMarkUnicode:[textUtils removeSpace:sOut]];
        self.mAnswerStringBodau = lvAnswerShort;
        
        NSArray* arrsOfferFull = [textUtils getSuggestionFull:lvAnswerShort];
        
        BM4Log(@"%@",arrsOfferFull);
        self.mSuggestionArray = arrsOfferFull;
        return YES;
    }@catch (NSException *e) {
        return NO;
    }
}


-(NSString*) getPictureUrl
{
    NSString* image_type;
    if (self.mImgType == 0)
    {
        image_type = @".jpg";
    }
    else
    {
        image_type = @".png";
    }
    
    NSString* image_url = [NSString stringWithFormat:@"%@img_%04d_%@",URL_WEB_IMAGE0,self.mLevel,self.mRandKey];
    return image_url;
}

-(void)toggleSound
{
    if(self.mSoundEnable==0)
    {
        self.mSoundEnable = 1;
    }else{
        self.mSoundEnable = 0;
    }
    
    [self saveLocalData];
    
}
-(void)setScore:(int)score
{
    self.mScore = score;
    [self saveLocalData];
}

-(void)setLevel:(int)level
{
    self.mLevel = level;
#ifdef BATCHU2
    if(level<900)
    {
        self.mLevel = 900;
    }
#endif
    [self saveLocalData];
}

-(void)setWinTextIndex:(int)index
{
    self.mWinTextIndex  = index;
    [self saveLocalData];
}

-(void)setWinColorIndex:(int)index
{
    self.mWinColorIndex  = index;
    [self saveLocalData];
}

-(void) playEffect: (NSString*)sound
{
    if(self.mSoundEnable==1){
        [self.audioController playEffect:sound];
    }
    
}

-(void) stopSound
{
    
    [self.audioController stopSound];
    
    
}

-(int) getBonusForWin:(int)level
{
    if (level <= 3) {
        return 13 - level;
    }
    if (level <= 12) {
        return 10 - (level - 1) / 2;
    }
    return 4;
}

- (NSString *) advertisingIdentifier
{
    if (!NSClassFromString(@"ASIdentifierManager")) {
        SEL selector = NSSelectorFromString(@"uniqueIdentifier");
        if ([[UIDevice currentDevice] respondsToSelector:selector]) {
            return [[UIDevice currentDevice] performSelector:selector];
        }else{
            return nil;
        }
        
    }else{
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
}



- (void)loadLocalData
{
    
    
    @try
    {
        
        xInputStream* inputStream = [xInputStream initFromFile:[self filename]];
        if (inputStream == nil) {
            
            self.mLevel = 0;
            self.kiemruby = 0;
            self.mScore = 0;
            self.is_blocked = 0;
            self.mWinTextIndex = 0;
            self.mWinColorIndex = 0;
            self.mSoundEnable = 0;
            self.mTotalLevels = MAX_BUNDLE_LEVEL;
            
            self.levelDownloading = MAX_BUNDLE_LEVEL+1;
#ifdef BATCHU2
            self.mTotalLevels = 905;
            self.levelDownloading = 905;
            self.mLevel = 900;
#endif
            self.mUserID = @"";
            self.mSessionID = @"";
            self.mDeviceID = @"";
            self.mSmsNumber = SMS_NUMBER;
            self.sms_syntax = SMS_SYNTAX;
            self.count_advs_a_day = 0;
            self.time_start_count_ads = 0;
            
            self.total_advs_a_day = @"30";
            self.delay_adv_in_second = @"30";
            self.countShowAsd = 0;
            

            self.mAdmodID = K_AdMobPublicID;

            
            self.level_mod_to_adv = MIN_LEVEL_MODE_TO_ADV;
            self.request_network_level = 70;
            
            if(self.mDeviceID==nil || [self.mDeviceID isEqualToString:@""]){
                NSString *deviceUuid;
                if(deviceUuid == nil){
                    deviceUuid = [self advertisingIdentifier];
                }
                
                
                if(deviceUuid == nil || [deviceUuid isEqualToString:@""]){
                    long t = time(0);
                    NSInteger ranInt = arc4random();
                    deviceUuid = [NSString stringWithFormat:@"%@-%ld-%d",GAME_ID,t,ranInt];
                }
                
                #ifdef DEBUG
                   self.mDeviceID = [NSString stringWithFormat:@"IOS_%@_test_4",deviceUuid];
                #else
                self.mDeviceID = [NSString stringWithFormat:@"IOS_%@_3",deviceUuid];
                #endif
                self.mLevel = 0;
#ifdef BATCHU2
                self.mLevel = 900;
#endif
                self.mSoundEnable = 1;
                self.mScore = 0;
                
                [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(saveLocalData) userInfo:nil repeats:NO];
                return;
            }
            return ;
        }
        
        
        
        
        
        self.levelDownloading = [inputStream readInt];
        [inputStream readInt];
        self.mLevel = [inputStream readInt];
        self.mScore = [inputStream readInt];
        
        if (self.mScore < 0)
            self.mScore = 0;
        
        self.mWinTextIndex = [inputStream readInt];
        self.mWinColorIndex = [inputStream readInt];
        self.mSoundEnable = [inputStream readInt];
        self.mTotalLevels = [inputStream readInt];
        
        self.mUserID = [inputStream readString];
        self.mSessionID = [inputStream readString];
        self.mDeviceID = [inputStream readString];
        
        self.mAdmodID = [inputStream readString];
        self.mSmsNumber = [inputStream readString];
        
        self.mScoreAds = [inputStream readString];
        
        self.delay_adv_in_second = [inputStream readString];
        self.total_advs_a_day = [inputStream readString];
        
        self.push_message  = [inputStream readString];
        self.sms_syntax = [inputStream readString];
        
        if(self.mAdmodID == nil || [self.mAdmodID isEqualToString:@""]){

            self.mAdmodID = K_AdMobPublicID;

        }
        
        if(self.mScoreAds == nil || [self.mScoreAds isEqualToString:@""]){
            self.mScoreAds = @"4";
        }
        
        self.count_advs_a_day = [inputStream readInt];
        self.time_start_count_ads = [inputStream readLong];
        self.countShowAsd = [inputStream readInt];
        
        self.level_mod_to_adv = [inputStream readInt];
        self.request_network_level = [inputStream readInt];
        
        self.is_blocked = [inputStream readInt];
        self.randomInt = [inputStream readInt];
        
        if(self.level_mod_to_adv == 0)
            self.level_mod_to_adv = MIN_LEVEL_MODE_TO_ADV;
        if(self.request_network_level == 0)
            self.request_network_level = 70;
        
        
        self.promotion_url  = [inputStream readString];
        self.promotion_icon  = [inputStream readString];
        self.promotion_asking  = [inputStream readString];
        self.more_app_link  = [inputStream readString];
        //self.startAppOption  =
       BOOL test = [inputStream readBool];
        
        self.mIsSync  = [inputStream readBool];
#ifdef BATCHU2
        self.mAllowSync  = [inputStream readString];
#endif
        if(self.promotion_url == nil){
            self.promotion_url = @"";
        }
        
        if(self.promotion_icon == nil){
            self.promotion_icon = @"";
        }
        
        if(self.promotion_asking == nil){
            self.promotion_asking = @"";
        }
        
        if(self.more_app_link == nil){
            self.more_app_link = @"";
        }
        
#ifdef BATCHU2
        if(self.mLevel < 900)
        {
            self.mLevel = 900;
        }
#endif
        
        self.kiemruby = [inputStream readInt];
        
        int count = [inputStream readInt];
        
        if(self.mOpenCharCounts != nil){
            self.mOpenCharCounts = nil;
        }
        
        if(count > 0){
            self.mOpenCharCounts = [[NSMutableArray alloc] init];
            for (int i = 0; i < count; i++) {
                int test = [inputStream readInt];
                [self.mOpenCharCounts addObject:[NSString stringWithFormat:@"%d",test]];
            }
        }
        
        self.show_banner_in_game = [inputStream readInt];
        self.showAdsCount = [inputStream readInt];
        self.showCustomAdsCount = [inputStream readInt];
        
        self.mIsSyncNative = [inputStream readBool];
        self.miniAppFullPageAdsCount = [inputStream readInt];
        
        
        
    }
    @catch (NSException* ex)
    {
        
        BM4Log(@"excepton  :%@",[ex description]);
    }
    
    
    
    
}


- (void)loadRandomData
{
    
    
    @try
    {
        if(self.mUserID != nil && ![self.mUserID isEqualToString:@""]){
            self.randomInt = [self.mUserID intValue] % 100;
        }
        
        if(self.randomInt <=0){
            self.randomInt = arc4random() % 100;
            [self saveLocalData];
        }
        
        NSLog(@"random int : %d\n",self.randomInt);
        
        if(self.randomInt ==0)  self.randomInt = 1;
        
        NSString* filename = [NSString stringWithFormat:@"rdata%d",self.randomInt];
        NSString *path = [[NSBundle mainBundle] pathForResource: filename ofType: @"dat"];
        
        self.mRandomLevel = [[NSMutableArray alloc] init];
        
        xInputStream* inputStream = [xInputStream initFromFile:path];
        NSInteger i = 1;
        while (i > 0) {
            i = [inputStream readRandomInt];
            if(i>0){
                [self.mRandomLevel addObject:[NSNumber numberWithInteger:i]];
            }
            //NSLog(@"%d\n",i);
        }
        
        // NSLog(@"size:%d",self.mRandomLevel.count);
        
        
        
    }
    @catch (NSException* ex)
    {
        
        
    }
    
    
    
    
}

-(NSString*)filename
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:@"config1.bin"];
    return filePathAndDirectory;
}

- (void)saveLocalData
{
    @try {
        xOutputStream* outputStream = [[xOutputStream alloc] init:1024];
        if(self.levelDownloading < (MAX_BUNDLE_LEVEL+1)){
            self.levelDownloading = MAX_BUNDLE_LEVEL+1;
        }
        
        if(self.mLevel > self.mTotalLevels+1){
            self.mLevel = (int)self.mTotalLevels+1;
        }
        
        [outputStream writeInt:(int)self.levelDownloading];
        [outputStream writeInt:1];
        [outputStream writeInt:(int)self.mLevel];
        [outputStream writeInt:(int)self.mScore];
        
        [outputStream writeInt:(int)self.mWinTextIndex];
        [outputStream writeInt:(int)self.mWinColorIndex];
        [outputStream writeInt:(int)self.mSoundEnable];
        [outputStream writeInt:(int)self.mTotalLevels];
        
        [outputStream writeString:self.mUserID];
        [outputStream writeString:self.mSessionID];
        [outputStream writeString:self.mDeviceID];
        [outputStream writeString:self.mAdmodID];
        [outputStream writeString:self.mSmsNumber];
        [outputStream writeString:self.mScoreAds];
        
        [outputStream writeString:self.delay_adv_in_second];
        [outputStream writeString:self.total_advs_a_day];
        [outputStream writeString:self.push_message];
        
        [outputStream writeString:self.sms_syntax];
        [outputStream writeInt:self.count_advs_a_day];
        [outputStream writeLong:self.time_start_count_ads];
        [outputStream writeInt:self.countShowAsd];
        [outputStream writeInt:self.level_mod_to_adv];
        [outputStream writeInt:self.request_network_level];
        [outputStream writeInt:self.is_blocked];
        [outputStream writeInt:self.randomInt];
        
        [outputStream writeString:self.promotion_url];
        [outputStream writeString:self.promotion_icon];
        [outputStream writeString:self.promotion_asking];
        [outputStream writeString:self.more_app_link];
        
        //[outputStream writeBool:self.startAppOption];
        [outputStream writeBool:YES];
        
        [outputStream writeBool:self.mIsSync];
#ifdef BATCHU2
        [outputStream writeString:self.mAllowSync];
#endif
        [outputStream writeInt:self.kiemruby];
        
        if(self.mOpenCharCounts != nil && self.mOpenCharCounts.count > 0 ){
            [outputStream writeInt:self.mOpenCharCounts.count];
            
            for (NSString* str in self.mOpenCharCounts) {
                [outputStream writeInt:[str intValue]];
            }
        }else{
            [outputStream writeInt:0];
           
        }
        [outputStream writeInt:self.show_banner_in_game];
        [outputStream writeInt:self.showAdsCount];
        [outputStream writeInt:self.showCustomAdsCount];
        
        [outputStream writeBool:self.mIsSyncNative];
        [outputStream writeInt:self.miniAppFullPageAdsCount];
        
        [outputStream writeToFile:[self filename]];
        
        
        
    }
    @catch (NSException *exception) {
        BM4Log(@"%@",[exception reason]);
    }
    @finally {
        
    }
    
}


- (void)receivedUrlData:(NSData*) data
{
    [self receiveLogin:data];
    
}


-(void)receiveLogin:(NSData*) data
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
        
        
        if([lvResult isEqualToString:@"OK"]){
            
            NSString* lvUserID = [lvObjUserInfo objectForKey:TAG_USER_ID];
            if ( lvUserID != nil && [self.mUserID isEqualToString:@""]){
                self.mUserID = lvUserID;
                self.randomInt = 0;
                [self loadRandomData];
            }else{
                self.mUserID = lvUserID;
            }
            
            self.mTotalLevels = [[lvObjUserInfo objectForKey:TAG_TOTALLEVEL] integerValue];
            self.mSessionID = [lvObjUserInfo objectForKey:TAG_SESSION_ID];
            self.installation_urlscheme = [lvObjUserInfo objectForKey:@"installation_urlscheme"];
            self.mIsLogin = YES;
            if(self.mLevel <= [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue]){
                self.mLevel = [[lvObjUserInfo objectForKey:TAG_LEVEL] integerValue];
#ifdef BATCHU2
                if( self.mLevel < 900)
                {
                    self.mLevel = 900;
                }
#endif
                self.mScore = [[lvObjUserInfo objectForKey:TAG_RUBY] integerValue];
            }
            
            
            if((self.mTotalLevels+1) < self.mLevel){
                self.mLevel = self.mTotalLevels + 1;
            }
            
            [self saveLocalData];
        }
    }
    
    
}


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
}

-(NSData*)loadCachedUrl:(NSString*)url
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString * filename = [self cachedFileNameForKey:url];
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
    
    
    return [NSData dataWithContentsOfFile:databasePath];
    
}


-(NSMutableString*)basicAdvData
{
    
    long seconds = time(0);
    //BM4Log(@"second:%ld",seconds);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",ADV_APP_ID,lvRequestID,ADV_SECRET_KEY];
    
    NSString* lvChecksum = [self MD5:lvBaseChecksum];
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:@""];
    [sDataUrl appendString: @"game_id="];
    [sDataUrl appendString:GAME_ID];
    [sDataUrl appendString: @"&request_id="];
    [sDataUrl appendString:lvRequestID];
    [sDataUrl appendString: @"&checksum="];
    [sDataUrl appendString:lvChecksum];
    [sDataUrl appendString: @"&game_version="];
    [sDataUrl appendString:version];
    [sDataUrl appendString: @"&adv_app_id="];
    [sDataUrl appendString:ADV_APP_ID];
    
    if (self.mUserID != nil && ![self.mUserID isEqualToString:@""]) {
        [sDataUrl appendString: @"&user_id="];
        [sDataUrl appendString:self.mUserID];
    }
    
    return sDataUrl;
}

-(void) LogClick:(AdvItem*)advCurrent
{
    NSURL *url = [NSURL URLWithString:@"http://advnetwork.weplay.vn/adv_v2/count_adv_clicks.php"];
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    [request setHTTPMethod:@"POST"];
    
    NSMutableString *sDataUrl = [self basicAdvData];
    
    [sDataUrl appendString: @"&target_id="];
    [sDataUrl appendString:advCurrent.target_id];
    
    BM4Log(@"%@",sDataUrl);
    
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self handleLogClick:response withData:data withError:connectionError];
                           }];
}

- (void)handleLogClick:(NSURLResponse *)request withData:(NSData*) data withError:(NSError*)connectionError
{
    if(data == nil)
    {
        return;
    }
    
    NSError* error;
    NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
    
    BM4Log(@"%@",[lvObjUserInfo description]);
    
}

-(void) LogView:(AdvItem*)advCurrent
{
    NSURL *url = [NSURL URLWithString:@"http://advnetwork.weplay.vn/adv_v2/count_adv_views.php"];
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    [request setHTTPMethod:@"POST"];
    
    NSMutableString *sDataUrl = [self basicAdvData];
    
    [sDataUrl appendString: @"&target_id="];
    [sDataUrl appendString:advCurrent.target_id];
    
    BM4Log(@"%@",sDataUrl);
    
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self handleLogView:response withData:data withError:connectionError];
                           }];
}


- (void)handleLogView:(NSURLResponse *)request withData:(NSData*) data withError:(NSError*)connectionError
{
    if(data == nil)
    {
        return;
    }
    
    NSError* error;
    NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
    
    BM4Log(@"%@",[lvObjUserInfo description]);
    
}


-(AdvItem*)getOfflineFullAdv
{
    AdvItem* ret = nil;
    if(self.advArrayOffline != nil && self.advArrayOffline.count > 0)
    {
        for (AdvItem* itemadv in self.advArrayOffline) {
            if([itemadv.adv_type isEqualToString:@"interstitial"])
            {
                if(itemadv.status == 1){
                    ret = itemadv;
                    break;
                }
            }
        }
    }
    
    return ret;
}

-(BOOL)checkOfflineFullAdvExists
{
    BOOL ret = NO;
    if(self.advArrayOffline != nil && self.advArrayOffline.count > 0)
    {
        for (AdvItem* itemadv in self.advArrayOffline) {
            if([itemadv.adv_type isEqualToString:@"interstitial"])
            {
                if(itemadv.status == 1){
                    ret = YES;
                    break;
                }
            }
        }
    }
    
    return ret;
}

-(AdvItem*)getOfflineBanner
{
    AdvItem* ret = nil;
    if(self.lastofflineBanner >= self.advArrayOffline.count){
        self.lastofflineBanner = 0;
    }
    
    if(self.advArrayOffline != nil && self.advArrayOffline.count > 0)
    {
        for (int i = self.lastofflineBanner+1; i < self.advArrayOffline.count; i++) {
            AdvItem* itemadv1 = [self.advArrayOffline objectAtIndex:i];
            if([itemadv1.adv_type isEqualToString:@"banner"]){
                if(itemadv1.status == 1){
                    self.lastofflineBanner = i;
                    ret = itemadv1;
                    break;
                }
            }
        }
        if(ret != nil)
            return ret;
        
        for (int i = 0; i < self.advArrayOffline.count; i++) {
            AdvItem* itemadv1 = [self.advArrayOffline objectAtIndex:i];
            if([itemadv1.adv_type isEqualToString:@"banner"]){
                if(itemadv1.status == 1){
                    self.lastofflineBanner = i;
                    ret = itemadv1;
                    break;
                }
            }
        }
        
    }
    
    return ret;
}

-(BOOL)checkOfflineBannerExists
{
    BOOL ret = NO;
    if(self.advArrayOffline != nil && self.advArrayOffline.count > 0)
    {
        for (AdvItem* itemadv in self.advArrayOffline) {
            if([itemadv.adv_type isEqualToString:@"banner"]){
                if(itemadv.status == 1){
                    ret = YES;
                    break;
                }
            }
        }
    }
    
    return ret;
}


-(BOOL)checkShowFullAdv
{
    int mod = self.level_mod_to_adv;
    
    if(self.is_blocked == 1)
    {
        mod = 2;
    }
    
    
    if (self.levelCount == 2 ) {
        return YES;
    }else if(self.levelCount >2 && (self.levelCount-1)%mod == 0){
        return YES;
    }else{
        return NO;
        
    }
    
    
}


-(void) updateRubyViewAdd
{
    
    if(self.mUserID==nil || [self.mUserID isEqualToString:@""])
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:UPDATE_RUBY_URL];
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    
    
    NSMutableString *sDataUrl = [self basicPostData];
    [sDataUrl appendFormat:@"&action=%@",ACTION_BUY_ITEM];
    [sDataUrl appendFormat:@"&ruby=%ld",(long)self.mScore];
    
    [sDataUrl appendFormat:@"&currtime=%ld",(long)time(0)];
    
    [sDataUrl appendFormat:@"&session_id=%@",self.mSessionID];
    [sDataUrl appendFormat:@"&user_id=%@",self.mUserID];
    [sDataUrl appendFormat:@"&level_id=%ld",(long)self.mLevel];
    
    BM4Log(@"%@",sDataUrl);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
#ifdef DEBUG
                               if(data != nil){
                                   NSString* newStr = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                                   BM4Log(@"updateRubyViewAdd response: %@ \n",newStr);
                               }
                               
#endif
                               
                           }];
    
    
    
}


- (void)winlevel
{
    
    if(self.mUserID==nil || [self.mUserID isEqualToString:@""])
    {
        return;
    }
    
    NSMutableString *sDataUrl = [self basicPostData];
    
    [sDataUrl appendFormat:@"&ruby=%ld",(long)self.mScore];
    [sDataUrl appendFormat:@"&curr_level=%ld",(long)self.mLevel];
    
    [sDataUrl appendFormat:@"&session_id=%@",self.mSessionID];
    [sDataUrl appendFormat:@"&user_id=%@",self.mUserID];
    [sDataUrl appendFormat:@"&level_id=%ld",(long)self.mLevel];
    
    
    currentUrl = [NSString stringWithFormat:@"%@?%@",WIN_LEVEL_URL,sDataUrl];
    
    BM4Log(@"%@",currentUrl);
    
    
    NSURL *url = [NSURL URLWithString:currentUrl];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    
    [request setHTTPMethod:@"GET"];
    
   
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               if(data != nil && data.length > 0){
                                   NSString* newStr = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                                   BM4Log(@"win response: %@ \n",newStr);
                               }
                               
                           }];
    
    
    
    
}


-(NSMutableURLRequest*)createGetUserDataRequest
{
    NSURL *url = [NSURL URLWithString:USER_DATA_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    NSMutableString *sDataUrl = [self basicPostData];
    
    [sDataUrl appendFormat:@"&session_id=%@",self.mSessionID];
    [sDataUrl appendFormat:@"&user_id=%@",self.mUserID];
    
    [sDataUrl appendFormat:@"&action=user_info"];
    [sDataUrl appendFormat:@"&ruby=%ld",(long)self.mScore];
    [sDataUrl appendFormat:@"&curr_level=%ld",(long)self.mLevel];
    
    BM4Log(@"%@",sDataUrl);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
    
}


- (void)openchar
{
    
    if(self.mUserID==nil || [self.mUserID isEqualToString:@""])
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:OPEN_CHAR_URL];
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL] ];
    
    NSMutableString *sDataUrl = [self basicPostData];
    [sDataUrl appendFormat:@"&action=%@",ACTION_BUY_ITEM];
    [sDataUrl appendFormat:@"&ruby=%ld",(long)self.mScore];
    [sDataUrl appendFormat:@"&session_id=%@",self.mSessionID];
    [sDataUrl appendFormat:@"&user_id=%@",self.mUserID];
    [sDataUrl appendFormat:@"&level_id=%ld",(long)self.mLevel];
    
    BM4Log(@"%@",sDataUrl);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sDataUrl dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               if(data != nil){
                                   NSString* newStr = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                                   BM4Log(@"openchar response: %@ \n",newStr);
                               }
                               
                               
                               
                           }];
    
}


-(NSString*)getItunesLink
{
#ifdef BATCHU2
    return kAppStoreAddress2;
#else
    return kAppStoreAddress1;
#endif
}


-(void)increaseFullPageAdsCount
{
    self.miniAppFullPageAdsCount++;
    [self saveLocalData];
}

-(BOOL)needToShowFullPageAds
{
    if(self.miniAppFullPageAdsCount >= 5)
        return YES;
    else
        return NO;
}
-(void)resetFullPageAdsCount
{
    self.miniAppFullPageAdsCount = 0;
    [self saveLocalData];
}


//-(NSString*)getURL:(NSString*)url
//{
//    return [NSString stringWithFormat:@"%@%@",BASEURL,url];
//}

@end
