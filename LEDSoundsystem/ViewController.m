//
//  ViewController.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/3/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "Config.h"
#import "ViewController.h"
#import <Spotify/Spotify.h>
#import <Spotify/SPTDiskCache.h>
#import "AFHTTPSessionManager.h"
#import "AppDelegate.h"

@import HealthKit;
@import WatchConnectivity;

@interface ViewController () <SPTAudioStreamingDelegate, NSURLSessionDelegate, WCSessionDelegate> {
    AppDelegate *pointer;
    int songId;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songTitle.text = @"Nothing Playing";
    
    pointer = [[UIApplication sharedApplication] delegate];
    
    _healthStore = [[HKHealthStore alloc]init];
    HKQueryAnchor *anchor = [HKQueryAnchor anchorFromValue:HKAnchoredObjectQueryNoAnchor];
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSet *dataTypes = [NSSet setWithObjects:quantityType, nil];
    
    [_healthStore requestAuthorizationToShareTypes:nil readTypes:dataTypes completion:^(BOOL success, NSError * _Nullable error) {
        if(success){
            NSLog(@"[InterfaceController] got permission");
        } else {
            NSLog(@"[InterfaceController] error requesting permission: %@", error);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"did appear!");
}

-(void)updateUI {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSDictionary *trackMetaData = [self.player currentTrackMetadata];
    
    
    if(trackMetaData != nil) {
        self.songTitle.text = [trackMetaData objectForKey:SPTAudioStreamingMetadataTrackName];
        return;
    }
    else{
        self.songTitle.text = @"Nothing Playing";
    }
    
    [self.spinner startAnimating];
    
    [SPTTrack trackWithURI:self.player.currentTrackURI session:auth.session callback:^(NSError *error, SPTTrack *track) {
        self.songTitle.text = track.name;
        
    }];
    
    
    
}

- (void)postSongData {
    
    NSURL *url = [NSURL URLWithString:@"http://10.89.87.147:3000/songs"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    __autoreleasing NSError* error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    [request setHTTPBody: _responseData];
    
    NSLog(@"[ViewController postSongData] result: %@", result);
    
    NSURLResponse* response = [[NSURLResponse alloc] init];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"%@",error);
    NSLog(@"%@",response);
}

-(void)handleNewSession {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSString *authToken = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", _song.identifier]]];
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];
    
    request = [mutableRequest copy];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        if(error != nil) {
            NSLog(@"**** Enabling playback got error: %@", error);
            return;
        }
        NSURL *songURL = (NSURL *)_song.playableUri;
        [self.player playURI:songURL callback:nil];
    }];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *someString = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
    _songData = someString;
    [self postSongData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

}

- (IBAction)playMusic:(id)sender {
    [self handleNewSession];
    [self updateUI];
}

-(IBAction)pauseMusic:(id)sender {
    if ([self.player isPlaying]) {
        [self.player setIsPlaying: NO callback:^(NSError *error) {
            NSLog(@"Error pausing the song: error: %@",error);
        }];
    }
}

-(IBAction)resumeMusic:(id)sender {
    if (![self.player isPlaying]) {
        [self.player setIsPlaying:YES callback:^(NSError *error) {
            NSLog(@"Unable to resume song. error: %@",error);
        }];
    }
}

#pragma mark - Navigation
- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue {
    
}
- (IBAction)unwindNow:(id)sender {
    [self performSegueWithIdentifier:@"unwindSegue" sender:self];
}


@end
