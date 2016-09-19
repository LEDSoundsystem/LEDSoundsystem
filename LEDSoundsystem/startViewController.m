//
//  startViewController.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 4/4/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "startViewController.h"
#import "playlistTableViewController.h"
#import <Spotify/Spotify.h>
@import HealthKit;

@interface startViewController () <SPTAudioStreamingDelegate> {
    
}

@end

@implementation startViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startClicked:(id)sender {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cjurden:playlist:5l0YAoyJvdUDDtPPI6ZbTp"] accessToken:auth.session.accessToken error:nil];
    
    [[SPTRequest sharedHandler]
        performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if(error) {
                NSLog(@"Playlist request generated error: %@", error);
                return;
            }

            _playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
        
            [self performSegueWithIdentifier:@"showPlaylists" sender:self];
        }
    ];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showPlaylists"]){
        playlistTableViewController* plist = (playlistTableViewController *)[segue destinationViewController];
        plist.playlists = _playlistSnapshot;
    }
    
}


@end
