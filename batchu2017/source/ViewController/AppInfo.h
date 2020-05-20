

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
{
}
@property () int addition_ruby;
@property () int status;

@property (strong,nonatomic) NSString* icon_url;
@property (strong,nonatomic) NSString* install_url;

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* urlscheme;

@end
