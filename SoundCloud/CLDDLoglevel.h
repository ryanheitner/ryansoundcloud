//
//  CLDDLoglevel.h
//
//

#import <Foundation/Foundation.h>
extern int ddLogLevel;

@interface CLDDLoglevel : NSObject
+ (void)setLogLevel:(int)logLevel;
+ (int)ddLogLevel;

@end
