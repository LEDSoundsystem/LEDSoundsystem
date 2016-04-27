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
    // Do any additional setup after loading the view.
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startClicked:(id)sender {
    //declare auth instance
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    //declare request for playlist
    NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"] accessToken:auth.session.accessToken error:nil];
    
    //perform playlist request using SPTRequest
    [[SPTRequest sharedHandler] performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        if(error != nil) {
            NSLog(@"playlist request generated error: %@", error);
            return;
        }
        
        //log progress...
        NSLog(@"Playlist request success");
        
        
        _playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
        
        [self performSegueWithIdentifier:@"showPlaylists" sender:self];
        
#warning move to player view
        //[self.player playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
        
        
//        SPTPartialTrack *track = playlistSnapshot.firstTrackPage.items[0];
//        
//        NSString *authToken = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];
//        
//        /* Create request variable containing our immutable request
//         * This could also be a paramter of your method */
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", track.identifier]]];
//        
//        //TO DO - MAKE A URL REQUEST FOR SONG DATA WITH EACH SONG CHANGE
//        
//        // Create a mutable copy of the immutable request and add more headers
//        NSMutableURLRequest *mutableRequest = [request mutableCopy];
//        [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];
//        
//        // Now set our request variable with an (immutable) copy of the altered request
//        request = [mutableRequest copy];
//        
//        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//        
//        if(!theConnection){
//            NSLog(@"Fucked, didn't work");
//        }
//        else {
//            NSLog(@"Not fucked, it worked: %@", _responseData);
//            [self collectHeartRate];
//        }
        
    }];
    

    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showPlaylists"]){
        playlistTableViewController* plist = (playlistTableViewController *)[segue destinationViewController];
        plist.playlists = _playlistSnapshot;
        
        NSLog(@"[startViewController prepareForSegue] this is the showPlaylists segue!");
    }
    
}


@end
