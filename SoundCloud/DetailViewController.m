//
//  ViewController.m
//  SoundCloud
//
//  Created by Ryan Heitner on 12/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SCConfig.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "UIView+Toast.h"

@interface DetailViewController ()

@end

@implementation DetailViewController {
    AVAudioPlayer *_player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _tracks.title;

    

    NSURL *artWorkURL = [NSURL URLWithString:self.tracks.artwork_url];
    
    // We get the art from the cache or fdownload from the URL
    
    
    [self.imageView sd_setImageWithURL:artWorkURL
                        placeholderImage:[UIImage imageNamed:@"icon_music_solid"]
                                 options:SDWebImageHighPriority
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (error == nil && image.size.height > 0) {
                                       
                                   } else {
                                       
                                       DDLogWarn(@"image %@",error);
                                   }
                               }];
    

    UIImage *pauseImage = [UIImage imageNamed:@"media_pause"];
    [self.buttonPlay setImage:pauseImage forState:UIControlStateSelected];
    UIImage *playImage  = [UIImage imageNamed:@"media_play"];
    [self.buttonPlay setImage:playImage forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushedButtonPlay:(id)sender {

    if (self.buttonPlay.selected && _player && _player.rate == 1.0) {
        [_player pause];
    } else {
// We keep client ID in our config.plist
        NSString *soundCloudAppID = [SCConfig valueForKey:kKeySoundCloudAppID];
        
        NSString *trackID = self.tracks.trackID;
        NSString *clientID = soundCloudAppID;
        NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", trackID, clientID]];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:trackURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // self.player is strong property
            _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
            [_player play];
        }];
        
        [task resume];
    }
    
    self.buttonPlay.selected = !self.buttonPlay.selected;

}

- (IBAction)pushedButtonRight:(id)sender {
    // I did not implement forward or back
    NSString *message = @"No Going Forward Today try Tommororw";
    [self.view makeToast:message];
}

- (IBAction)pushedButtonLeft:(id)sender {
    // I did not implement forward or back

    NSString *message = @"No Going Back";
    [self.view makeToast:message];
}


@end
