//
//  startViewController.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 4/4/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "startViewController.h"

@interface startViewController : UIViewController <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property (strong, nonatomic) SPTPlaylistSnapshot* playlistSnapshot;

- (IBAction)startClicked:(id)sender;

@end
