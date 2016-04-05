//
//  playlistTableViewController.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/29/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface playlistTableViewController : UITableViewController <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property (strong, nonatomic) SPTPlaylistList *playlists;

@end
