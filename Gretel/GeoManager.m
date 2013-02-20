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

@implementation GeoManager

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
        
        //Create an instance of CLLocation manager for the manager to use
        locationManager = [[CLLocationManager alloc] init];
        
        //Configure the settings, accuracy etc.
        [self configureLocationManager];
    }
    
    return self;
}

/**
 * Configures the managers settings
 * @return void
 */
-(void)configureLocationManager {
    
    [locationManager setDistanceFilter:25.0];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    [locationManager setHeadingFilter:1];
    
}

#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //Store the current location in the property for easy access
    self.currentLocation = (CLLocation *)[locations lastObject];
    self.currentSpeed = self.currentLocation.speed;
    
    //Update any observers
    [self notifyObserversOfLocationUpdate];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    //Convert Degree to Radian and move the needle
	self.fromHeadingAsRad =  -manager.heading.trueHeading * M_PI / 180.0f;
	self.toHeadingAsRad =  -newHeading.trueHeading * M_PI / 180.0f;
    
    NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, self.fromHeadingAsRad, newHeading.trueHeading, self.toHeadingAsRad);
    
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationHeadingDidUpdate object:nil];
    
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
#warning TODO: Handle pauses
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
#warning TODO: Handle resumes
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationLocationUpdatesDidFail object:nil];
}

#pragma LocationManager methods
-(void)startTrackingPosition {
    
    if(!self.recording){
        
        //Begin tracking the users location and sending notifications on change
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        [self notifyObserversOfLocationUpdate];
        
        //Update the recording state
        self.recording = YES;
    
    }
    
}

-(void)stopTrackingPosition {
    
    [locationManager stopUpdatingLocation];
    self.recording = NO;
    
}

-(void)notifyObserversOfLocationUpdate {
    //Post a notfication to update observers
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationUpdatedSuccessfully object:nil];
}


@end
