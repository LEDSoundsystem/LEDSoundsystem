//
//  Global.m
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 4/7/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import "Global.h"

@implementation Global

+ (AFHTTPSessionManager *)networkManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager setResponseSerializer:responseSerializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    return  manager;
}

@end
