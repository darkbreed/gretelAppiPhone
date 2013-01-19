//
//  BRMapAnnotation.m
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "BRMapAnnotation.h"

@implementation BRMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord andType:(kBRMapAnnotationType)annotationType {
    
    self = [super init];
    if (self != nil) {
        self.coordinate = coord;
        self.type = annotationType;
        
    }
    return self;
}

@end
