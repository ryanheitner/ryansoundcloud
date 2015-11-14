//


#import "SCConfig.h"

@implementation SCConfig

+ (instancetype)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedConfig = nil;
	
	dispatch_once(&p, ^{
		_sharedConfig = [[self alloc] init];
	});
	
	return _sharedConfig;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		
		
	}
	return self;
}


+ (NSString *)configFilePath {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SCConfig" ofType:@"plist"];
	NSAssert([[NSFileManager defaultManager] isReadableFileAtPath:path], @"config file missing or corrupt- %s",__PRETTY_FUNCTION__);
	return path;
}

+ (NSDictionary *)configDictionary {
	NSString *path = [SCConfig configFilePath];
	return [[NSDictionary alloc] initWithContentsOfFile:path];
}


+ (id)valueForKey:(NSString *)key {
	NSDictionary *dict = [SCConfig configDictionary];
	return [dict valueForKey:key];
}
@end
