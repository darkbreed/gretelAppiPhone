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

@class GeoManager;

@interface GeoManager : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    
}

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) id delegate;
@property (nonatomic, readwrite) BOOL recording;

+(GeoManager*)sharedManager;
-(void)startTrackingPosition;
-(void)stopTrackingPosition;

@end
