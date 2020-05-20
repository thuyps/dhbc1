//
//  xInputStream.m
//  testsavefile
//
//  Created by dungpq on 2/16/13.
//  Copyright (c) 2013 Felix jsc. All rights reserved.
//

#import "xInputStream.h"


@implementation xInputStream

-(id)init:(NSMutableData*)data
{
    self = [super init];
    if (self) {
        _data = data;
        _pos = 0;
        _total_length = [_data length];
    }
    return self;
    
}



+(id)initFromFile:(NSString*)path
{

    NSMutableData* data = [[NSMutableData alloc] initWithContentsOfFile:path];
    if(data==nil){
        return nil;
    }
    
    xInputStream* stream = [[xInputStream alloc] init:data];

   return stream;

}

-(long)readLong
{
    NSRange _range = NSMakeRange(_pos, sizeof(long));
    long _value;
    [_data getBytes:&_value range:_range];
    _pos = _pos + sizeof(long);
    return _value;
}



-(int)readRandomInt
{
    if ((_pos+sizeof(int)) <= _total_length)
    {
        NSRange _range = NSMakeRange(_pos, sizeof(int));
        int8_t _value[4];
        [_data getBytes:&_value range:_range];
        
        int8_t byte1 = _value[0];
        int8_t byte2 = _value[1];
        int8_t byte3 = _value[2];
        int8_t byte4 = _value[3];
        
        int i1 = (int)(byte1 << 24) & 0xFF000000;
        int i2 = (int)(byte2 << 16) & 0x00FF0000;
        int i3 = (int)(byte3 << 8) & 0x0000FF00;
        int i4 = (int)(byte4 & 0xFF);
        
        int returnInt =  i1 | i2 | i3 | i4;
        _pos = _pos + sizeof(int);
        return returnInt;
    }else
    {
        return 0;
    }
}

-(int)readInt
{
    if ((_pos+sizeof(int)) <= _total_length)
    {
        NSRange _range = NSMakeRange(_pos, sizeof(int));
        int _value;
        [_data getBytes:&_value range:_range];
        _pos = _pos + sizeof(int);
        return _value;
    }else
    {
        return 0;
    }
}

-(BOOL)readBool
{
    if ((_pos+sizeof(int)) <= _total_length)
    {
        NSRange _range = NSMakeRange(_pos, sizeof(int));
        int _value;
        [_data getBytes:&_value range:_range];
        _pos = _pos + sizeof(int);
        if(_value==1){
            return YES;
        }else{
            return NO;
        }
    }else
    {
        return NO;
    }
}

-(float)readFloat
{
    NSRange _range = NSMakeRange(_pos, sizeof(float));
    float _value;
    [_data getBytes:&_value range:_range];
    _pos = _pos + sizeof(float);
    return _value;
}

-(NSString*)readString
{
    int string_len = [self readInt];
    if(string_len>0 && string_len<5000)
    {
        if ((string_len + _pos) <= _total_length){
            NSRange _range = NSMakeRange(_pos, string_len);
            NSData* string2data = [_data subdataWithRange:_range];
            NSString* newStr = [[NSString alloc] initWithData:string2data
                                                     encoding:NSUTF8StringEncoding];
          
            _pos = _pos + string_len;
            return newStr;
        }else{
            return nil; 
        }
    }else if(string_len==0){
        return nil; 
    }else{
        [NSException raise:NSInvalidArgumentException format:@"String format error "];
        return nil;
    }
}


-(NSData*)readBytes
{
    int string_len = [self readInt];
    if(string_len>0 && string_len<5000)
    {
        if ((string_len + _pos) <= _total_length){
            NSRange _range = NSMakeRange(_pos, string_len);
            NSData* string2data = [_data subdataWithRange:_range];
            _pos = _pos + string_len;
            return [string2data copy];
        }else{
            return nil;
        }
    }else if(string_len==0){
            return nil;
    }else{
            [NSException raise:NSInvalidArgumentException format:@"String format error "];
        return nil;
    }
}

@end
