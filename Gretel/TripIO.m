//
//  TripImporter.m
//  Gretel
//
//  Created by Ben Reed on 09/05/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripIO.h"
#import "TripManager.h"
#import "TripUtilities.h"

@interface TripIO ()

@property (nonatomic, strong) TripManager *tripManager;

@end

@implementation TripIO {
    dispatch_queue_t q_default;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(id)init {
    
    self = [super init];
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPointsToImportedTrip:) name:GTTripImportedSuccessfully object:nil];
        
        self.tripManager = [TripManager sharedManager];
        q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return self;
}

#pragma mark Trip Export Methods
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

-(void)createGPXFileFromTrip:(Trip *)trip withSuccessBlock:(FileCreationSuccessBlock)successBlock andFailureBlock:(FileCreationFailureBlock)failureBlock{
    
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
        successBlock([gpxURL absoluteString]);
    }];
}

#pragma mark - Trip Import Methods
-(void)importTripReadError {
    
    [self showErrorOverlay];
    
}

-(void)deletionContextDidSave:(NSNotification *)notification {
    
    if(self.tripManager.managedObjectContext){
        [self.tripManager.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
    }
    
}

-(void)importContextDidSave:(NSNotification *)notification {
    
    if(self.tripManager.managedObjectContext){
        [self.tripManager.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
    }
}

-(void)importTripFromGPXFile:(NSURL *)url{
    
    [self performSelectorOnMainThread:@selector(showImportStatusOverlay) withObject:nil waitUntilDone:NO];
    
    dispatch_async(q_default, ^{
        
        NSString *fileName = [url lastPathComponent];
        Trip *importedTrip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:self.managedObjectContext];
        [importedTrip setGpxFilePath:[url absoluteString]];
        [importedTrip setTripName:fileName];
        [importedTrip setReceivedFromRemote:[NSNumber numberWithBool:YES]];
        [importedTrip setImportedPoints:[NSNumber numberWithBool:NO]];
        [importedTrip setRead:[NSNumber numberWithBool:NO]];
        [importedTrip setIsImporting:[NSNumber numberWithBool:YES]];
        
        [self addPointsToImportedTrip:importedTrip];
        
    });
}

-(void)addPointsToImportedTrip:(Trip *)trip {
    
    NSURL *url = [NSURL URLWithString:trip.gpxFilePath];
    
    GPXRoot *root = [GPXParser parseGPXAtURL:url];
    
    if([[root tracks] count] > 0){
        
        for (GPXTrack *track in [root tracks]) {
            
            [self parseTrackSegements:track forTrip:trip];
            
        }
        
    }else{
        [self importTripReadError];
    }
}

-(void)parseTrackSegements:(GPXTrack *)track forTrip:(Trip *)trip{
    
    if([[track tracksegments] count] > 0){
        for (GPXTrackSegment *segment in [track tracksegments]) {
            [self parseSegmentTrackPoints:segment forTrip:trip];
        }
        
        [self performSelectorOnMainThread:@selector(dismissStatusOverlay) withObject:nil waitUntilDone:YES];
        
    }else{
        
        [self importTripReadError];
    }
}

-(void)parseSegmentTrackPoints:(GPXTrackSegment *)segment forTrip:(Trip *)trip{
    
    int count = 0;
    
    if([[segment trackpoints] count] > 0){
        
        for(GPXTrackPoint *trackPoint in [segment trackpoints]){
            
            GPSPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"GPSPoint" inManagedObjectContext:self.managedObjectContext];
            [point setLat:[NSNumber numberWithFloat:[trackPoint latitude]]];
            [point setLon:[NSNumber numberWithFloat:[trackPoint longitude]]];
            [point setTimestamp:[trackPoint time]];
            [point setPointID:[NSNumber numberWithInt:count]];
            [point setAltitude:[NSNumber numberWithFloat:[trackPoint elevation]]];
            
            [trip addPointsObject:point];
            
            count++;
        }
        
        //calculate the distance and store it
        [trip setTotalDistance:[NSNumber numberWithFloat:[TripUtilities calculateDistanceForPointsInMetres:trip]]];
        [trip setRecordingState:[self.tripManager recordingStateForState:GTTripStatePaused]];
        [trip setReceivedFromRemote:[NSNumber numberWithBool:YES]];
        [trip setIsImporting:[NSNumber numberWithBool:NO]];
        
        //Save the trip
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        
    }else{
        [self importTripReadError];
    }
}

-(void)dismissStatusOverlay {
    [BWStatusBarOverlay dismissAnimated:YES];
}

-(void)showImportStatusOverlay {
    [BWStatusBarOverlay showLoadingWithMessage:@"Importing Data" animated:NO];
}

-(void)showErrorOverlay {
    [BWStatusBarOverlay setMessage:@"Error reading file" animated:YES];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext!= nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
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

#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
