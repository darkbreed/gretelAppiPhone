//
//  BRMapAnnotation.h
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    kBRLocationTypeStart,
    kBRLocationTypeFinish,
    kBRLocationTypePoint
} kBRMapAnnotationType;

@interface BRMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) kBRMapAnnotationType type;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord andType:(kBRMapAnnotationType)annotationType;

@end
