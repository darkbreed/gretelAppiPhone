//
//  LaunchViewController.h
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "RecordNewTripViewController.h"
#import "HistoryViewController.h"

/**
 * Definitions for button indexes in the UIAlertView for creating a new trip
 */
typedef enum {
    TripAlertViewButtonIndexCancel,
    TripAlertViewButtonIndexCreate
}TripAlertViewButtonIndexType;

@interface LaunchViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *startNewTripButton;

@end
