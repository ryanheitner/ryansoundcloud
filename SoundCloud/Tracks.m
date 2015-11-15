//
//  Tracks.m
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import "Tracks.h"
#import "AppDelegate.h"

@implementation Tracks

// Insert code here to add functionality to your managed object subclass

+ (NSError *)parseTracks:(NSData *)responseData {
    NSError *jsonError;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:0
                                         error:&jsonError];
    
    if (jsonError) {
        NSString *message = [NSString stringWithFormat:@"jsonError:%@",jsonError];
        return [NSError errorWithDomain:@"ryancloud" code:23 userInfo:@{@"message":message}];
        
    }
    AppDelegate *appdelegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tracks" inManagedObjectContext:appdelegate.managedObjectContext];
    if ([jsonResponse isKindOfClass:[NSArray class]])
    {
        NSArray *tracks = (NSArray *)jsonResponse;
        
        for (NSDictionary *track in tracks) {
            

            Tracks *tracks = [[Tracks alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:appdelegate.managedObjectContext];
            
            NSNumber *value = track[kSC_id];
            tracks.trackID = [value stringValue];
            DDLogDebug(@"tracks.trackID %@",value);
            if (track[kSC_permalink_url] != [NSNull null]) {
                tracks.permalink_url = track[kSC_permalink_url];
            }
            
            if (track[kSC_artwork_url] != [NSNull null]) {
                tracks.artwork_url = track[kSC_artwork_url];
            }
            
            if (track[kSC_title] != [NSNull null]) {
                tracks.title = track[kSC_title];
            }
            
            if (track[kSC_uri] != [NSNull null]) {
                tracks.uri = track[kSC_uri];
            }
        }
    }
    [appdelegate saveContext];
    return nil;
}

@end
