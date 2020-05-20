//
//  xInputStream.h
//  testsavefile
//
//  Created by dungpq on 2/16/13.
//  Copyright (c) 2013 Felix jsc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xInputStream : NSObject
{
@private
    NSMutableData* _data;
    int _pos;
    int _total_length;
}

-(id)init:(NSMutableData*)data;
-(int)readInt;
-(float)readFloat;
-(NSString*)readString;
-(long)readLong;
-(BOOL)readBool;
+(id)initFromFile:(NSString*)path;
-(NSData*)readBytes;
-(int)readRandomInt;
@end
