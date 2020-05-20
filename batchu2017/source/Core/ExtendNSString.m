#import "ExtendNSString.h"

@implementation NSString (util)

- (int) indexOf:(NSString *)text {
    NSRange range = [self rangeOfString:text];
       
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}

- (int) indexOf:(NSString *)text fromIndex:(int)fromindex {
    
    NSRange range = [self rangeOfString:text options:NSCaseInsensitiveSearch range:NSMakeRange(fromindex,[self length]-fromindex-1)];
    
    
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}

-(int)count:(NSString*)text
{
    int start = 0;
    int result = 0;
    int count = 0;
    while (result>-1 && start < (self.length - 1))
    {
        result = [self indexOf:text fromIndex:start];
        start +=text.length;
        if(result>-1)
            count++;
    }
    
    return count;
}

@end
