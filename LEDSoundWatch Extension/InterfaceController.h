//
//  InterfaceController.h
//  LEDSoundWatch Extension
//
//  Created by Nicholas Jurden on 4/28/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@import HealthKit;
@import WatchKit;

@interface InterfaceController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSwitch *toggleSwitch;

- (IBAction)toggleWorkout:(BOOL)value;
- (void)updateHeartRate:(NSArray *)samples;
- (HKQuery *)createHeartRateStreamingQuery:(NSDate *)workoutStartDate;
- (void)startWorkout;
- (void)workoutDidStart:(NSDate *)date;
- (void)workoutDidEnd:(NSDate *)date;


@end
