//
//  TripImporter.h
//  Gretel
//
//  Created by Ben Reed on 09/05/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPX/GPX.h>
#import "GPXDocument.h"
#import "BWStatusBarOverlay.h"
#import "Trip.h"
#import "GPSPoint.h"

typedef void(^FileCreationSuccessBlock)(NSString *gpxFilePath);
typedef void(^FileCreationFailureBlock)(NSError *error);

@interface TripIO : NSObject
///Core data stack
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)createGPXFileFromTrip:(Trip *)trip withSuccessBlock:(FileCreationSuccessBlock)successBlock andFailureBlock:(FileCreationFailureBlock)failureBlock;
-(void)importTripFromGPXFile:(NSURL *)url;
-(NSString *)gpxFilePathWithName:(NSString *)tripName;

@end
