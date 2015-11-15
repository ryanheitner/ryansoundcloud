//
//  CLDDLoglevel.m
//
//

#import "CLDDLoglevel.h"
int ddLogLevel = DDLogLevelOff;

@implementation CLDDLoglevel
+ (int)ddLogLevel
{
	return ddLogLevel;
}

+ (void)setLogLevel:(int)logLevel
{
	ddLogLevel = logLevel;
}
@end
