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
#import "SettingsManager.h"
#import <GPX/GPX.h>
#import "GPXDocument.h"
#import "BWStatusBarOverlay.h"

/**
 * Defines the states that a trip can exist in to help determine how the view should behave.
 */
typedef enum {
    GTTripStateNew,
    GTTripStateRecording,
    GTTripStatePaused
} GTTripState;

typedef enum {
    TripManagerAlertViewButtonTypeDismiss,
    TripManagerAlertViewButtonTypeGotoInbox
}TripManagerAlertViewButtonType;

extern NSString * const GTTripTimerDidUpdate;
extern NSString * const GTTripDeletedSuccess;
extern NSString * const GTCurrentTripDeleted;
extern NSString * const GTTripImportedSuccessfully;
extern NSString * const GTTripSavedSuccessfully;
extern NSString * const GTTripUpdatedDistance;
extern NSString * const GTTripGotoInbox;


@interface TripManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, readwrite) GTTripState tripState;
@property (nonatomic, strong) Trip *currentTrip;
@property (nonatomic, strong) Trip *tripForDetailView;
@property (nonatomic, strong) NSFetchedResultsController *allTrips;
@property (nonatomic, strong) NSString *timerValue;
@property (nonatomic, readwrite) BOOL isResuming;
@property (nonatomic, strong) NSMutableArray *pointsForDrawing;

///Core data stack
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(TripManager*)sharedManager;

/**
 * Fetches all trips that have been recorded on the app. This sets a predicate on the NSFetchedResultsController and updates
 * the tableview accordingly
 * @return void
 */
-(void)fetchAllTrips;

/**
 * Fetches all trips in the inbox. This sets a predicate on the NSFetchedResultsController and updates
 * the tableview accordingly
 * @return void
 */
-(void)fetchInbox;

/**
 * Starts the trip recording. This methods tells the GeoManager to start tracking the users location.
 * @return void
 */
-(void)beginRecording;

/**
 * Pauses the recording of a trip
 * @return void
 */
-(void)pauseRecording;

/**
 * Saves a trip to coredata. This method is called whenever a trip is created or updated.
 * @return void
 */
-(void)saveTrip;

/**
 * Saves a trip, generates a GPX file from the points and saves the URL of the new file to the Trip object in CoreData.
 * This method also clears the current trip and resets any flags and settings ready to record a new trip.
 * @return void
 */
-(void)saveTripAndStop;

/**
 * Creates a new trip with the current date as the name. This can then be changed by the user at a later date.
 * @param name - by default this is the current date as a string.
 * @return void
 */
-(void)createNewTripWithName:(NSString *)name;

/**
 * Adds a new GPSPoint object to the current trip
 * @return void
 */
-(void)storeLocation;

/**
 * Fetches the points needed for drawing the route onto the map view
 * @return void
 */
-(NSArray *)fectchPointsForDrawing:(BOOL)forDetailView;

/**
 * Fetches a trip from the NSFetchedResultsController with the given indexPath
 * @param NSIndexPath tripIndexPath
 * @return Trip trip
 */
-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath;

/**
 * Deletes a batch of trips from the app
 * @param NSArray tripIndexPaths
 * @return void
 */
-(void)deleteTrips:(NSArray *)tripIndexPaths;

/**
 * Deletes a single trip from the app
 * @param NSIndexPath tripIndexPath
 * @return void
 */
-(void)deleteTrip:(Trip *)trip;

/**
 * Returns a string representing the trip state
 * @param GTTripState tripIndexPath
 * @return NSString tripState
 */
-(NSString *)recordingStateForState:(GTTripState)state;

/**
 * Searches core data for any trips matching the keywords given. This only works for trip title at the moment. 
 * A flag can also be set to only return inbox results.
 * @param NSString keyword
 * @param BOOL returnInboxResults
 * @return NSString tripState
 */
-(void)searchTripsByKeyword:(NSString *)keyword shouldReturnInboxResults:(BOOL)returnInboxResults;

@end
