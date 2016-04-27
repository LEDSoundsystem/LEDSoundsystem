//
//  playlistTableCellTableViewCell.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 4/26/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface playlistTableCellTableViewCell : UITableViewCell

@property (strong, nonatomic) SPTPartialTrack *song;

@end
