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


@interface ViewController () <SPTAudioStreamingDelegate> {
    HKHealthStore *healthStore;
}

@property (strong, nonatomic) SPTAudioStreamingController *player;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songTitle.text = @"Nothing Playing";
    
    //GET SONG INFORMATION AND STORE IT...once you play....
    
#warning need to set the duration equal to the song data being passed's duration.
    
    // Do any additional setup after loading the view, typically from a nib.
    //MIGHT WANT TO PUT THIS IN PLAY BUTTON PRESSED...
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        healthStore = [[HKHealthStore alloc] init];
        
        //define quantity types to read
        NSSet *readObjectTypes = [NSSet setWithObjects:
                                  [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]
                                  , nil];
        
        
        [healthStore requestAuthorizationToShareTypes:nil readTypes:readObjectTypes completion:^(BOOL success, NSError *error) {
            if(success == YES) {
                [self queryHeartRate];
            } else {
                //need to determine if error or user canceled...
                NSLog(@"error authorizing heart rate: %@", error);
            }
        }];
    }
}

# warning THIS ONLY GETS DATA FROM HEALTHKIT...WE NEED TO USE A "WORKOUT" TO GET DATA FROM APPLE WATCH...
-(void)queryHeartRate {
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *now = [NSDate date];
#warning eventually make then the time after the current time + the duration
    NSDate *then = [NSDate dateWithTimeIntervalSinceNow:1200];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:now endDate:then options:HKQueryOptionStrictStartDate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    HKQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(!error && results) {
            for(HKQuantitySample *samples in results) {
#warning implement appending of code to nsmutable array....we could POST straight from here too
                NSLog(@"[Viewcontroller queryheartrate] sample: %@", samples);
            }
        }
        else{
            NSLog(@"[queryHeartRate] error in sampling: %@", error);
        }
    }];
    
    [healthStore executeQuery:sampleQuery];
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
        NSLog(@"successfully started playing.");
        NSURL *songURL = (NSURL *)_song.playableUri;
        NSLog(@"song url: %@", songURL);
        [self.player playURI:songURL callback:nil];
        //[self updateUI];
    }];
}
//
//  THIS CAN BE USED OT SAVE HEART RATE TO HEALTHKIT
//
//-(void)getHeartRate:(double)height{
//    NSDate *now = [NSDate date];
//    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    HKUnit *heartRateUnit = [HKUnit unitFromString:@"count/min"];
//    HKQuantity *quantity = [HKQuantity quantityWithUnit:heartRateUnit doubleValue:height];
//    HKQuantitySample *heartRateSample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:now endDate:now];
//    
//}

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

-(void)collectHeartRate {
    while([self.player isPlaying])
    {
        NSDate *now = [NSDate date];
        NSDate *then= [NSDate dateWithTimeInterval:1200 sinceDate:now];
        
        HKQuantityType *heartRateType =
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        HKQuantity *heartRateForInterval =
        [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"]
                         doubleValue:95.0];
        
        
        //need to figure out when to stop and start the heart rate sampling
        HKQuantitySample *heartRateForIntervalSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:heartRateForInterval startDate:now endDate:then];
        
        [_samples addObject:heartRateForIntervalSample];
        NSLog(@"sample %lu: %@", (unsigned long)_samples.count, heartRateForIntervalSample);
    }
}

@end
