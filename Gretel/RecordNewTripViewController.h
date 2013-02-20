//
//  ViewController.h
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GeoManager.h"
#import "Trip.h"
#import "BRBaseMapViewController.h"

/**
 * Defines the states that a trip can exist in to help determine how the view should behave.
 */
typedef enum {
    kTripStateRecording,
    kTripStatePaused,
    kTripStateNew
} kTripState;

/**
 * Defines the button states for the main action/options button
 */
typedef enum {
    kTripActionSheetStop,
    kTripActionSheetOptions
} kTripActionSheetType;

@interface RecordNewTripViewController : BRBaseMapViewController <MKMapViewDelegate> {
    int currentPointId;
    NSMutableArray *recordedPoints;
}

/** @section General UI Properties */
///Starts a new trip
@property (nonatomic, strong) IBOutlet UIButton *startButton;
///Stops a current trip
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
///Switches from map view to HUD view
@property (nonatomic, strong) IBOutlet UIBarButtonItem *modeChangeButton;
///HUD view for displaying trip information
@property (nonatomic, strong) IBOutlet UIView *hudView;
///Container for map and HUD view, needed for transition effects
@property (nonatomic, strong) IBOutlet UIView *mapHudContainer;

/** @section HUD UI Properties */
///Used to display the latitude
@property (nonatomic, strong) IBOutlet UILabel *latLabel;
///Used to display the longitude
@property (nonatomic, strong) IBOutlet UILabel *lonLabel;
///Used to display the curernt speed
@property (nonatomic, strong) IBOutlet UILabel *currentSpeedLabel;
@property (nonatomic, strong) IBOutlet UIImageView *compassNeedle;

/** @section Non UI Properties */
///Current trip state
@property (nonatomic, readwrite) kTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;
///The trip name as set in the launch controller UIAlertView
@property (nonatomic, strong) NSString *tripName;

/** @section Button handlers */
-(IBAction)startTrackingButtonHandler:(id)sender;
-(IBAction)stopTrackingButtonHandler:(id)sender;
-(IBAction)addButtonHandler:(id)sender;
-(void)setCurrentTripState:(kTripState)tripState;

@end
