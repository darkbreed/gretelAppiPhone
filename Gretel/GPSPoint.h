//
//  GPSPoint.h
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class Trip;

@interface GPSPoint : ExtendedManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * pointID;
@property (nonatomic, retain) Trip *trip;

@end
