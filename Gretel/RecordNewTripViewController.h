//
//  ViewController.h
//  Gretel
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GCDiscreetNotificationView/GCDiscreetNotificationView.h>
#import "GeoManager.h"
#import "Trip.h"
#import "BRBaseMapViewController.h"
#import "SettingsViewController.h"
#import "SettingsManager.h"
#import "TripManager.h"

typedef enum {
    GTAlertViewTagBeginRecordingAlert,
    GTAlertViewTagStopRecordingAlert
} GTAlertViewType;

/**
 * Defines the button states for the main action/options button
 */
typedef enum {
    kTripActionSheetStop,
    kTripActionSheetOptions
} kTripActionSheetType;

@interface RecordNewTripViewController : BRBaseMapViewController <MKMapViewDelegate, UIAlertViewDelegate> {
    NSMutableArray *recordedPoints;
    BOOL resumingTrip;
    TripManager *tripManager;
    NSTimeInterval startTime;
    NSTimeInterval pausedTime;
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
///Notification view
@property (nonatomic, strong) GCDiscreetNotificationView *notificationView;
///handles recording states
@property (nonatomic, readwrite) BOOL isRecording;
///Indicates to the user whether they are recording
@property (nonatomic, strong) IBOutlet UIView *recordingIndicatorContainer;
@property (nonatomic, strong) UIImageView *recordingLight;
@property (nonatomic, strong) IBOutlet UILabel *tripTimerLabel;

/** @section HUD UI Properties */
///Used to display the latitude
@property (nonatomic, strong) IBOutlet UILabel *latLabel;
///Used to display the longitude
@property (nonatomic, strong) IBOutlet UILabel *lonLabel;
///Used to display the curernt speed
@property (nonatomic, strong) IBOutlet UILabel *currentSpeedLabel;
@property (nonatomic, strong) IBOutlet UIImageView *compassNeedle;
@property (nonatomic, strong) IBOutlet UIImageView *compassBackground;
///Allows the user to set the trip name.
@property (nonatomic, strong) IBOutlet UITextField *tripNameField;

@property (nonatomic, strong) IBOutlet UIButton *locateMeButton;

/** @section Non UI Properties */
///Current trip state
@property (nonatomic, readwrite) GTTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;
///The trip name as set in the launch controller UIAlertView
@property (nonatomic, strong) NSString *tripName;

/** @section Button handlers */
-(IBAction)startTrackingButtonHandler:(id)sender;
-(IBAction)stopTrackingButtonHandler:(id)sender;
-(IBAction)addButtonHandler:(id)sender;

@end
