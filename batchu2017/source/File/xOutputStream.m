//
//  xOutputStream.m
//  testsavefile
//
//  Created by dungpq on 2/16/13.
//  Copyright (c) 2013 Felix jsc. All rights reserved.
//

#import "xOutputStream.h"

@implementation xOutputStream


-(id)init:(int)length
{
    self = [super init];
    if (self) {
           _data = [[NSMutableData alloc] initWithCapacity:length];
        
        _pos = 0;
        
    }
    return self; 
   
}

-(id)init:(int)length isInMem:(BOOL)isMemory
{
    self = [super init];
    if (self) {
         _data = [[NSMutableData alloc] initWithCapacity:length];
        _pos = 0;
        
    }
    return self;
    
}

-(void)writeFloat:(float)_value
{
    [_data appendBytes:&_value length:sizeof(float)];
}

-(void)writeInt:(int)_value
{
    [_data appendBytes:&_value length:sizeof(int)];
}

-(void)writeBool:(BOOL)_value
{
    if(_value){
        [self writeInt:1];
    }else{
        [self writeInt:0];
    }
   
}

-(void)writeBytes:(NSData*)_value withLength:(int)count
{
    [self writeInt:count];
    [_data appendBytes:[_value bytes] length:count];
    
}

-(void)writeLong:(long)_value
{
    [_data appendBytes:&_value length:sizeof(long)];
    
}

-(void)writeString:(NSString*)_value
{
    if(_value!=nil && [_value length]>0){
        NSData* string2data = [_value dataUsingEncoding:NSUTF8StringEncoding];
        int length = [string2data length];
        [_data appendBytes:&length length:sizeof(int)];
        [_data appendBytes:[string2data bytes] length:length];
    }else{
        int length = 0;
        [_data appendBytes:&length length:sizeof(int)];
    }
    
}
-(NSMutableData*) getdata
{
    return _data;
}


-(void)writeToFile:(NSString*)path
{
    [_data writeToFile:path atomically:YES];

}
@end
