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

-(void)fetchAllTrips;
-(void)fetchInbox;
-(void)beginRecording;
-(void)pauseRecording;
-(void)saveTrip;
-(void)saveTripAndStop;
-(void)createNewTripWithName:(NSString *)name;
-(void)storeLocation;
-(NSArray *)fectchPointsForDrawing:(BOOL)forDetailView;
-(Trip *)tripWithIndexPath:(NSIndexPath *)tripIndexPath;
-(void)deleteTrips:(NSArray *)tripIndexPaths;
-(void)deleteTrip:(Trip *)trip;
-(NSString *)recordingStateForState:(GTTripState)state;
-(void)searchTripsByKeyword:(NSString *)keyword shouldReturnInboxResults:(BOOL)returnInboxResults;
-(float)calculateDistanceForPoints:(Trip *)trip;
-(void)importTripFromGPXFile:(NSURL *)url;

@end
