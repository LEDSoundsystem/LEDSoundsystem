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
    
    if(self.player.currentTrackURI == nil) {
        self.songTitle.text = @"Nothing Playing";
        return;
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
            SPTPlaylistSnapshot *playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
            
            [self.player playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
            
            SPTPartialTrack *track = playlistSnapshot.firstTrackPage.items[0];
            NSString *requestURL = [NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", track.identifier];
            
            NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            [params setValue:authorizationString forKey:@"Authorization"];
            
            [[Global networkManager] GET:requestURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"GET request for song info succeeded. Track info for %@: %@", track.name, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"failed to get track info. error: %@", error);
            }];
            
            NSLog(@"[viewController handleNewSession] track.identifier = %@", track.identifier);
            
            
            
            [self updateUI];
        }];
        
    }];
    
    
    
}

- (IBAction)playMusic:(id)sender {
    NSLog(@"play button pressed...");
    [self handleNewSession];
}
- (IBAction)logPress:(id)sender {
    NSLog(@"buton pressed");
}

@end
