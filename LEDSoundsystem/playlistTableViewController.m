//
//  playlistTableViewController.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/29/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "playlistTableViewController.h"

//NOT SURE WE NEED CUSTOM CELL JUST NOW...
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"[playlistTableViewController viewDidLoad] %@", self.playlists.firstTrackPage.items);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Configure the cell...
    
    //Track title
    cell.textLabel.text=[NSString stringWithFormat:@"%@", [[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] name]];
    
    //album title
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] album] name]];
    
    //album artwork
    
    NSURL *albumURL = [[[[_playlists.firstTrackPage.items objectAtIndex:indexPath.row] album] smallestCover]imageURL];
    
    
    UIImage *albumCover = [UIImage imageWithData:[NSData dataWithContentsOfURL:albumURL]];
    cell.imageView.image = albumCover;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"showSong" sender:self];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showSong"])
    {
        SPTAuth *auth = [SPTAuth defaultInstance];
        ViewController *songView = (ViewController *)[segue destinationViewController];
        SPTPartialTrack *selectedTrack = (SPTPartialTrack *)[_playlists.firstTrackPage.items objectAtIndex:selectedIndex];
        songView.song = selectedTrack;
        
//        NSString *authToken = [NSString stringWithFormat:@"Bearer %@", auth.session.accessToken];
//        
//        /* Create request variable containing our immutable request
//         * This could also be a paramter of your method */
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/audio-features/%@", selectedTrack.identifier]]];
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
//            NSLog(@"Not fucked, it worked");
//            songView.responseData = _responseData;
//        }

    }
}


@end
