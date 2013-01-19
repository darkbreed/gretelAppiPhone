//
//  GeoManager.m
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "GeoManager.h"

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
    
    if(self != nil){
        
        locationManager = [[CLLocationManager alloc] init];
        [self configureLocationManager];
    }
    
    return self;
}

-(void)configureLocationManager {
    
    [locationManager setDistanceFilter:25.0];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    
}


#pragma mark CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //Store the current location in the property for easy access
    self.currentLocation = (CLLocation *)[locations lastObject];
    
    //Update any observers
    [self notifyObserversOfLocationUpdate];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

#pragma LocationManager methods
-(void)startTrackingPosition {
    
    if(!self.recording){
        
        [locationManager startUpdatingLocation];
        [self notifyObserversOfLocationUpdate];
        
        self.recording = YES;
    
    }
    
}

-(void)stopTrackingPosition {
    
    [locationManager stopUpdatingLocation];
    self.recording = NO;
    
}

-(void)notifyObserversOfLocationUpdate {
    //Post a notfication to update observers
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedSuccessfully object:nil];
}


@end
