//
//  AlphabetButton.h
//  batchu
//
//  Created by Pham Quang Dung on 10/10/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface AlphabetButton1 : UIView
@property (nonatomic, strong) NSString *alphabet;
@property (nonatomic, strong) UILabel *alphabetLb;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) int state;
@property (weak) AlphabetButton1* ref;
@property () int mIndex;
@property () float scale;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton* bt;


-(id) createAnswerAtIndex:(int)index withPosY:(CGFloat)posY  withAdv:(BOOL)advExists;
-(id) createOfferAtIndex:(int)index withPosY:(CGFloat)posY;
-(void) addAlphabetTitleLabel;
-(UILabel*) getAlphabetTitleLabel;
-(id)createWinanswer:(NSString*)ch;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
