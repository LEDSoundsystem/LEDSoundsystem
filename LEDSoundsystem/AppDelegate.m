//
//  AppDelegate.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/3/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "startViewController.h"
#import "playlistTableViewController.h"
#import "Config.h"

@import WatchConnectivity;
@import HealthKit;

@interface AppDelegate () <WCSessionDelegate>

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *heartData;
@property (nonatomic, strong) NSDictionary *songData;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Spotify Authorization Logic
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @LEDClientID;
    auth.redirectURL = [NSURL URLWithString:@LEDCallbackURL];
    [auth setRequestedScopes:@[SPTAuthStreamingScope]];
    
    
    NSURL *loginURL = [auth loginURL];

    [application performSelector:@selector(openURL:)
                      withObject:loginURL];
    
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    return YES;
}


// Spotify Auth Methods

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {

    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        if(error != nil) {
            NSLog(@"auth callback returned error %@", error);
            return;
        }
        auth.session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    if([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

-(void)playUsingSession:(SPTSession *)session {
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        
        NSURL *trackURI = [NSURL URLWithString:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp"];
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

// Watch Methods

- (void) applicationShouldRequestHealthAuthorization:(UIApplication *)application {
    
    [self.healthStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * error) {
        if(!success) {
            NSLog(@"error: %@", error);
        }
    }];
}

#pragma mark - WCSession Delegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary*)message {
    
    AppDelegate *tmpDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIViewController *vc = (tmpDelegate.window.rootViewController);
    NSString *HR = [message objectForKey:@"heartRate"];
    
    if (!self.heartData) {
        self.heartData = [[NSMutableArray alloc] init];
    }
        
    [self.heartData addObject:HR];

    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSDictionary *heartDict = [[NSDictionary alloc] initWithObjectsAndKeys: [message objectForKey:@"heartRate"], @"heart_rate", timestamp, @"time", nil];
    [self postHeartrate: heartDict];
}

#pragma mark - Standard WatchKit Delegate

-(void)sessionWatchStateDidChange:(nonnull WCSession *)session
{
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
        if(session.reachable){
            NSLog(@"session.reachable");
        }
        
        if(session.paired){
            if(session.isWatchAppInstalled){
                
                if(session.watchDirectoryURL != nil){
                    
                }
            }
        }
    }
}

- (void)postHeartrate:(NSDictionary *)data {
    
    NSURL *url = [NSURL URLWithString:@"http://10.89.87.147:3000/songs/0"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    __autoreleasing NSError* error = nil;
    NSURLResponse* response = [[NSURLResponse alloc] init];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
    
    [request setHTTPBody: jsonData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"error in postHeartrate: %@", error);
    }
    
}





@end
