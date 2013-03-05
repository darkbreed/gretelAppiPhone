//
//  Trip.h
//  Gretel
//
//  Created by Ben Reed on 01/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class GPSPoint;

@interface Trip : ExtendedManagedObject

@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSString * recordingState;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSSet *points;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addPointsObject:(GPSPoint *)value;
- (void)removePointsObject:(GPSPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
