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
    NSArray *route;
}

@property (nonatomic, strong) Trip *trip;

@end
