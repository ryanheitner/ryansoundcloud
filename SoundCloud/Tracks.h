//
//  Tracks.h
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>





NS_ASSUME_NONNULL_BEGIN

@interface Tracks : NSManagedObject


+ (NSError *)parseTracks:(NSData * )responseData;

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Tracks+CoreDataProperties.h"
