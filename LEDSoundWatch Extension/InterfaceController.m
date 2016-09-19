//
//  InterfaceController.m
//  LEDSoundWatch Extension
//
//  Created by Nicholas Jurden on 4/28/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "InterfaceController.h"
@import HealthKit;
@import WatchKit;
@import Foundation;
@import WatchConnectivity;

@interface InterfaceController() <HKWorkoutSessionDelegate, WCSessionDelegate>
{
    HKHealthStore *healthStore;
    HKWorkoutSession *session;
    HKUnit *heartRateUnit;
    BOOL workoutActive;
    HKQueryAnchor *anchor;
    WCSession *WCsession;
}
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    
    [super willActivate];
    [_toggleSwitch setOn:NO];
    if ([HKHealthStore isHealthDataAvailable]) {
        heartRateUnit = [HKUnit unitFromString:@"count/min"];
        healthStore = [[HKHealthStore alloc]init];
        workoutActive = false;
        anchor = [HKQueryAnchor anchorFromValue:HKAnchoredObjectQueryNoAnchor];
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        NSSet *dataTypes = [NSSet setWithObjects:quantityType, nil];
        
        [healthStore requestAuthorizationToShareTypes:nil
                                            readTypes:dataTypes
                                           completion:^(BOOL success, NSError * _Nullable error) {
                                               if (error) {
                                                   NSLog(@"[InterfaceController] error requesting permission: %@", error);
                                               }
        }];
    }
    
    if ([WCSession isSupported]) {
        WCsession = [WCSession defaultSession];
        WCsession.delegate = self;
        [WCsession activateSession];
    }
    
}

-(void)updateHeartRate:(NSMutableArray *)samples {
    dispatch_async(dispatch_get_main_queue(), ^{
        HKQuantitySample *sample = [samples objectAtIndex:0];
        HKQuantity *quantity = sample.quantity;
        float value = [quantity doubleValueForUnit:heartRateUnit];

        if(WCsession.reachable){
            NSString *heartString = [NSString stringWithFormat:@"%f", value];
            NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[heartString] forKeys:@[@"heartRate"]];
            [WCsession sendMessage:applicationData
                      replyHandler:^(NSDictionary* replyMessage) {}
                      errorHandler:^(NSError *error) {
                          NSLog(@"error in sending message: %@", error);
                      }
            ];
        }
    });
}

-(HKQuery *)createHeartRateStreamingQuery:(NSDate *)workoutStartDate{
    HKObjectType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    HKAnchoredObjectQuery *heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:quantityType predicate:nil anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            anchor = newAnchor;
            [self updateHeartRate:sampleObjects];
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            
        } else {
            NSLog(@"[interfaceController createStreamingQuery] resultsHandler] query %@", error);
        }
    }];
    
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            anchor = Anchor;
            [self updateHeartRate:SampleArray];
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }else{
            NSLog(@"[interfaceController createStreamingQuery] updateHandler] query %@", error);
        }
    }];
    
    return heartQuery;
}

-(void)startWorkout{
    session = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypePlay locationType:HKWorkoutSessionLocationTypeUnknown];
    session.delegate = self;
    [healthStore startWorkoutSession:session];
    
}

-(void)workoutDidStart:(NSDate *)date{
    HKQuery *query = [self createHeartRateStreamingQuery:date];
    [healthStore executeQuery:query];
}

-(void)workoutDidEnd:(NSDate *)date{
    HKQuery *query = [self createHeartRateStreamingQuery:date];
    [healthStore stopQuery:query];
    
}

-(void) workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date {
    if (toState) {
        [self workoutDidStart:date];
    } else {
        [self workoutDidEnd:date];
    }
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error {
    NSLog(@"workout error: %@", error.userInfo);
}



- (void)didDeactivate {
    [super didDeactivate];
}

- (IBAction)toggleWorkout:(BOOL)value{
    if (value == NO) {
        workoutActive = NO;
        [_toggleSwitch setTitle:@"Start"];
        [healthStore endWorkoutSession:session];
    } else {
        workoutActive = YES;
        [_toggleSwitch setTitle:@"Stop"];
        [self startWorkout];
    }
}

- (void)endWorkout {
    [healthStore endWorkoutSession:session];
}
@end



