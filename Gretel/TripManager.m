//
//  TripManager.m
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripManager.h"
#import "TripUtilities.h"
#import "TripIO.h"

NSString * const GTTripTimerDidUpdate = @"tripTimerDidUpdate";
NSString * const GTTripDeletedSuccess = @"tripDeletedSucessfully";
NSString * const GTCurrentTripDeleted = @"deltedCurrentTrip";
NSString * const GTTripImportedSuccessfully = @"tripImportedSuccessfully";
NSString * const GTTripSavedSuccessfully = @"tripSavedSuccessfully";
NSString * const GTTripUpdatedDistance = @"updatedDistance";
NSString * const GTTripGotoInbox = @"gotoInbox";

const float interval = 30.0;
const float desiredDistanceBetweenPoints = 5.0;

@implementation TripManager {
    
    int currentPointId;
    
    //Trip Timer varibles
    NSTimeInterval secondsElapsedForTrip;
    NSDate *startDate;
    NSTimer *stopWatchTimer;
    NSTimer *recordingTimer;
    NSTimer *distanceTimer;
    
    Trip *importedTrip;
    
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    }
    
    return self;
}

-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath {
    
    return [self.allTrips objectAtIndexPath:tripIndexPath];
    
}

-(void)updateDistance {
    self.currentTrip.totalDistance = [NSNumber numberWithFloat:[TripUtilities calculateDistanceForPointsInMetres:self.currentTrip]];
    [[NSNotificationCenter defaultCenter] postNotificationName:GTTripUpdatedDistance object:nil];
}

-(void)deleteTrips:(NSArray *)trips {
    
    //Loop over the index paths
    for(NSIndexPath *indexPath in trips){
        
        //Load the trip object
        Trip *trip = [self.allTrips objectAtIndexPath:indexPath];
        
        //Check if any are recording
        if([trip.recordingState isEqualToString:[self recordingStateForState:GTTripStateRecording]]){
            [self pauseRecording];
            [[NSNotificationCenter defaultCenter] postNotificationName:GTCurrentTripDeleted object:nil];
        }
        
        //Grab the file URL from the object...
        NSString *filePath = [trip gpxFilePath];
        NSError *error = nil;
        
        //...and delete it
        NSURL *url = [NSURL URLWithString:filePath];
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
        
        //Delete the trip
        [self.managedObjectContext deleteObject:trip];

    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
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

-(void)searchTripsByKeyword:(NSString *)keyword shouldReturnInboxResults:(BOOL)returnInboxResults {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSPredicate *predicate = nil;
    
    if (returnInboxResults) {
        predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@ && receivedFromRemote = %@",keyword,[NSNumber numberWithBool:YES]];
        [self.allTrips.fetchRequest setPredicate:predicate];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@ && receivedFromRemote = %@",keyword,[NSNumber numberWithBool:NO]];
        [self.allTrips.fetchRequest setPredicate:predicate];
    }

    NSError *error = nil;
    [self.allTrips performFetch:&error];
}

-(void)fetchAllTrips {

    [NSFetchedResultsController deleteCacheWithName:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receivedFromRemote = %@",[NSNumber numberWithBool:NO]];

    [self.allTrips.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    [self.allTrips performFetch:&error];
    
}

-(void)fetchInbox {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receivedFromRemote = %@",[NSNumber numberWithBool:YES]];
    [self.allTrips.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    [self.allTrips performFetch:&error];
    
}

-(void)resetRecordingStateForAllTrips {
    
    [self fetchAllTrips];
    
    for (Trip *trip in self.allTrips.fetchedObjects) {
        trip.recordingState = [self recordingStateForState:GTTripStatePaused];
    }
    
    [self saveTrip];
}

-(void)createNewTripWithName:(NSString *)name {
    
    //Check all other trips to see if any are still marked in progress
    [self resetRecordingStateForAllTrips];
    
    self.currentTrip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:self.managedObjectContext];
    currentPointId = 0;
    
    self.pointsForDrawing = [NSMutableArray array];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd yyyy"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:now];
    [self.currentTrip setDisplayDate:formattedDateString];
    
    //Create a new trip object and save it
    [self.currentTrip setStartDate:now];
    [self.currentTrip setTripName:name];
    [self.currentTrip setReceivedFromRemote:[NSNumber numberWithBool:NO]];
    
}

-(void)beginRecording {
    
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStateRecording]];
    [self setTripState:GTTripStateRecording];
    secondsElapsedForTrip = [[self.currentTrip tripDuration] floatValue];
    
    [self startTimer];
    
    [[GeoManager sharedManager] startLocationManagerTimer];
    
}

-(void)updateLocation {
    
    if(self.tripState == GTTripStateRecording){
        //Store the data point
        [self storeLocation];
    }
}

-(void)saveTrip {
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
    }
}

-(void)pauseRecording {
            
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self setTripState:GTTripStatePaused];
    [self stopTimer];
    
    self.currentTrip.totalDistance = [NSNumber numberWithFloat:[TripUtilities calculateDistanceForPointsInMetres:self.currentTrip]];
    
    [recordingTimer invalidate];
    recordingTimer = nil;
    
    [self saveTrip];
    
    [[GeoManager sharedManager] stopLocationManagerTimer];
    
}


-(void)saveTripAndStop {

    [self.currentTrip setFinishDate:[NSDate date]];
    [self.currentTrip setRecordingState:[self recordingStateForState:GTTripStatePaused]];
    [self.currentTrip setTotalDistance:[NSNumber numberWithFloat:[TripUtilities calculateDistanceForPointsInMetres:self.currentTrip]]];
    
    [recordingTimer invalidate];
    recordingTimer = nil;
    
    [self stopTimer];
    [self saveTrip];
    
    __weak TripManager *weakSelf = self;
    
    TripIO *tripIO = [TripIO new];
    [tripIO createGPXFileFromTrip:self.currentTrip withSuccessBlock:^(NSString *gpxFilePath) {
        
        weakSelf.currentTrip.gpxFilePath = gpxFilePath;
        
        [weakSelf setCurrentTrip:nil];
        [weakSelf setTripState:GTTripStateNew];
        
        weakSelf.pointsForDrawing = nil;
        
        [[GeoManager sharedManager] stopLocationManagerTimer];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:GTTripSavedSuccessfully object:nil];
    
    } andFailureBlock:^(NSError *error) {
        
        [[GeoManager sharedManager] stopLocationManagerTimer];

    }];

}

-(NSArray *)fectchPointsForDrawing:(BOOL)forDetailView {
   
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointID" ascending:NO];

    if(forDetailView){
        //If loading a detail view, load the points in one hit from core data
        return [self.tripForDetailView.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }else{
        //else get the points from memory when drawing a live map
        return [self.pointsForDrawing sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
}

-(void)storeLocation {
    
    CLLocation *location = [GeoManager sharedManager].currentLocation;
    CLLocation *previousLocation = [GeoManager sharedManager].previousLocation;

    if(!previousLocation){
        
        // Create and configure a new instance of the GPS entity.
        GPSPoint *point = (GPSPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GPSPoint" inManagedObjectContext:self.managedObjectContext];
        point.altitude = [NSNumber numberWithDouble:location.altitude];
        point.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        point.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        point.timestamp = [NSDate date];
        point.pointID = [NSNumber numberWithInt:currentPointId++];
        
        //Add it to the current trip for storage
        [self.currentTrip addPointsObject:point];
        [self.pointsForDrawing addObject:point];
        
        [self saveTrip];
        
        //Only store the location if it far enough away from the old one
    }else if([location distanceFromLocation:previousLocation] > desiredDistanceBetweenPoints){
        
        // Create and configure a new instance of the GPS entity.
        GPSPoint *point = (GPSPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GPSPoint" inManagedObjectContext:self.managedObjectContext];
        point.altitude = [NSNumber numberWithDouble:location.altitude];
        point.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        point.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        point.timestamp = [NSDate date];
        point.pointID = [NSNumber numberWithInt:currentPointId++];
        
        //Add it to the current trip for storage
        [self.currentTrip addPointsObject:point];
        [self.pointsForDrawing addObject:point];
        
        [self saveTrip];
        
    }else{
        
        DLog(@"Not a large enough distance between here and the previous location. Skipping.");
        
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
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Gretel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        
        BOOL success = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil URL:storeURL
                                               options:options error:&error];
        if (!success) {
            DLog(@"Could not migrate store");
        }
        
        
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
