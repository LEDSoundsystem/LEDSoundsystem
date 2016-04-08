//
//  Global.h
//  LEDSoundsystem
//
//  Created by Nicholas Jurden on 4/7/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface Global : NSObject

+ (AFHTTPSessionManager *)networkManager;

@end
