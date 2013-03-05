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
        
        self.allTrips = [[Trip findAllSortedBy:@"startDate" ascending:NO] mutableCopy];
        
    }
    
    return self;
}

-(Trip *)tripWithIndex:(int)tripIndex {
    
    return [self.allTrips objectAtIndex:tripIndex];
    
}

-(void)deleteTripAtIndex:(int)tripIndex {
    
    [[self.allTrips objectAtIndex:tripIndex] deleteInContext:[NSManagedObjectContext defaultContext]];
    [self.allTrips removeObjectAtIndex:tripIndex];
    //Save
    [[NSManagedObjectContext defaultContext] saveNestedContextsErrorHandler:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
    
}

-(void)createNewTripWithName:(NSString *)name {
    
    self.currentTrip = [Trip createInContext:context];
    currentPointId = 0;
        
    //Create a new trip object and save it
    [self.currentTrip setStartDate:[NSDate date]];
    [self.currentTrip setTripName:name];
    [self saveTrip];
    
}

-(void)stopRecording {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    [self saveTrip];
}

-(void)pauseRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self saveTrip];
    
    [self setTripState:GTTripStatePaused];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    
}

-(void)beginRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStateRecording]];
    [self saveTrip];
    [self setTripState:GTTripStateRecording];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}

-(void)saveTrip {
    
    NSError *error;
    
    //Save
    [[NSManagedObjectContext defaultContext] saveNestedContextsErrorHandler:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
}

-(void)saveTripAndStop {
    
    [self.currentTrip setFinishDate:[NSDate date]];
    [self saveTrip];
    
    [self setCurrentTrip:nil];
    [self setTripState:GTTripStateNew];
    
    [self saveTrip];
    
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
        [[NSManagedObjectContext defaultContext] saveNestedContextsErrorHandler:^(NSError *error) {
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
