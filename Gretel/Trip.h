//
//  Trip.h
//  Gretel
//
//  Created by Ben Reed on 14/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class GPSPoint;

@interface Trip : ExtendedManagedObject

@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *points;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addPointsObject:(GPSPoint *)value;
- (void)removePointsObject:(GPSPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
