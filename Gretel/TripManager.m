//
//  TripManager.m
//  Gretel
//
//  Created by Ben Reed on 04/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripManager.h"

@implementation TripManager

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
        
        //configure here
        
    }
    
    return self;
}

@end
