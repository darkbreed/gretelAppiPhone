//
//  TripManager.m
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripManager.h"

NSString * const GTTripTimerDidUpdate = @"tripTimerDidUpdate";

@implementation TripManager {
    NSManagedObjectContext *context;
    int currentPointId;
    
    //Timer varibles
    BOOL timerIsRunning;
    NSTimeInterval secondsElapsedForTrip;
    NSDate *startDate;
    NSTimer *stopWatchTimer;
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
        
        self.isResuming = NO;
        
        [self fetchAllTrips];
        
    }
    
    return self;
}

-(void)importTripFromGPXFile:(NSURL *)url {
    
    GPXRoot *root = [GPXParser parseGPXAtURL:url];
    NSLog(@"Trip manager RootGPX %@",root);
    
}

- (void)didReceiveNewURL:(NSNotification *)notification
{
    
}

-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath {
    
    return [self.allTrips objectAtIndexPath:tripIndexPath];
    
}

-(float)calculateDistanceForPoints:(Trip *)trip {
    
    CLLocationDistance totalDistance = 0.0f;

    NSArray *points = [trip.points allObjects];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointID" ascending:YES];
    NSArray *sortedPoints = [points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];;
    
    if([sortedPoints count] > 0){
        
        GPSPoint *startPoint = [sortedPoints objectAtIndex:0];
        GPSPoint *nextPoint = nil;
        
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[startPoint.lat floatValue] longitude:[startPoint.lon floatValue]];
        CLLocation *nextLocation = nil;
        
        int count = [sortedPoints count];
        
        for (int i = 0; i < count; i++) {
            if(i > 0 && i < count){
            
                nextPoint = [sortedPoints objectAtIndex:i];
                nextLocation = [[CLLocation alloc] initWithLatitude:[nextPoint.lat floatValue] longitude:[nextPoint.lon floatValue]];
                totalDistance += [startLocation distanceFromLocation:nextLocation];
                startLocation = nextLocation;
               
            }
        }
        
        CLLocationDistance distance = 0.0f;
            
        if([[SettingsManager sharedManager] unitType] == GTAppSettingsUnitTypeMPH){
            distance = totalDistance * [[SettingsManager sharedManager] distanceMultiplier];
        }else{
            distance = totalDistance / [[SettingsManager sharedManager] distanceMultiplier];
        }
        
        return distance;
        
    }else{
        return 0.0;
    }
}

-(void)deleteTripAtIndexPath:(NSIndexPath *)tripIndexPath {
    
    Trip *trip = [self.allTrips objectAtIndexPath:tripIndexPath];
    
    if([trip.recordingState isEqualToString:[self recordingStateForState:GTTripStateRecording]]){
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    }
    
    [trip deleteInContext:context];
    
    [context save];
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
    [self saveTrip];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
}

-(void)pauseRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self setTripState:GTTripStatePaused];
    [self stopTimer];
    
    self.currentTrip.totalDistance = [NSNumber numberWithFloat:[self calculateDistanceForPoints:self.currentTrip]];
    [self saveTrip];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
}

-(void)beginRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStateRecording]];
    [self setTripState:GTTripStateRecording];
    secondsElapsedForTrip = [[self.currentTrip tripDuration] floatValue];
    [self startTimer];
    [self saveTrip];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}

-(void)saveTrip {
    
    //Save
    [context saveNestedContexts];
}

-(void)saveTripAndStop {
    
    [self.currentTrip setFinishDate:[NSDate date]];
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    [self createGPXFileFromTrip:self.currentTrip];
    [self setCurrentTrip:nil];
    [self setTripState:GTTripStateNew];
    
    //Re-fectch the trips
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

-(void)storeLocation {
    
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

-(NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSString *)applicationTempDirectory
{
    return NSTemporaryDirectory();
}

- (NSString *)gpxFilePathWithName:(NSString *)tripName {
    
    //Clean the trip name
    NSArray *invalidCharacters = [NSArray arrayWithObjects:@"/",@"\\",@"?",@"%",@"*",@"|",@"\"",@"<",@">",@" ",nil];
    
    NSString *cleanName = tripName;
    
    for (NSString *invalidChar in invalidCharacters) {
        NSString *tmp = [cleanName stringByReplacingOccurrencesOfString:invalidChar withString:@""];
        cleanName = tmp;
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_log_%@.gpx", cleanName, dateString];
    
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
}

-(void)createGPXFileFromTrip:(Trip *)trip {
    
    GPXRoot *root = [GPXRoot rootWithCreator:@"Gretel"];
    GPXTrack *track = [root newTrack];
    track.name = trip.tripName;
    
    for (GPSPoint *point in trip.points) {
        GPXTrackPoint *gpxTrackPoint = [track newTrackpointWithLatitude:[point.lat floatValue] longitude:[point.lon floatValue]];
        gpxTrackPoint.elevation = [point.altitude floatValue];
        gpxTrackPoint.time = point.timestamp;
    }
            
    NSURL *gpxURL = [NSURL fileURLWithPath:[self gpxFilePathWithName:trip.tripName]];
    
    GPXDocument *document = [[GPXDocument alloc] initWithFileURL:gpxURL];
    document.gpxString = root.gpx;
    
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        trip.gpxFilePath = [gpxURL absoluteString];
        [self saveTrip];
    }];
}

#pragma mark trip timer methods
-(void)updateTimer {
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    
    // Add the saved interval
    timeInterval += secondsElapsedForTrip;
    
    [self.currentTrip setTripDuration:[NSNumber numberWithFloat:timeInterval]];
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.timerValue = timeString;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTTripTimerDidUpdate object:nil];
    
}

- (void)startTimer {
    
    stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1/10
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    // Save the new start date every time
    startDate = [stopWatchTimer fireDate];
}

- (void)stopTimer {
    
    secondsElapsedForTrip += [[NSDate date] timeIntervalSinceDate:startDate];
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    
}

- (void)resetTimer {
    secondsElapsedForTrip = 0;
}

@end
