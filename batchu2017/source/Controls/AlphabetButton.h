//
//  AlphabetButton.h
//  batchu
//
//  Created by Pham Quang Dung on 10/10/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlphabetButton : UIView
@property (nonatomic, retain) NSString *alphabet;
@property (nonatomic, retain) UILabel *alphabetLb;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic) int state;
@property (assign) AlphabetButton* ref;
@property () int mIndex;
@property () float scale;
@property (nonatomic, retain) UIView *container;
@property (nonatomic, retain) UIButton* bt;

-(id) createAnswerAtIndex:(int)index withPosY:(CGFloat)posY;
-(id) createOfferAtIndex:(int)index withPosY:(CGFloat)posY;
-(void) addAlphabetTitleLabel;
-(UILabel*) getAlphabetTitleLabel;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

+(UIView*)createWinanswer:(NSString*)ch;
@end
