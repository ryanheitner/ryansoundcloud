//
//  ViewController.h
//  SoundCloud
//
//  Created by Ryan Heitner on 12/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tracks.h"

@interface DetailViewController : UIViewController

@property (weak, nonatomic ) IBOutlet UIImageView *imageView;
@property (weak, nonatomic ) IBOutlet UIButton    *buttonPlay;
@property (nonatomic,strong) Tracks      *tracks;


- (IBAction)pushedButtonPlay:(id)sender;
- (IBAction)pushedButtonRight:(id)sender;
- (IBAction)pushedButtonLeft:(id)sender;

@end

