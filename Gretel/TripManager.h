//
//  TripManager.h
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"
#import "GPSPoint.h"

/**
 * Defines the states that a trip can exist in to help determine how the view should behave.
 */
typedef enum {
    kTripStateNew,
    kTripStateRecording,
    kTripStatePaused
} kTripState;

@interface TripManager : NSObject

@property (nonatomic, readwrite) BOOL isRecording;

///Current trip state
@property (nonatomic, readwrite) kTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;

+(TripManager*)sharedManager;

-(void)setCurrentTripState:(kTripState)tripState;

@end
