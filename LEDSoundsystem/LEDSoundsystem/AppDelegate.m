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
#import "Config.h"

@interface AppDelegate ()

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Spotify Authorization Logic
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @LEDClientID;
    auth.redirectURL = [NSURL URLWithString:@LEDCallbackURL];
    [auth setRequestedScopes:@[SPTAuthStreamingScope]]; //this is where you define the scope of permission requirement
    
    // Construct a login URL and open it
    NSURL *loginURL = [auth loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL];
    //End Spotify Authorization Logic
    
    return YES;
}


//***************************************************************************************************
//Spotify Auth Methods
//***************************************************************************************************

// Handle auth callback
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
    
    // Create a new player if needed
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
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}
//****************************************************************************************
//end spotify auth methods
//****************************************************************************************

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





@end
