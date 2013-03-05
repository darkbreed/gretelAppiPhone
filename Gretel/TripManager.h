//
//  TripManager.h
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Trip.h"
#import "GPSPoint.h"
#import "GeoManager.h"

/**
 * Defines the states that a trip can exist in to help determine how the view should behave.
 */
typedef enum {
    GTTripStateNew,
    GTTripStateRecording,
    GTTripStatePaused
} GTTripState;

@interface TripManager : NSObject

///Current trip state
@property (nonatomic, readwrite) GTTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;
///All trips
@property (nonatomic, strong) NSFetchedResultsController *allTrips;

+(TripManager*)sharedManager;

-(void)fetchAllTrips;
-(void)beginRecording;
-(void)stopRecording;
-(void)pauseRecording;
-(void)saveTrip;
-(void)saveTripAndStop;
-(void)createNewTripWithName:(NSString *)name;
-(void)storeLocation;
-(NSArray *)fectchPointsForDrawing;
-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath;
-(void)deleteTripAtIndexPath:(NSIndexPath *)tripIndexPath;
-(NSString *)recordingStateForState:(GTTripState)state;
-(void)searchTripsByKeyword:(NSString *)keyword;

@end
