//
//  TripManager.m
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripManager.h"

@implementation TripManager {
    NSManagedObjectContext *context;
    int currentPointId;
}

#pragma mark - Singleton methods
+(TripManager*)sharedManager {
    
    static TripManager *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    
    self = [super init];
    
    if(self != nil){
        
        context = [NSManagedObjectContext contextForCurrentThread];
        currentPointId = 0;
        
        [self fetchAllTrips];
        
    }
    
    return self;
}

-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath {
    
    return [self.allTrips objectAtIndexPath:tripIndexPath];
    
}

-(void)deleteTripAtIndexPath:(NSIndexPath *)tripIndexPath {
    
    Trip *trip = [self.allTrips objectAtIndexPath:tripIndexPath];
    [trip deleteInContext:context];
}

-(void)searchTripsByKeyword:(NSString *)keyword {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@",keyword];
    self.allTrips = [Trip fetchAllGroupedBy:@"displayDate" withPredicate:predicate sortedBy:@"startDate" ascending:NO];
}

-(void)fetchAllTrips {
    
    //self.allTrips = [[Trip findAllSortedBy:@"startDate" ascending:NO] mutableCopy];
    self.allTrips = [Trip fetchAllGroupedBy:@"displayDate" withPredicate:nil sortedBy:@"startDate" ascending:NO];
    
}

-(void)createNewTripWithName:(NSString *)name {
    
    self.currentTrip = [Trip createInContext:context];
    currentPointId = 0;
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd yyyy"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:now];
    [self.currentTrip setDisplayDate:formattedDateString];
    
    //Create a new trip object and save it
    [self.currentTrip setStartDate:now];
    [self.currentTrip setTripName:name];
    
}

-(void)stopRecording {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    [self saveTrip];
}

-(void)pauseRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self setTripState:GTTripStatePaused];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    [self saveTrip];
}

-(void)beginRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStateRecording]];
    [self setTripState:GTTripStateRecording];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [self saveTrip];
    
}

-(void)saveTrip {
    
    //Save
    [context saveNestedContexts];
}

-(void)saveTripAndStop {
    
    [self.currentTrip setFinishDate:[NSDate date]];
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    
    [self setCurrentTrip:nil];
    [self setTripState:GTTripStateNew];
    
    [self saveTrip];
    
    [self fetchAllTrips];
    
}

-(NSArray *)fectchPointsForDrawing {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointID" ascending:NO];
    NSArray *sortedPoints = [self.currentTrip.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return sortedPoints;
    
}

-(void)storeLocation{
    
    CLLocation *location = [GeoManager sharedManager].currentLocation;
    
    if(location.coordinate.latitude != 0.0){
        //Create the GPS point
        GPSPoint *point = [GPSPoint MR_createEntity];
        point.altitude = [NSNumber numberWithDouble:location.altitude];
        point.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        point.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        point.timestamp = [NSDate date];
        point.pointID = [NSNumber numberWithInt:currentPointId++];
        
        //Add it to the current trip for storage
        [self.currentTrip addPointsObject:point];
        
        //Save
        [context saveNestedContextsErrorHandler:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }
}

-(NSString *)recordingStateForState:(GTTripState)state {
    
    switch (state) {
        case GTTripStatePaused:
            return @"paused";
        case GTTripStateRecording:
            return @"recording";
        case GTTripStateNew:
            return @"stopped";
    }
    
}

@end
