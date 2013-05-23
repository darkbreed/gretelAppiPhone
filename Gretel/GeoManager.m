//
//  GeoManager.m
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "GeoManager.h"

NSString *const GTLocationUpdatedSuccessfully = @"locationUpdatedSuccessfully";
NSString *const GTLocationLocationUpdatesDidFail = @"locationUpdatesFailed";
NSString *const GTLocationHeadingDidUpdate = @"headingDidUpdate";
NSString *const GTLocationDidPauseUpdates = @"updatesPaused";
NSString *const GTLocationDidResumeUpdates = @"updatesResumed";
NSString *const GTAppDidEnterForeground = @"didEnterForeground";
NSString *const GTAppDidEnterBackground = @"didEnterBackground";

@implementation GeoManager {
    
    NSUserDefaults *defaults;
    NSTimer *locationManagerTimer;
    float locationManagerTick;
    int desiredAccuracy;
    CLLocation *previousLocation;
    __block UIBackgroundTaskIdentifier background_task; //Create a task object
    
}

#pragma mark - Singleton methods
+(GeoManager*)sharedManager {
    
    static GeoManager *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    
    self = [super init];
    
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUsageType) name:GTApplicationDidUpdateUsageType object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIntervalValue) name:GTApplicationDidUpdateInterval object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDesiredAccuracyValue) name:GTApplicationDidUpdateAccuracy object:nil];
        
        defaults = [NSUserDefaults standardUserDefaults];
        locationManagerTick = [defaults floatForKey:SMLocationCheckInterval];
        desiredAccuracy = [defaults integerForKey:SMDesiredAccuracy];
        
        initialLocate = YES;
        
        [self startLocationManagerTimer];
    
    }

    return self;
}

-(void)setUsageType {
    
    int usageType = [defaults integerForKey:GTApplicationUsageTypeKey];
    
    switch (usageType) {
        case GTAppSettingsUsageTypeCar:
            [locationManager setActivityType:CLActivityTypeAutomotiveNavigation];
            break;
            
        case GTAppSettingsUsageTypeWalk:
            [locationManager setActivityType:CLActivityTypeFitness];
            break;
        
        case GTAppSettingsUsageTypeMix:
            [locationManager setActivityType:CLActivityTypeOther];
            break;
    }
    
}

-(void)setIntervalValue {
    locationManagerTick = [defaults floatForKey:SMLocationCheckInterval];
}

-(void)setDesiredAccuracyValue {
    desiredAccuracy = [defaults floatForKey:SMDesiredAccuracy];
    [locationManager setDesiredAccuracy:[defaults integerForKey:SMDesiredAccuracy]];
}

#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //Store the current location in the property for easy access
    
    CLLocation *location = (CLLocation *)[locations lastObject];
    
    DLog(@"Updating location");
    
    if(location.horizontalAccuracy < desiredAccuracy){
        
        self.currentLocation = (CLLocation *)[locations lastObject];
        self.previousLocation = previousLocation ? previousLocation : nil;
        self.speed = self.currentLocation.speed;
        self.elevation = self.currentLocation.altitude;
        
        //Update any observers
        [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationUpdatedSuccessfully object:nil];
        [self stopTrackingPosition];
        
        DLog(@"Killing location manager");

        previousLocation = location;
        
        initialLocate = NO;

    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    //Convert Degree to Radian and move the needle
	self.fromHeadingAsRad =  -manager.heading.trueHeading * M_PI / 180.0f;
	self.toHeadingAsRad =  -newHeading.trueHeading * M_PI / 180.0f;

    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationHeadingDidUpdate object:nil];
    
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
    [self stopTrackingPosition];
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationDidPauseUpdates object:nil];
    
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
    [self startTrackingPosition];
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationDidResumeUpdates object:nil];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationLocationUpdatesDidFail object:nil];
}

-(void)startLocationManagerTimer {
    
    //Configure the settings, accuracy etc.
    locationManagerTimer = [NSTimer scheduledTimerWithTimeInterval:locationManagerTick
                                                            target:self
                                                          selector:@selector(startTrackingPosition)
                                                          userInfo:nil
                                                           repeats:YES];
    [locationManagerTimer fire];

}

-(void)stopLocationManagerTimer {
    
    [locationManagerTimer invalidate];
    locationManagerTimer = nil;
}


#pragma LocationManager methods
-(void)startTrackingPosition {
    
    //Begin tracking the users location and sending notifications on change
    if(!locationManager){
        
        //Create an instance of CLLocation manager for the manager to use
        locationManager = [CLLocationManager new];
        
        [locationManager setDistanceFilter:[defaults floatForKey:SMLocationCheckInterval]];
        [locationManager setDesiredAccuracy:[defaults integerForKey:SMDesiredAccuracy]];
        [locationManager setDelegate:self];
        [locationManager setPausesLocationUpdatesAutomatically:YES];
        
        if ([defaults integerForKey:GTApplicationUsageTypeKey]) {
            [self setUsageType];
        }else{
            [locationManager setActivityType:CLActivityTypeFitness];
        }
    }
    
    [locationManager startUpdatingLocation];
    
    [self beginHeadingUpdates];
    
}

-(void)stopTrackingPosition {
    [locationManager stopUpdatingLocation];
    locationManager = nil;
}

-(void)beginHeadingUpdates {
    [locationManager startUpdatingHeading];
}

-(float)currentSpeed {
    return self.speed;
}

-(float)currentElevation {
    return self.elevation;
}

-(BOOL)locationServicesEnabled {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager locationServicesEnabled] == NO) {
        return NO;
    }else{
        return YES;
    }
}

-(void)killAllLocationServices {
    
    [locationManagerTimer invalidate];
    locationManagerTimer = nil;
    
    background_task = UIBackgroundTaskInvalid;
    background_task = nil;
    
}

-(void)setBackgroundMode:(BOOL)backgroundMode {

    if(backgroundMode){
        
        [self stopLocationManagerTimer];
        [locationManager stopUpdatingHeading];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
            if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
                
                UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
               
                background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                    [application endBackgroundTask:background_task]; //Tell the system that we are done with the tasks
                }];
                    
                self.backgroundLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:locationManagerTick target:self
                                                                                        selector:@selector(startTrackingPosition) userInfo:nil repeats:YES];
            }
        }
                
    }else{
        
        TripManager *tripManager = [TripManager sharedManager];
        
        background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
        
        if([tripManager.currentTrip.recordingState isEqualToString:[[TripManager sharedManager] recordingStateForState:GTTripStateRecording]]){
            [self startLocationManagerTimer];
            [locationManager startUpdatingHeading];
        }
    }
}

@end
