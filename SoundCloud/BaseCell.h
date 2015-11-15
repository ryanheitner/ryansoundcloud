//
//  listCell.h
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@end
