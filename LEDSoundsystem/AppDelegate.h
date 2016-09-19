//
//  AppDelegate.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 3/3/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WatchConnectivity;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)postDataToServer:(NSDictionary *)data;

@end

