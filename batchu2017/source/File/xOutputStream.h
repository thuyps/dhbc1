//
//  xOutputStream.h
//  testsavefile
//
//  Created by dungpq on 2/16/13.
//  Copyright (c) 2013 Felix jsc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xOutputStream : NSObject
{
@private
    NSMutableData* _data;
    int _length;
    int _pos;
  
}
-(id)init:(int)length isInMem:(BOOL)isMemory;
-(id)init:(int)length;
-(void)writeBool:(BOOL)_value;
-(void)writeInt:(int)_value;
-(void)writeLong:(long)_value;
-(void)writeFloat:(float)_value;
-(void)writeString:(NSString*)_value;
-(void)writeBytes:(NSData*)_value withLength:(int)count;
-(NSMutableData*) getdata;
-(void)writeToFile:(NSString*)path;
@end
