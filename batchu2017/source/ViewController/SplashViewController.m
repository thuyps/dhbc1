//
//  SplashViewController.m
//  batchu
//
//  Created by dungpq on 10/1/15.
//  Copyright (c) 2015 Weplay.vn. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"


@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imgView.image = [UIImage imageNamed:@"splash"];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imgView];
    
    
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    l.text = [NSString stringWithFormat:@"Version: %@",version];
    l.font = [UIFont boldSystemFontOfSize:18*screenW/320];
#ifdef BATCHU2
    l.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
#else
    l.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
#endif
    [l sizeToFit];
    
    l.frame = CGRectMake(screenW/2-CGRectGetWidth(l.frame)/2, screenH-40*SCALE, CGRectGetWidth(l.frame), CGRectGetHeight(l.frame));
    
    [self.view addSubview:l];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gotoNext) userInfo:nil repeats:NO];

}

-(void)loadView
{
    [super loadView];
    
    
}



-(void)gotoNext
{
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
   
    
    [delegate.window setRootViewController:[[HomeViewController alloc] init]];
    
}

@end
