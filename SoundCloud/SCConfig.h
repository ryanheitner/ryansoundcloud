//


#import <Foundation/Foundation.h>

@interface SCConfig : NSObject

+ (instancetype)sharedInstance;
+ (NSDictionary *)configDictionary ;
+ (NSString *)configFilePath ;


+ (id)valueForKey:(NSString *)key ;



@end
