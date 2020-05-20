//
//  AlphabetButton.m
//  batchu
//
//  Created by Pham Quang Dung on 10/10/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "AlphabetButton1.h"
#import "CustomContext.h"
#import "WPUtils.h"
#import "config.h"


@implementation AlphabetButton1


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alphabet = nil;
        
        self.scale = [UIScreen mainScreen].bounds.size.width/320;
        if(self.scale > [UIScreen mainScreen].bounds.size.height/480){
            self.scale = [UIScreen mainScreen].bounds.size.height/480;
        }
        
    }
    return self;
}

-(id)createAnswerAtIndex:(int)index withPosY:(CGFloat)posY withAdv:(BOOL)advExists
{
    CustomContext *mContext = [CustomContext getInstance];
    
    int small_height = 1;
    
    self.scale = [UIScreen mainScreen].bounds.size.width/320;
    
    if (self.scale > [UIScreen mainScreen].bounds.size.height/480)
    {
        self.scale = [UIScreen mainScreen].bounds.size.height/480;
        small_height = 2;
    }
    
    if([UIScreen mainScreen].bounds.size.height == 480 && [UIScreen mainScreen].bounds.size.width == 320){
        small_height = 3;
    }
    
    self.mIndex = index;
    
    UIImage* img = [UIImage imageNamed:@"black_placeholder"];
    
    float w =  self.scale*img.size.width/2;
    float h = self.scale*img.size.height/2;
    
    if(mContext.mSuggestionArray.count > 14 && small_height ==  3){
        w = w*95/100;
        h = h*95/100;
    }else if(mContext.mSuggestionArray.count > 14 && small_height ==  2){
        w = w*90/100;
        h = h*90/100;
    }
    
    CGFloat spaceV = (self.scale*[UIImage imageNamed:@"imgtest"].size.width/2 - 8 * w)/7;
    
    CGFloat spaceH = 10*self.scale;
    
    if (small_height == 2)
    {
        spaceH = 4*self.scale;
    }
    
    int col,row;
    
    //if((mContext.mAnswerStringBodau.length<=8 || [UIScreen mainScreen].bounds.size.height > 490) && mContext.show_banner_in_game == 1){
    if(advExists){
        if([UIScreen mainScreen].bounds.size.height > 490){
            if(index>7){
                posY += h+spaceH;
                col = index%8;
                row = 1;
            }else{
                col = index;
                row = 0;
            }
        }else{
            if([UIScreen mainScreen].bounds.size.height > 490)
            {
                posY += h+spaceH;
            }
            col = index;
            row = 0;
        }
        
    }else{
        if(index>7){
            posY += h+spaceH;
            col = index%8;
            row = 1;
        }else{
            col = index;
            row = 0;
        }
    }
        
    
    int len = (int)mContext.mAnswerStringBodau.length;
    
    
    if(row==1){
        len = len%8;
    }else{
        if(len>8)
            len = 8;
    }
    
    
    CGFloat left_margin = ([UIScreen mainScreen].bounds.size.width - w*len - spaceV*(len - 1))/2;
    
    
    //dasdasdsa
    
    CGFloat expand = self.scale*7*w/100;
    CGFloat new_X = left_margin + col*(w + spaceV) - expand;
    CGFloat new_Y = posY - expand;
    CGFloat new_W = w + 2*expand;
    CGFloat new_H = h + 2*expand;
    
    //[self initWithFrame:CGRectMake(left_margin + col*(w + spaceV) , posY, w,h)];
    
    [self initWithFrame:CGRectMake(new_X,new_Y, new_W,new_H)];
    self.backgroundColor = [UIColor clearColor];
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(expand, expand, w, h)] ;
    [self addSubview:self.container];
    
    UIImageView* imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)] ;
    
    imgBG.image = img;
    
    [self.container addSubview:imgBG];
    
 
    self.alphabet = @"";
    self.textColor = [UIColor greenColor];
    [self addAlphabetTitleLabel];
    
    
    
    self.bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, new_W, new_H)] ;
    self.bt.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bt];
    
    return self;
}


-(id)createOfferAtIndex:(int)index withPosY:(CGFloat)posY1
{
    CustomContext *mContext = [CustomContext getInstance];
    
    int small_height = 1;
    self.scale = [UIScreen mainScreen].bounds.size.width/320;
    
    if(self.scale > [UIScreen mainScreen].bounds.size.height/480){
        self.scale = [UIScreen mainScreen].bounds.size.height/480;
        small_height = 2;
    }
    
    if([UIScreen mainScreen].bounds.size.height == 480 && [UIScreen mainScreen].bounds.size.width == 320){
        small_height = 3;
    }
    
    self.mIndex = index;
    
    UIImage* img = [UIImage imageNamed:@"white_placeholder"];
    
    float w =  self.scale*img.size.width/2;
    float h = self.scale*img.size.height/2;
    
    if(mContext.mSuggestionArray.count > 14 && small_height ==  3){
        w = w*95/100;
        h = w = w*95/100;
        
        
    }else if(mContext.mSuggestionArray.count > 14 && small_height ==  2){
        w = w*90/100;
        h = w = w*90/100;
    }
    
    float margin = 3*self.scale;
    
    CGFloat spaceV = ([UIScreen mainScreen].bounds.size.width - 2*margin - 7*w)/8;
    
    CGFloat spaceH = 10*self.scale;
    
    int startY = posY1;
    
    if(mContext.mSuggestionArray.count > 14)
    {
        if (small_height >= 2)
        {
            spaceH = 5*self.scale;
        }
        
        if ([UIScreen mainScreen].bounds.size.height < (posY1 + 3*(h+spaceH))){
            startY = [UIScreen mainScreen].bounds.size.height - 3*(h+spaceH);
        }
        
    }
    
    
    int col = 0;
    
    
    if(index>13){
        startY += 2*(h+spaceH);
        col = index%7;
    }else if(index > 6){
        startY += h+spaceH;
        col = index%7;
    }else{
        col = index;
    }
    
    CGFloat expand = self.scale*8*w/100;
    CGFloat new_X = margin + spaceV + col*(w+spaceV) - expand;
    CGFloat new_Y = startY - expand;
    CGFloat new_W = w + 2*expand;
    CGFloat new_H = h + 2*expand;
    
   // [self initWithFrame:CGRectMake(margin + spaceV + col*(w+spaceV), startY, w,h)];
    
     [self initWithFrame:CGRectMake(new_X,new_Y, new_W,new_H)];
     self.backgroundColor = [UIColor clearColor];
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(expand, expand, w, h)] ;
    [self addSubview:self.container];
    
    UIImageView* imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)] ;
    
    imgBG.image = img;
    
    [self.container addSubview:imgBG];
    
   // [self setBackgroundImage:img forState:UIControlStateNormal];
    
    self.alphabet = @"";
    
    [self addOfferTitleLabel];
    
    self.bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, new_W, new_H)] ;
    self.bt.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bt];
    return self;
}

/*
-(id)createOfferAtIndex1:(int)index withPosY:(CGFloat)posY
{
    int small_height = 1;
    self.scale = [UIScreen mainScreen].bounds.size.width/320;
    if(self.scale > [UIScreen mainScreen].bounds.size.height/480){
        self.scale = [UIScreen mainScreen].bounds.size.height/480;
        small_height = 2;
    }
    
    UIImage* img = [UIImage imageNamed:@"white_placeholder"];
    
    
    
    CGFloat left_margin;
    
    CGFloat space = self.scale*([UIImage imageNamed:@"imgtest"].size.width - img.size.width*7)/6;
    
    left_margin = ([UIScreen mainScreen].bounds.size.width - 7*self.scale*img.size.width/2 - 6*space/2)/2;
    
    
    
    
    int col,row;
    if(index>6){
        posY +=self.scale*img.size.height/2+space/2/small_height;
        col = index%7;
        // row = 1;
    }else{
        col = index;
        //  row = 0;k
    }
    
    
    
    [self initWithFrame:CGRectMake(left_margin + col*self.scale*img.size.width/2 + space*col/2, posY, self.scale*img.size.width/2,self.scale*img.size.height/2)];
    
    UIImageView* imgBG = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scale*img.size.width/2,self.scale*img.size.height/2)] autorelease];
    imgBG.image = img;
    [self addSubview:imgBG];
  //  [self setBackgroundImage:img forState:UIControlStateNormal];
    
    self.alphabet = @"";
    
    [self addOfferTitleLabel];

    return self;
}

*/


- (void) addAlphabetTitleLabel {
    self.alphabetLb = [[UILabel alloc] initWithFrame:CGRectMake(self.container.bounds.origin.x,self.container.bounds.origin.y+3*self.scale,self.container.bounds.size.width,self.container.bounds.size.height-4*self.scale)] ;
    self.alphabetLb.text = [self.alphabet capitalizedString];
    self.alphabetLb.textColor = self.textColor;
    self.alphabetLb.backgroundColor = [UIColor clearColor];
    self.alphabetLb.textAlignment = NSTextAlignmentCenter;
    
    self.alphabetLb.font = [UIFont fontWithName:@"Arial-BoldMT" size:self.scale*20.0];
    
    self.alphabetLb.userInteractionEnabled = NO;
    self.alphabetLb.exclusiveTouch = NO;
    [self.container addSubview:self.alphabetLb];
    
}

-(UILabel*) getAlphabetTitleLabel
{
    return self.alphabetLb;
}
- (void) addOfferTitleLabel {
    self.alphabetLb = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x,self.bounds.origin.y+3,self.bounds.size.width,self.bounds.size.height-4)] ;
    self.alphabetLb.text = [self.alphabet capitalizedString];
    self.alphabetLb.textColor = [UIColor blackColor];
    self.alphabetLb.backgroundColor = [UIColor clearColor];
    self.alphabetLb.textAlignment = NSTextAlignmentCenter;
    
    self.alphabetLb.font = [UIFont fontWithName:@"Bold" size:self.scale*23.0];
    
    self.alphabetLb.userInteractionEnabled = NO;
    self.alphabetLb.exclusiveTouch = NO;
    [self.container addSubview:self.alphabetLb];
    
}


-(id)createWinanswer:(NSString*)ch
{
    CustomContext *mContext = [CustomContext getInstance];
    UIImage* img = [UIImage imageNamed:@"black_placeholder"];
    
    [self initWithFrame:CGRectMake(0,0, img.size.width/2,img.size.height/2)];
    
    UIImageView* imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width/2,img.size.height/2)];
    imgBG.image = img;
    [self addSubview:imgBG];
    
    self.alphabet = ch;
    self.textColor = [WPUtils colorFromString:@"ff00ff"];
    //[self addAlphabetTitleLabel];
    
    self.alphabetLb = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x,self.container.bounds.origin.y+3*self.scale,self.bounds.size.width,self.bounds.size.height-4*self.scale)] ;
    self.alphabetLb.text = [self.alphabet capitalizedString];
    self.alphabetLb.textColor = self.textColor;
    self.alphabetLb.backgroundColor = [UIColor clearColor];
    self.alphabetLb.textAlignment = NSTextAlignmentCenter;
    
    self.alphabetLb.font = [UIFont fontWithName:@"Arial-BoldMT" size:self.scale*20.0];
    
    self.alphabetLb.userInteractionEnabled = NO;
    self.alphabetLb.exclusiveTouch = NO;
    [self addSubview:self.alphabetLb];
    
    return self;
}


- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.bt addTarget:target action:action forControlEvents:controlEvents];
}

@end
