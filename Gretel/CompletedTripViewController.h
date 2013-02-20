//
//  CompletedTripViewController.h
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBaseMapViewController.h"
#import "Trip.h"

@interface CompletedTripViewController : BRBaseMapViewController {
    
    ///The trip points as an array to feed the map view
    NSArray *route;
}

///The trip to be viewed
@property (nonatomic, strong) Trip *trip;

@end
