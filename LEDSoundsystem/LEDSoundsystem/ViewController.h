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


@interface ViewController : UIViewController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, NSURLConnectionDelegate>
{
    
};
@property (strong, nonatomic) SPTPartialTrack *song;
@property (strong, nonatomic) NSMutableData *responseData;
//not sure we need this anymore
@property (strong, nonatomic) NSMutableArray *samples;
-(void)collectHeartRate;

@end

