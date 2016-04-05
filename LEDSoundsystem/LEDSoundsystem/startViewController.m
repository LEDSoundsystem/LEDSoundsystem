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

@interface startViewController () <SPTAudioStreamingDelegate>

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showPlaylists"]){
        playlistTableViewController *plist = [segue destinationViewController];
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        [SPTPlaylistList playlistsForUserWithSession:auth.session callback:^(NSError *error, SPTPlaylistList *object) {
            
            if (!error) {
                NSURL *playlistURL = nil;
                plist.playlists = object;
                //at this point, the pl object isn't playing nice
                if(object != nil && object.items != nil && object.items.count > 0) {
                    playlistURL = [object.items[0] uri];
                } else {
                    //snipped code
                }
                NSString *theResult = [playlistURL absoluteString];
                
                NSLog(@"[startViewController prepareForSegue if!error] %@", theResult);
                //snipped code
            } else {
                NSLog(@"Problem with the Spotify media Picker... %@", error);
            }
        }];
        NSLog(@"[startViewController prepareForSegue] this is the showPlaylists segue!");
    }
    
}


@end
