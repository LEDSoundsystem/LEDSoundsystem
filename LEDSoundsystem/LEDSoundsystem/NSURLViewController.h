//
//  NSURLViewController.h
//  LEDSoundsystem
//
//  Created by Evan Nichols on 4/10/16.
//  Copyright © 2016 EECS 700 Group. All rights reserved.
//

#ifndef NSURLViewController_h
#define NSURLViewController_h

@interface NSURLViewController : UIViewController<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}


#endif /* NSURLViewController_h */
