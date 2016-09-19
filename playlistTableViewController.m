//
//  playlistTableViewController.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/29/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "playlistTableViewController.h"
#import "playlistTableCellTableViewCell.h"
#import "ViewController.h"
#import <Spotify/Spotify.h>

SPTPlaylistSnapshot *playlist;

@interface playlistTableViewController () <SPTAudioStreamingDelegate>
{
    NSInteger selectedIndex;
    NSMutableData *_responseData;
}

@end

@implementation playlistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_playlists.firstTrackPage.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Track title
    cell.textLabel.text=[NSString stringWithFormat:@"%@", [[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] name]];
    
    // Album title
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] album] name]];
    
    // Album artwork
    NSURL *albumURL = [[[[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] album] smallestCover]imageURL];
    
    
    UIImage *albumCover = [UIImage imageWithData:[NSData dataWithContentsOfURL:albumURL]];
    cell.imageView.image = albumCover;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"showSong" sender:self];
}

#pragma mark - Navigation
- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showSong"]) {
        SPTAuth *auth = [SPTAuth defaultInstance];
        ViewController *songView = (ViewController *)[segue destinationViewController];
        SPTPartialTrack *selectedTrack = (SPTPartialTrack *)[_playlists.firstTrackPage.items objectAtIndex:selectedIndex];
        songView.song = selectedTrack;
    }
}


@end
