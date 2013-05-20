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
#import "TripManager.h"

///Notification name for classes to subscribe to. Fires when the app detects a change in the users location
extern NSString *const GTLocationUpdatedSuccessfully;
extern NSString *const GTLocationLocationUpdatesDidFail;
extern NSString *const GTLocationHeadingDidUpdate;
extern NSString *const GTLocationDidPauseUpdates;
extern NSString *const GTLocationDidResumeUpdates;
extern NSString *const GTAppDidEnterForeground;
extern NSString *const GTAppDidEnterBackground;

///Distance filter for accuracy settings
extern NSNumber *const GTDistanceFilterInMetres;

@class GeoManager;

@interface GeoManager : NSObject <CLLocationManagerDelegate> {
    
    ///Location manager instance for tracking position, heading etc.
    CLLocationManager *locationManager;
    BOOL initialLocate;
}

/**
 * Stores the most recent location, updates each time the app detects a change in the users location
 */
@property (nonatomic, strong) CLLocation *currentLocation;

/**
 * Stores the previous location, updates each time the app detects a change in the users location
 */
@property (nonatomic, strong) CLLocation *previousLocation;

/**
 * The delegate to handle callbacks
 */
@property (nonatomic, strong) id delegate;
@property (nonatomic, readwrite) float fromHeadingAsRad;
@property (nonatomic, readwrite) float toHeadingAsRad;
@property (nonatomic, readwrite) float speed;
@property (nonatomic, readwrite) float elevation;
@property (nonatomic, strong) NSTimer *backgroundLocationUpdateTimer;

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

/**
 * Returns the users current elevation from core location
 * @return float elevation
 */
-(float)currentElevation;

/**
 * Adjusts the app settings when going into the background. Mainly this methods initiates
 * a background process and timer to replace the NSTimer that will be killed when going
 * into the background.
 *
 * @param BOOL backgroundMode
 * @return void
 */
-(void)setBackgroundMode:(BOOL)backgroundMode;

/**
 * Starts a NSTimer that checks for the users location every n seconds. If the location is found within
 * the desired accuracy then the app shuts of the location updates until the timer fires again.
 * @return void
 */
-(void)startLocationManagerTimer;

/**
 * Stops and invalidates the location update timer
 * @return void
 */
-(void)stopLocationManagerTimer;

/**
 * Kills all location related stuff dead! 
 *
 * @return void
 */
-(void)killAllLocationServices;

@end
