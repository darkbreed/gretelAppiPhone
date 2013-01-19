//
//  ExtendedManagedObject.h
//  Gretel
//
//  Created by Ben Reed on 30/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ExtendedManagedObject : NSManagedObject

@property (nonatomic, readwrite) BOOL traversed;

- (NSData *)toData;
- (NSDictionary*)toDictionary;
- (void)populateFromDictionary:(NSDictionary*)dict;
+ (ExtendedManagedObject*)createManagedObjectFromDictionary:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context;

@end