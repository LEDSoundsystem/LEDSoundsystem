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

@import HealthKit;


@interface ViewController () <SPTAudioStreamingDelegate>

@property (strong, nonatomic) SPTAudioStreamingController *player;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songTitle.text = @"Nothing Playing";
    // Do any additional setup after loading the view, typically from a nib.
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

-(void)handleNewSession {
    
    //create default auth instance
    SPTAuth *auth = [SPTAuth defaultInstance];
    
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
        
        NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"] accessToken:auth.session.accessToken error:nil];
        
        [[SPTRequest sharedHandler] performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if(error != nil) {
                NSLog(@"playlist request generated error: %@", error);
                return;
            }
            
            NSLog(@"Playlist request success");
            
            SPTPlaylistSnapshot *playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
            
            [self.player playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
            
            SPTPartialTrack *track = playlistSnapshot.firstTrackPage.items[0];
            
            NSString *authToken = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];
            
            /* Create request variable containing our immutable request
             * This could also be a paramter of your method */
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", track.identifier]]];
            
            //TO DO - MAKE A URL REQUEST FOR SONG DATA WITH EACH SONG CHANGE 
            
            // Create a mutable copy of the immutable request and add more headers
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            [mutableRequest addValue:authToken forHTTPHeaderField:@"Authorization"];
            
            // Now set our request variable with an (immutable) copy of the altered request
            request = [mutableRequest copy];
            
            // Log the output to make sure our new headers are there    
            NSLog(@"%@", request.allHTTPHeaderFields);
            
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            if(!theConnection){
                NSLog(@"Fucked, didn't work");
            }
            else {
                NSLog(@"Not fucked, it worked: %@", _responseData);
                NSMutableArray *samples = [NSMutableArray array];
                HKQuantityType *heartRateType =
                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                
                HKQuantity *heartRateForInterval =
                [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"]
                                 doubleValue:95.0];
                
                
                //need to figure out when to stop and start the heart rate sampling
                /*HKQuantitySample *heartRateForIntervalSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:heartRateForInterval startDate:<#(nonnull NSDate *)#> endDate:<#(nonnull NSDate *)#>]*/
                
                //[samples addObject:heartRateForIntervalSample];
            }
            
            [self updateUI];
        }];
    }];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
    NSLog(@"NSURL: Did Receive Response");
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
    NSLog(@"%@",someString);
    
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
