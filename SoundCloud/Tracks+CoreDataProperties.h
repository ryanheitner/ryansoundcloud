//
//  Tracks+CoreDataProperties.h
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tracks.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tracks (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *artwork_url;
@property (nullable, nonatomic, retain) NSString *trackID;
@property (nullable, nonatomic, retain) NSString *permalink_url;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uri;

@end

NS_ASSUME_NONNULL_END
