//
//  AppDelegate.h
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TestFlightSDK/TestFlight.h>
#import "TripManager.h"
#import "BWStatusBarOverlay.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) BWStatusBarOverlay *statusBarOverlay;

@end
