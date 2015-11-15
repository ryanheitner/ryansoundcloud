//
//  MyLogFormat.m
//

#import "MyLogFormat.h"

@implementation MyLogFormat
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	NSString *logLevel;
	switch (logMessage->_flag) {
		case DDLogFlagError    :
			logLevel = @"E"; break;
		case DDLogFlagWarning  :
			logLevel = @"W"; break;
		case DDLogFlagInfo     :
			logLevel = @"I"; break;
		case DDLogFlagDebug    :
			logLevel = @"D"; break;
		default                :
			logLevel = @"V"; break;
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM-dd hh:mm:ss"];
	
	NSString *date = [formatter stringFromDate:[NSDate date]];
	
	return [NSString stringWithFormat:@"%@:%@ |line %d|%@| %@\n",date,  logLevel, (int)logMessage.line, logMessage.function,logMessage.message];
}

@end
