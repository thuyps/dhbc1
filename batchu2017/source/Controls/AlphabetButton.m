//
//  AlphabetButton.m
//  batchu
//
//  Created by Pham Quang Dung on 10/10/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "AlphabetButton.h"
#import "CustomContext.h"
#import "WPUtils.h"
#import "config.h"

@implementation AlphabetButton

@synthesize alphabet;
@synthesize alphabetLb;
@synthesize state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.alphabet = nil;
 
    }
    return self;
}

-(id)createAnswerAtIndex:(int)index withPosY:(CGFloat)posY
{
    CustomContext *mContext = [CustomContext getInstance];
    
    
    self.mIndex = index;
    
    UIImage* img = [UIImage imageNamed:GAME_SCREEN_BATCHU_ANSWER_HOLDER];
    CGFloat w = screenW/640*img.size.width;
    CGFloat h = screenW/640*img.size.width;
    
    w = 0.96*w;
    h = 0.96*h;
    
    if(IPAD == IDIOM){
        w = 0.7*w;
        h = 0.7*h;
    }else if(screenH < 490){
        w = 0.9*w;
        h = 0.9*h;
    }
    
    
    if(mContext.mSuggestionArray.count > 14){
        w = w*95/100;
        h = h*95/100;
    }else if(mContext.mSuggestionArray.count > 14){
        w = w*90/100;
        h = h*90/100;
    }
    
    CGFloat spaceV = (screenW/640*[UIImage imageNamed:@"imgtest"].size.width - 8 * w)/7;
    
    if(IDIOM == IPAD){
        spaceV = 0.7*spaceV;
    }
    
    CGFloat spaceH = 10*SCALE;
    
    if (IDIOM == IPAD)
    {
        spaceH = 4*SCALE;
    }else if (screenH < 490){
        spaceH = 4*SCALE;
    }

    int col,row;
    
    if(index>7){
        posY += h+spaceH;
        col = index%8;
        row = 1;
    }else{
        col = index;
        row = 0;
    }
    
    
    int len = (int)mContext.mAnswerStringBodau.length;
    

    if(row==1){
        len = len%8;
    }else{
        if(len>8)
            len = 8;
    }
    
    if(len==0){
        len = 8;
    }
    
    CGFloat left_margin = ([UIScreen mainScreen].bounds.size.width - w*len - spaceV*(len - 1))/2;

 
    CGFloat expand = SCALE*7*w/100;
    CGFloat new_X = left_margin + col*(w + spaceV) - expand;
    CGFloat new_Y = posY - expand;
    CGFloat new_W = w + 2*expand;
    CGFloat new_H = h + 2*expand;
    
   
    
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
    
    
    self.mIndex = index;
    
    UIImage* img = [UIImage imageNamed:GAME_SCREEN_BATCHU_OFFER_HOLDER];
    
    CGFloat w =  screenW/640*img.size.width;
    CGFloat h = screenW/640*img.size.height;

    CGFloat spaceH = 10*SCALE;
    
    if(IPAD == IDIOM){
        w = 0.7*w;
        h = 0.7*h;
    }else if(screenH < 490){
        w = 0.9*w;
        h = 0.9*h;
        spaceH = 4*SCALE;
    }
    
    
    
    
     if(mContext.mSuggestionArray.count > 14 ){
        w = w*90/100;
        h = w = w*90/100;
        spaceH = 5*SCALE;
    }
    
    float margin = 3*SCALE;

    CGFloat spaceV = ([UIScreen mainScreen].bounds.size.width - 2*margin - 7*w)/8;
    
    
    
    int startY = posY1;
    
    if(mContext.mSuggestionArray.count > 14)
    {
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
   
   
    
    CGFloat expand = SCALE*8*w/100;
    CGFloat new_X = margin + spaceV + col*(w+spaceV) - expand;
    CGFloat new_Y = startY - expand;
    CGFloat new_W = w + 2*expand;
    CGFloat new_H = h + 2*expand;
    
    
    [self initWithFrame:CGRectMake(new_X,new_Y, new_W,new_H)];
    self.backgroundColor = CLEAR_COLOR;
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(expand, expand, w, h)] ;
    [self addSubview:self.container];
    
    
    UIImageView* imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)] ;
    
    imgBG.image = img;
    
    [self.container addSubview:imgBG];
    
    
    
    self.alphabet = @"";
    
    [self addOfferTitleLabel];
   
    self.bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, new_W, new_H)] ;
    self.bt.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bt];
    return self;
}


#define OFFER_FONT @"Bold"
#define ANSWER_FONT @"Arial-BoldMT"

- (void) addAlphabetTitleLabel {
    self.alphabetLb = [[UILabel alloc] initWithFrame:CGRectMake(0,SCALE,self.container.frame.size.width,self.container.frame.size.height)] ;
    self.alphabetLb.text = [self.alphabet capitalizedString];
    self.alphabetLb.textColor = self.textColor;
    self.alphabetLb.backgroundColor = [UIColor clearColor];
    self.alphabetLb.textAlignment = NSTextAlignmentCenter;
    
    
    
    
    if(IPAD == IDIOM){
        self.alphabetLb.font = [WPUtils createFont:ANSWER_FONT Size:0.8*20*SCALE];
    }else if(screenH < 490){
        self.alphabetLb.font = [WPUtils createFont:ANSWER_FONT Size:0.9*20*SCALE];
    }else{
        self.alphabetLb.font = [WPUtils createFont:ANSWER_FONT Size:20*SCALE];
        
    }
    
    self.alphabetLb.userInteractionEnabled = NO;
    self.alphabetLb.exclusiveTouch = NO;
   [self.container addSubview:self.alphabetLb];
}

-(UILabel*) getAlphabetTitleLabel
{
    return self.alphabetLb;
}




- (void) addOfferTitleLabel {
    self.alphabetLb = [[UILabel alloc] initWithFrame:CGRectMake(0,SCALE,self.container.frame.size.width,self.container.frame.size.height)] ;
    self.alphabetLb.text = [self.alphabet capitalizedString];
    self.alphabetLb.textColor = [UIColor blackColor];
    self.alphabetLb.backgroundColor = [UIColor clearColor];
    self.alphabetLb.textAlignment = NSTextAlignmentCenter;
    

    if(IPAD == IDIOM){
       self.alphabetLb.font = [WPUtils createFont:OFFER_FONT Size:0.8*20*SCALE];
    }else if(screenH < 490){
        self.alphabetLb.font = [WPUtils createFont:OFFER_FONT Size:0.9*20*SCALE];
    }else{
        self.alphabetLb.font = [WPUtils createFont:OFFER_FONT Size:20*SCALE];
    }
    
    
    
    self.alphabetLb.userInteractionEnabled = NO;
    self.alphabetLb.exclusiveTouch = NO;
  
    [self.container addSubview:self.alphabetLb];
}




- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.bt addTarget:target action:action forControlEvents:controlEvents];
}



+(UIView*)createWinanswer:(NSString*)ch
{
    UIImage* img = [UIImage imageNamed:GAME_SCREEN_BATCHU_ANSWER_HOLDER];
    
    CGFloat w =  screenW/640*img.size.width;
    CGFloat h = screenW/640*img.size.height;
    
    CGFloat spaceH = 10*SCALE;
    
    if(IPAD == IDIOM){
        w = 0.7*w;
        h = 0.7*h;
    }else if(screenH < 490){
        w = 0.9*w;
        h = 0.9*h;
        spaceH = 4*SCALE;
    }

    UIImageView* imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)] ;
    
    imgBG.image = img;
  
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    
    [container addSubview:imgBG];
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,SCALE,w,h - SCALE)] ;
    label.text = [ch capitalizedString];
    label.textColor = [WPUtils colorFromString:@"ff00ff"];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if(IPAD == IDIOM){
        label.font = [WPUtils createFont:ANSWER_FONT Size:0.8*20*SCALE];
    }else if(screenH < 490){
        label.font = [WPUtils createFont:ANSWER_FONT Size:0.9*20*SCALE];
    }else{
        label.font = [WPUtils createFont:ANSWER_FONT Size:20*SCALE];
        
    }
    [container addSubview:label];

    
    return container;
}


@end
