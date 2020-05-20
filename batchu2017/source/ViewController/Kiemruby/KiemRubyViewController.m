
#import "config.h"

#import "WPUtils.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

#import "AppDelegate.h"
#import "KiemRubyViewController.h"

#import "xOutputStream.h"

#import "AppInfo.h"
#import <CommonCrypto/CommonDigest.h>
#import "xInputStream.h"

@interface KiemRubyViewController ()

@end


@implementation KiemRubyViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self addBackGroundScaleFill:@"kiemruby_bg_640"];
    
    UIButton*closebutton = [[UIButton alloc] initWithFrame:CGRectMake( 0,0, 50*SCALE, 50*SCALE)];
    
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50 ,50)];
    
    imgview.image = [UIImage imageNamed:@"close"];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    
     [WPUtils addView:imgview withPoint:CGPointMake(50*SCALE/2, 50*SCALE/2) withAlignment:CustomAlignMidleCenter toView:closebutton];
    
    
    [closebutton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    [WPUtils addView:closebutton withPoint:CGPointMake(screenW-10*SCALE, 0) withAlignment:CustomAlignTopRight toView:self.view];
   
    
    self.applist = [[NSMutableArray alloc] init];
    
    [self requestAppList];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW - 40*screenW/320, screenH - 160*screenH/480)];
                      
                      //CGRectMake(280, 125*SCALE, screenW-40*SCALE , screenH - 160*screenH/480)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 84;
    
    if(IDIOM == IPAD){
        self.tableView.rowHeight = 160;
    }
   
    [WPUtils addView:self.tableView withPoint:CGPointMake(screenW/2, screenH - 40*SCALE) withAlignment:CustomAlignBottomCenter toView:self.view];
    
    
    UIButton* kiemruby_button_refresh = [WPUtils createButtonFromImage:@"kiemruby_button_refresh" Text:nil];
    [WPUtils addView:kiemruby_button_refresh withPoint:CGPointMake(screenW, screenH) withAlignment:CustomAlignBottomRight toView:self.view];
    
    [kiemruby_button_refresh addTarget:self action:@selector(buttonRefreshAction) forControlEvents:UIControlEventTouchUpInside];
    
}


-(NSMutableString*)getInstallationString
{
    NSArray* oldArray = [self loadAppInfo];
    
    NSArray* array = [self.mContext.installation_urlscheme componentsSeparatedByString:@";"];
    NSMutableString * ret =  [[NSMutableString alloc] initWithString:@""];
    for (NSString* str in array) {
        if (str!= nil && ![str isEqualToString:@""]){
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
           {
               AppInfo* oldapp = [self getoldAppByScheme:oldArray byScheme:str];
               
               if(oldapp!= nil && (oldapp.status == 200 || oldapp.status == 2)){
                   if(ret.length > 2){
                       [ret appendFormat:@";%@",str];
                   }else{
                       [ret appendFormat:@"%@",str];
                   }
               }
               
           }
        }
        
    }
 
    return ret;
    
}

-(void) requestAppList
{
    
        long seconds = time(0);
        
        NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
        
        NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
        
        NSString* lvChecksum = [self.mContext MD5:lvBaseChecksum];
        
        NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:REQUIRE_INSTALL];
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
    
    
    [sDataUrl appendString: @"&installation="];
   
    NSMutableString * str = [self getInstallationString];
    
    [sDataUrl appendString:str];
   
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
                 
                 NSError* error;
                 NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                                JSONObjectWithData:data
                                                options:kNilOptions
                                                error:&error];
                 
                 BM4Log(@"%@",[lvObjUserInfo description]);
                 
                 NSArray* oldArray = [self loadAppInfo];
                 
                 NSObject* ob = [lvObjUserInfo objectForKey:@"installation"];
                 NSArray* installations;
                 [self.applist removeAllObjects];
                 if(ob != nil && [ob isKindOfClass:[NSArray class]]){
                     installations = (NSArray*)ob;
                     for (NSDictionary* dic in installations) {
                         AppInfo* app = [[AppInfo alloc] init];
                         app.addition_ruby = [[dic objectForKey:@"addition_ruby"] intValue];
                         app.status = [[dic objectForKey:@"status"] intValue];
                         app.icon_url = [dic objectForKey:@"icon_url"];
                         app.install_url = [dic objectForKey:@"install_url"];
                         app.name = [dic objectForKey:@"name"];
                         app.urlscheme = [dic objectForKey:@"urlscheme"];
                       
                         AppInfo* oldapp = [self getoldAppByScheme:oldArray byScheme:app.urlscheme];
                         
                         if(oldapp!= nil && oldapp.status == 100 )
                          {
                                app.status = 100;
                          }
                            
                         
                         if(oldapp!= nil && oldapp.status == 200 && app.status != 2)
                         {
                             app.status = 200;
                         }
                         
                         [self.applist addObject:app];
                     }
                 }
                 [self.tableView reloadData];
                
             }else{
                 [WPUtils alert:sConnectionError FromController:self];
             }
             
             
         }];
    
        
    }

-(BOOL)isInstalled:(AppInfo*)app
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:app.urlscheme]])
    {
        return YES;
    }else{
        return NO;
    }
}





-(void)sendOpenApp:(AppInfo*)app
{
    
    long seconds = time(0);
    
    NSString* lvRequestID = [NSString stringWithFormat:@"%ld",seconds];
    
    NSString* lvBaseChecksum = [NSString stringWithFormat:@"%@%@%@",GAME_ID,lvRequestID,SECRET_KEY];
    
    NSString* lvChecksum = [self.mContext MD5:lvBaseChecksum];
    
    NSMutableString* sDataUrl = [[NSMutableString alloc] initWithString:OPEN_APP];
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
    
    
    [sDataUrl appendString: @"&url_scheme="];
    
    [sDataUrl appendString:app.urlscheme];
    
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
             
             NSError* error;
             NSDictionary *lvObjUserInfo = [NSJSONSerialization
                                            JSONObjectWithData:data
                                            options:kNilOptions
                                            error:&error];
             
             BM4Log(@"%@",[lvObjUserInfo description]);
             
         }else{
             [WPUtils alert:sConnectionError FromController:self];
         }
         
         
     }];
    
    
}

-(AppInfo*)getoldAppByScheme:(NSArray*)oldArray byScheme:(NSString*)urlscheme
{
    AppInfo* ret = nil;
    for (AppInfo* app in oldArray) {
        if([app.urlscheme isEqualToString:urlscheme]){
            ret = app;
            break;
        }
    }
    return ret;
}

-(void) close:(UIButton*)sender
{
    [sender setEnabled:NO];
 
    
    [self dismissViewControllerAnimated:NO completion:^(){
     [[NSNotificationCenter defaultCenter] postNotificationName:@"delayReloadRuby" object:self];
    }];
    
   
}


-(void)buttonRefreshAction
{
    [self.applist removeAllObjects];
    [self.tableView reloadData];
    [self requestAppList];
}



#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.applist.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppInfo* app = [self.applist objectAtIndex:indexPath.row];

    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:app.urlscheme]])
    {
        if(app.status == 100 ){
            app.status = 200;
            [self saveAppInfo];
            [self sendOpenApp:app];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.urlscheme]];
        return;
    }
    
    if(app.status == 0 ){
        app.status = 100;
        //save app info
        [self saveAppInfo];
        
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.install_url]];
        return;
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app.install_url]];
    }
    
    
   
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier1 = @"Cell1";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    AppInfo* app = [self.applist objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];

    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
   // if(app.status == 0){
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiemruby_row_bg"]];
  
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    for (UIView* view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20*screenW/320, 15*tableView.rowHeight/84, 54*tableView.rowHeight/84,54*tableView.rowHeight/84)] ;
    iconView.backgroundColor = [UIColor clearColor];
    
    //NSURL* url = [NSURL URLWithString:app.icon_url];
    
    UIImage* placeHolder;
    
    NSData *data = nil;
    
        NSString * filename = [self.mContext cachedFileNameForKey:app.icon_url];
        NSString *docsDir;
        NSArray *dirPaths;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *fullpath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
        
        data = [NSData dataWithContentsOfFile:fullpath];
    
    if(data != nil){
        
        placeHolder = [UIImage imageWithData:data];
        
    }else{
        
        placeHolder = [UIImage imageNamed:@"icon120"];
        [self downloadIcon:app.icon_url];
        NSLog(@"%@",app.icon_url);
        
    }
    
    
    iconView.image = placeHolder;
    
    [cell.contentView addSubview:iconView];
    
    UILabel* l;
    if(app.status == 0 && ![self isInstalled:app]){
        l = [[UILabel alloc] initWithFrame:CGRectMake(80*screenW/320,20*tableView.rowHeight/84, 180*screenW/320, 20*tableView.rowHeight/84)];
        l.backgroundColor = [UIColor clearColor];
        l.numberOfLines = 1;
        l.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        l.text = app.name;
        l.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:l];
        
        l = [[UILabel alloc] initWithFrame:CGRectMake(80*screenW/320, 42*tableView.rowHeight/84, 60*screenW/320, 30*tableView.rowHeight/84)];
        l.backgroundColor = [UIColor clearColor];
        l.numberOfLines = 1;
        l.textAlignment = NSTextAlignmentRight;
        
        l.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
        l.textColor = [WPUtils colorFromString:@"ffcd0f"];
        l.text = [NSString stringWithFormat:@"+%d",app.addition_ruby];
        [cell.contentView addSubview:l];
        
        UIView* temp = [WPUtils createViewFromImage:@"kiemruby_download" Scale:tableView.rowHeight/84.0];
        
        [WPUtils addView:temp withPoint:CGPointMake( screenW - 40*screenW/320-10*SCALE, 86*tableView.rowHeight/84.0)  withAlignment:CustomAlignBottomRight toView:cell.contentView];
        
       
        
        
        temp = [WPUtils createViewFromImage:@"kiemruby_ruby" Scale:tableView.rowHeight/84];
        [WPUtils addView:temp withPoint:CGPointMake(143*screenW/320, 45*tableView.rowHeight/84)  withAlignment:CustomAlignTopLeft toView:cell.contentView];
        
        
        
    }else{
    
        l = [[UILabel alloc] initWithFrame:CGRectMake(80*screenW/320, 20*tableView.rowHeight/84, 180*screenW/320, 20*tableView.rowHeight/84)];
        l.backgroundColor = [UIColor clearColor];
        l.numberOfLines = 1;
        l.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        l.text = app.name;
        l.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:l];
        
        l = [[UILabel alloc] initWithFrame:CGRectMake(80*screenW/320, 42*tableView.rowHeight/84, 180*screenW/320, 20*tableView.rowHeight/84)];
        l.backgroundColor = [UIColor clearColor];
        l.numberOfLines = 1;
        l.font = [UIFont fontWithName:@"ArialMT" size:12];
        l.textColor = [WPUtils colorFromString:@"ff002c"];
        [cell.contentView addSubview:l];
        
        if (app.status == 100) {
            if([self isInstalled:app])
            {
                l.text = @"Mở app để nhận Ruby";
            }else{
                l.text = @"Đang cài đặt";
            }
        }else if(app.status == 200 || app.status == 2 ){
            l.text = @"Đã cài đặt";
        }else if(app.status == 0 && [self isInstalled:app]){
            l.text = @"Đã cài đặt";
        }else
        {
            l.text = @"Không xác định";
        }
        
    }
    
    
    return cell;
    
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
         
         NSString * filename = [self.mContext cachedFileNameForKey:urlString];
         
         NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:filename]];
         
         [data writeToFile:databasePath atomically:YES];
         
         [NSTimer scheduledTimerWithTimeInterval:0.1 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
     }];
    
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

-(NSString*)filename
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:@"applist.bin"];
    return filePathAndDirectory;
}

-(void) saveAppInfo
{
    @try {
        xOutputStream* outputStream = [[xOutputStream alloc] init:1024];
        
        [outputStream writeInt:(int)self.applist.count];
        
        for (int i = 0; i < self.applist.count; i++) {
            AppInfo* app = [self.applist objectAtIndex:i];
            [outputStream writeInt:app.status];
            [outputStream writeInt:app.addition_ruby];
            [outputStream writeString:app.name];
            [outputStream writeString:app.install_url];
            [outputStream writeString:app.urlscheme];
            [outputStream writeString:app.icon_url];
        }
        
        [outputStream writeToFile:[self filename]];
        
        
        
    }
    @catch (NSException *exception) {
        BM4Log(@"%@",[exception reason]);
    }
    @finally {
        
    }
    
 }

- (NSMutableArray*)loadAppInfo
{
    
    
    @try
    {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        xInputStream* inputStream = [xInputStream initFromFile:[self filename]];
        if (inputStream != nil) {
            int count = [inputStream readInt];
            for (int i = 0; i< count; i++) {
                AppInfo* app = [[AppInfo alloc] init];
                app.status = [inputStream readInt];
                app.addition_ruby = [inputStream readInt];
                app.name = [inputStream readString];
                app.install_url = [inputStream readString];
                app.urlscheme = [inputStream readString];
                app.icon_url = [inputStream readString];
                [array addObject:app];
            }
        }
        return  array;
        
    }
    @catch (NSException* ex)
    {
        
        return nil;
    }
    
    
    
    
}

-(void)dealloc
{
    [self.applist removeAllObjects];
   
    
}

@end
