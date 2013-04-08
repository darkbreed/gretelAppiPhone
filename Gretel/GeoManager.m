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

@implementation GeoManager {
    
    NSUserDefaults *defaults;
    
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
        
        //Create an instance of CLLocation manager for the manager to use
        locationManager = [[CLLocationManager alloc] init];
        
        //Configure the settings, accuracy etc.
        [self configureLocationManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUsageType) name:GTApplicationDidUpdateUsageType object:nil];
        
        defaults = [NSUserDefaults standardUserDefaults];
        
    }
    
    
    return self;
}

/**
 * Configures the managers settings
 * @return void
 */
-(void)configureLocationManager {
    
    [locationManager setDistanceFilter:10.0];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager setPausesLocationUpdatesAutomatically:YES];
    [locationManager setHeadingFilter:1];
    
    if ([defaults integerForKey:GTApplicationUsageTypeKey]) {
        [self setUsageType];
    }else{
        [locationManager setActivityType:CLActivityTypeFitness];
    }
    
    //Locate the user
    //[locationManager startUpdatingLocation];
    //[locationManager startUpdatingHeading];
    
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

#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //Store the current location in the property for easy access
    self.currentLocation = (CLLocation *)[locations lastObject];
    self.speed = self.currentLocation.speed;
    
    //Update any observers
    [self notifyObserversOfLocationUpdate];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    //Convert Degree to Radian and move the needle
	self.fromHeadingAsRad =  -manager.heading.trueHeading * M_PI / 180.0f;
	self.toHeadingAsRad =  -newHeading.trueHeading * M_PI / 180.0f;
    
    //NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, self.fromHeadingAsRad, newHeading.trueHeading, self.toHeadingAsRad);
    
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationHeadingDidUpdate object:nil];
    
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
    [self stopTrackingPosition];
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationDidPauseUpdates object:nil];
    
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Post a notfication to update observers that updates have failed
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationLocationUpdatesDidFail object:nil];
}


#pragma LocationManager methods
-(void)startTrackingPosition {
    
    //Begin tracking the users location and sending notifications on change
    [locationManager startUpdatingLocation];
    
}

-(void)stopTrackingPosition {
    
    [locationManager stopUpdatingLocation];
    
}

-(void)notifyObserversOfLocationUpdate {
    //Post a notfication to update observers
    [[NSNotificationCenter defaultCenter] postNotificationName:GTLocationUpdatedSuccessfully object:nil];
}

-(float)currentSpeed {
    return self.speed;
}

-(BOOL)locationServicesEnabled {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager locationServicesEnabled] == NO) {
        return NO;
    }else{
        return YES;
    }
}

@end
