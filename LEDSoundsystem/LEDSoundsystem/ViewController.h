//
//  ViewController.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/3/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "AFHTTPSessionManager.h"
#import "Global.h"

@import HealthKit;

@interface ViewController : UIViewController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) SPTPartialTrack *song;
@property (strong, nonatomic) NSMutableData *responseData;
//not sure we need this anymore
@property (strong, nonatomic) NSMutableArray *samples;
@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) SPTAudioStreamingController *player;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;

@property (strong, nonatomic) NSString *songData;

@end

