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
        
        context = [NSManagedObjectContext MR_contextForCurrentThread];
        currentPointId = 0;
        
    }
    
    return self;
}

-(void)createNewTrip {
    
    self.currentTrip = [Trip MR_createInContext:context];
    currentPointId = 0;
    
}

-(void)setCurrentTripState:(kTripState)tripState {
    self.tripState = tripState;
}

-(void)resumeRecording {
    
}

-(void)stopRecording {
    [self setIsRecording:NO];
}

-(void)pauseRecording {
    [self setIsRecording:NO];
    [self setCurrentTripState:kTripStatePaused];
}

-(void)beginRecording {
    [self setIsRecording:YES];
    [self setCurrentTripState:kTripStateRecording];
}

-(void)saveTrip {
    
    NSError *error;
    [context save:&error];
    
    if(error){
        NSLog(@"Error: %@",error.description);
    }
    
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
        [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContextsErrorHandler:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }
}

@end
