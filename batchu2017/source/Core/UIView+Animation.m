//
//  UIView+Animation.m
//  UIAnimationSamples
//
//  Created by Ray Wenderlich on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+Animation.h"


@implementation UIView (Animation)

- (void) moveTo:(CGPoint)destination duration:(float)secs delay:(float)delay option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:delay options:option
                     animations:^{
                         self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

- (void) downUnder:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
         animations:^{
             self.transform = CGAffineTransformRotate(self.transform, M_PI);
         }
         completion:nil];
}

- (void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option
{
    // first reduce the view to 1/100th of its original dimension
    CGAffineTransform trans = CGAffineTransformScale(view.transform, 0.01, 0.01);
    view.transform = trans;	// do it instantly, no animation
    [self addSubview:view];
    // now return the view to normal dimension, animating this tranformation
    [UIView animateWithDuration:secs delay:0.0 options:option
        animations:^{
            view.transform = CGAffineTransformScale(view.transform, 100.0, 100.0);
        }
        completion:nil];	
}

- (void) removeWithZoomOutAnimation:(float)secs option:(UIViewAnimationOptions)option
{
	[UIView animateWithDuration:secs delay:0.0 options:option
    animations:^{
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    }
    completion:^(BOOL finished) { 
        [self removeFromSuperview]; 
    }];
}

// add with a fade-in effect
- (void) addSubviewWithFadeAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option
{
	view.alpha = 0.0;	// make the view transparent
	[self addSubview:view];	// add it
	[UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{view.alpha = 1.0;}
                     completion:nil];	// animate the return to visible 
}


- (void) removeWithFadeAnimation:(float)secs option:(UIViewAnimationOptions)option
{
	[UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{self.alpha = 0.0;}
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];	
}

// remove self making it "drain" from the sink!
- (void) removeWithSinkAnimation:(int)steps
{
	if (steps > 0 && steps < 100)	// just to avoid too much steps
		self.tag = steps;
	else
		self.tag = 50;
    [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(removeWithSinkAnimationRotateTimer:) userInfo:nil repeats:YES];
}
- (void) removeWithSinkAnimationRotateTimer:(NSTimer*) timer
{
	CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(self.transform, 0.9, 0.9),0.314);
	self.transform = trans;
	self.alpha = self.alpha * 0.98;
	self.tag = self.tag - 1;
	if (self.tag <= 0)
	{
		[timer invalidate];
		[self removeFromSuperview];
	}
}

- (void) bounceZoomView{
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
     
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)bounceTranslationView
{    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationCurveEaseInOut animations:^{
        [UIView setAnimationRepeatCount:2.0];
        self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -40);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

- (void)rotateShakeView
{
    CGAffineTransform translateRight  = CGAffineTransformMakeRotation(0.2);
    CGAffineTransform translateLeft = CGAffineTransformMakeRotation(-0.2);

    
    self.transform = translateLeft;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:5.0];
        self.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

@end
