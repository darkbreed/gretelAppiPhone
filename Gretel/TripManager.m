//
//  TripManager.m
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripManager.h"

NSString * const GTTripTimerDidUpdate = @"tripTimerDidUpdate";
NSString * const GTTripDeletedSuccess = @"tripDeletedSucessfully";

@implementation TripManager {
    int currentPointId;
    
    //Trip Timer varibles
    //BOOL tripTimerIsRunning;
    NSTimeInterval secondsElapsedForTrip;
    NSDate *startDate;
    NSTimer *stopWatchTimer;
    
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
        
        currentPointId = 0;
        self.isResuming = NO;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        self.allTrips = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:self.managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    }
    
    return self;
}

-(void)importTripFromGPXFile:(NSURL *)url {
    
    GPXRoot *root = [GPXParser parseGPXAtURL:url];
    NSLog(@"Trip manager RootGPX %@",root);
    
}

- (void)didReceiveNewURL:(NSNotification *)notification {
    
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

-(void)deleteTrips:(NSArray *)trips {
    
    //Loop over the index paths
    for(NSIndexPath *indexPath in trips){
        
        //Load the trip object
        Trip *trip = [self.allTrips objectAtIndexPath:indexPath];
        
        //Check if any are recording and reset the app badge
        if([trip.recordingState isEqualToString:[self recordingStateForState:GTTripStateRecording]]){
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
        
        //Grab the file URL from the object...
        NSString *filePath = [trip gpxFilePath];
        NSError *error = nil;
        
        //...and delete it
        NSURL *url = [NSURL URLWithString:filePath];
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
        
        //If the file deleted ok, remove the object from CoreData
        if(!error){
            //Delete the trip
            [self.managedObjectContext deleteObject:trip];
            
        }else{
            NSLog(@"There was an error deleting the file:%@ - %@",filePath,[error localizedDescription]);
        }
        
    }
    
    //Notify observers
    [[NSNotificationCenter defaultCenter] postNotificationName:GTTripDeletedSuccess object:nil];
    
    //Commit the changes to core data
    [self saveTrip];
   
}

-(void)deleteTrip:(Trip *)trip {
    
    //Reset the app badge
    if([trip.recordingState isEqualToString:[self recordingStateForState:GTTripStateRecording]]){
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    //Commit the change to the context
    [self.managedObjectContext deleteObject:trip];
    
    //Notify observers
    [[NSNotificationCenter defaultCenter] postNotificationName:GTTripDeletedSuccess object:nil];
}

-(void)searchTripsByKeyword:(NSString *)keyword {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@",keyword];
    [self.allTrips.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    [self.allTrips performFetch:&error];
}

-(void)fetchAllTrips {

    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error = nil;
    [self.allTrips performFetch:&error];
}

-(void)createNewTripWithName:(NSString *)name {
    
    self.currentTrip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:self.managedObjectContext];
    currentPointId = 0;
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd yyyy"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:now];
    [self.currentTrip setDisplayDate:formattedDateString];
    
    //Create a new trip object and save it
    [self.currentTrip setStartDate:now];
    [self.currentTrip setTripName:name];
    
    [self saveTrip];
    
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
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Error saving context");
    }
}

-(void)pauseRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self setTripState:GTTripStatePaused];
    [self stopTimer];
    
    self.currentTrip.totalDistance = [NSNumber numberWithFloat:[self calculateDistanceForPoints:self.currentTrip]];
    [self saveTrip];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
}


-(void)saveTripAndStop {
    
    [self.currentTrip setFinishDate:[NSDate date]];
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self.currentTrip setTotalDistance:[NSNumber numberWithFloat:[self calculateDistanceForPoints:self.currentTrip]]];
    
    [self saveTrip];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
    
    [self createGPXFileFromTrip:self.currentTrip];
    [self setCurrentTrip:nil];
    [self setTripState:GTTripStateNew];
    
    [self stopTimer];
    
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
        
        // Create and configure a new instance of the GPS entity.
        GPSPoint *point = (GPSPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GPSPoint" inManagedObjectContext:self.managedObjectContext];
        point.altitude = [NSNumber numberWithDouble:location.altitude];
        point.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        point.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        point.timestamp = [NSDate date];
        point.pointID = [NSNumber numberWithInt:currentPointId++];
        
        //Add it to the current trip for storage
        [self.currentTrip addPointsObject:point];
        
        //Save
        
        [self saveTrip];
        
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


#pragma mark GPX File Creation Methods
-(NSString *)applicationDocumentsDirectoryBasePath
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
    NSArray *invalidCharacters = [NSArray arrayWithObjects:@"/",@"\\",@"?",@"%",@"*",@"|",@"\"",@"<",@">",@" ",@":",nil];
    
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
    
    return [[self applicationDocumentsDirectoryBasePath] stringByAppendingPathComponent:fileName];
}

-(void)updateFileWithName:(NSString *)newName forTrip:(Trip *)trip {
    
}

-(void)createGPXFileFromTrip:(Trip *)trip {
    
    GPXRoot *root = [GPXRoot rootWithCreator:@"Gretel"];
    GPXTrack *track = [root newTrack];
    track.name = trip.tripName;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pointID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *points = [trip.points sortedArrayUsingDescriptors:sortDescriptors];
    
    for (GPSPoint *point in points) {
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

#pragma mark Timer Methods
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

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Gretel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TestCoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
