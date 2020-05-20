//
//  TextUtils.h
//  batchu
//
//  Created by Pham Quang Dung on 10/12/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextUtils : NSObject
{
    NSArray* codau;
    NSString* vietnameseindex;
    NSArray *bodau;
   
}
-(NSString*) removeSpace:(NSString*) s;
-(NSString*)getNoMarkUnicode:(NSString*) s;

-(NSArray*) getSuggestionFull:(NSString*) pAnswerShort;

@end
