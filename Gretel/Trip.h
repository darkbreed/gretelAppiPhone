//
//  Trip.h
//  Gretel
//
//  Created by Ben Reed on 08/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class GPSPoint;

@interface Trip : ExtendedManagedObject

@property (nonatomic, retain) NSString * displayDate;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSString * recordingState;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSString * gpxFilePath;
@property (nonatomic, retain) NSNumber * tripDurationHours;
@property (nonatomic, retain) NSNumber * tripDurationMinutes;
@property (nonatomic, retain) NSNumber * tripDurationSeconds;
@property (nonatomic, retain) NSNumber * tripDurationMilliseconds;
@property (nonatomic, retain) NSSet *points;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addPointsObject:(GPSPoint *)value;
- (void)removePointsObject:(GPSPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
