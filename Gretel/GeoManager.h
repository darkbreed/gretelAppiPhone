//
//  GeoManager.h
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GPSPoint.h"
#import "SettingsManager.h"

///Notification name for classes to subscribe to. Fires when the app detects a change in the users location
extern NSString *const GTLocationUpdatedSuccessfully;
extern NSString *const GTLocationLocationUpdatesDidFail;
extern NSString *const GTLocationHeadingDidUpdate;
extern NSString *const GTLocationDidPauseUpdates;

///Distance filter for accuracy settings
extern NSNumber *const GTDistanceFilterInMetres;

@class GeoManager;

@interface GeoManager : NSObject <CLLocationManagerDelegate> {
    
    ///Location manager instance for tracking position, heading etc.
    CLLocationManager *locationManager;
    
}

/**
 * Stores the current location, updates each time the app detects a change in the users location
 */
@property (nonatomic, strong) CLLocation *currentLocation;

/**
 * The delegate to handle callbacks
 */
@property (nonatomic, strong) id delegate;

@property (nonatomic, readwrite) float fromHeadingAsRad;
@property (nonatomic, readwrite) float toHeadingAsRad;

@property (nonatomic, readwrite) float speed;

/**
 * Singleton init method
 */
+(GeoManager*)sharedManager;

/**
 * Tells the app to start tracking the users location
 */
-(void)startTrackingPosition;

/**
 * Tells the app to stop tracking the users location
 */
-(void)stopTrackingPosition;

/**
 * Returns the current speed the device is travelling in metres per second
 * @return float speed in metres per second
 */
-(float)currentSpeed;

/**
 * Wrapper for CLLocationManager method to check if location service are enabled.
 * @return BOOL enabled
 */
-(BOOL)locationServicesEnabled;

@end
