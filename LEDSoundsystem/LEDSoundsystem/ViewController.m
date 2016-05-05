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
    
    //GET SONG INFORMATION AND STORE IT...once you play....
    pointer = [[UIApplication sharedApplication] delegate];
#warning need to set the duration equal to the song data being passed's duration.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)postSongData{
    //play is pressed...send the song data...
    //set up url
    
    NSURL *url = [NSURL URLWithString:@"http://10.90.6.211:3000/songs"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    //NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
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

    
//    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if(error) {
//            NSLog(@"error posting song data: %@", error);
//        }
////        [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
////        songId = response;
//    
//    }];
    
    NSLog(@"[ViewController postSongData] got to resume.");
    //[postDataTask resume];
}

-(void)handleNewSession {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSString *authToken = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];
    
    /* Create request variable containing our immutable request
     * This could also be a paramter of your method */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", _song.identifier]]];
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(!theConnection){
        NSLog(@"Fucked, didn't work");
    }
    else {
        NSLog(@"Not fucked, it worked");
        NSLog(@"response data: %@", self.responseData);
    }
    
    //create default auth instance
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
        NSLog(@"successfully started playing.");
        NSURL *songURL = (NSURL *)_song.playableUri;
        NSLog(@"song url: %@", songURL);
        [self.player playURI:songURL callback:nil];
        //[self updateUI];
    }];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
    NSLog(@"NSURL: Did Receive Response: %@", _responseData);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    NSLog(@"NSURL: Did Receive Data");

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@"%@",_responseData);
    NSString *someString = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
    NSLog(@"response: %@",someString);
    _songData = someString;
    //[AppDelegate getSongData:_songData];
    [self postSongData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (IBAction)playMusic:(id)sender {
    NSLog(@"Play button pressed.");
    [self handleNewSession];
    [self updateUI];
}
- (IBAction)logPress:(id)sender {
    NSLog(@"buton pressed");
}

-(IBAction)pauseMusic:(id)sender {
    NSLog(@"Pause Button pressed.");
    if([self.player isPlaying]){
        NSLog(@"Pausing Current Song");
        
        [self.player setIsPlaying: NO callback:^(NSError *error) {
            NSLog(@"Error pausing the song: error: %@",error);
        }];
    }
}

-(IBAction)resumeMusic:(id)sender {
    if(![self.player isPlaying]){
        NSLog(@"Resuming Music");
        [self.player setIsPlaying:YES callback:^(NSError *error) {
            NSLog(@"Unable to resume song. error: %@",error);
        }];
    }
}

@end
