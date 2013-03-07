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
    NSTimer *tripTimer;
    NSDateFormatter *timerFormatter;
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
        
        timerFormatter = [[NSDateFormatter alloc] init];
        [timerFormatter setDateFormat:@"HH : mm : ss"];
        
        [self fetchAllTrips];
        
    }
    
    return self;
}

-(void)updateTimer {
    
}

-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath {
    
    return [self.allTrips objectAtIndexPath:tripIndexPath];
    
}

-(float)calculateDistanceForPoints:(Trip *)trip {
    
    CLLocationDistance totalDistance = 0.0f;
    NSArray *points = [trip.points allObjects];
    
    GPSPoint *startPoint = [[trip.points allObjects] objectAtIndex:0];
    GPSPoint *nextPoint = nil;
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[startPoint.lat floatValue] longitude:[startPoint.lon floatValue]];
    CLLocation *nextLocation = nil;
    
    int count = [points count];
    
    for (int i = 0; i < count; i++) {
        if(i > 0 && i < count){
            
            nextPoint = [points objectAtIndex:i];
            
            nextLocation = [[CLLocation alloc] initWithLatitude:[nextPoint.lat floatValue] longitude:[nextPoint.lon floatValue]];
            totalDistance += [startLocation distanceFromLocation:nextLocation];

            startPoint = nextPoint;
            
        }
    }
    
    if([[SettingsManager sharedManager] unitType] == GTAppSettingsUnitTypeMPH){
        return totalDistance * [[SettingsManager sharedManager] distanceMultiplier];
    }else{
        return totalDistance / [[SettingsManager sharedManager] distanceMultiplier];
    }
    
}

-(void)deleteTripAtIndexPath:(NSIndexPath *)tripIndexPath {
    
    Trip *trip = [self.allTrips objectAtIndexPath:tripIndexPath];
    [trip deleteInContext:context];
    [context saveNestedContexts];
}

-(void)searchTripsByKeyword:(NSString *)keyword {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@",keyword];
    self.allTrips = [Trip fetchAllGroupedBy:@"displayDate" withPredicate:predicate sortedBy:@"startDate" ascending:NO];
}

-(void)fetchAllTrips {

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
    
//    //Create and save a GPX file
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *extension = @"gpx";
//    
//    NSString *trimPunctuation = [self.currentTrip.tripName stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
//    NSString *trimWhiteSpace = [trimPunctuation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSString *fileURLString = [[documentsDirectory stringByAppendingPathComponent:trimWhiteSpace] stringByAppendingPathExtension:extension];
//
//    NSURL *fileURL = [NSURL fileURLWithPath:fileURLString];
//    
//    UIDocument *document = [[UIDocument alloc] initWithFileURL:fileURL];
//    
//    
//    //Convert the trip into the GPX file format
//    GPXFactory *factory = [[GPXFactory alloc] init];
//    NSString *gpx = [factory createGPXFileFromGPSPoints:self.currentTrip.points];
//    
//    NSError *error = nil;
//    
//    if(gpx){
//        [document writeContents:[gpx dataUsingEncoding:NSUTF8StringEncoding] toURL:fileURL forSaveOperation:UIDocumentSaveForCreating originalContentsURL:fileURL error:&error];
//        
//        [document saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            NSLog(@"Saved to %@",fileURL);
//        }];
//    }
    
    [self setCurrentTrip:nil];
    [self setTripState:GTTripStateNew];
    
    [self saveTrip];
    
    [self fetchAllTrips];
    
}

-(NSArray *)fectchPointsForDrawing:(BOOL)forDetailView {
   
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointID" ascending:NO];
    
    NSArray *sortedPoints = nil;
    
    if(forDetailView){
        sortedPoints = [self.tripForDetailView.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }else{
        sortedPoints = [self.currentTrip.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
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
