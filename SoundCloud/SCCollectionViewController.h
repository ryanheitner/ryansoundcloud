//
//  SCCollectionViewController.h
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tracks.h"


@interface SCCollectionViewController : UICollectionViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


#pragma mark buttons
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonGridView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonListView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSearch;

#pragma markcore data
@property (nonatomic, strong) Tracks  *selectedTrack;

#pragma markbutton actions

- (IBAction)pushedButtonSearch:(id)sender;
- (IBAction)pushedButtonGrid:(id)sender;
- (IBAction)pushedButtonList:(id)sender;


@end
