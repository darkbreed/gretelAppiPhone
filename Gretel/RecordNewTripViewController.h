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
#import "ECSlidingViewController.h"
#import "GTThemeManager.h"

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
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *modeChangeButton;
@property (nonatomic, weak) IBOutlet UIView *hudView;
@property (nonatomic, weak) IBOutlet UIView *mapHudContainer;
@property (nonatomic, weak) IBOutlet UIView *recordingIndicatorContainer;
@property (nonatomic, weak) IBOutlet UILabel *tripTimerLabel;
@property (nonatomic, weak) IBOutlet UIButton *hudButton;
@property (nonatomic, strong) GCDiscreetNotificationView *notificationView;
@property (nonatomic, weak) UIImageView *recordingLight;

/** @section HUD UI Properties */
@property (nonatomic, weak) IBOutlet UILabel *latLabel;
@property (nonatomic, weak) IBOutlet UILabel *lonLabel;
@property (nonatomic, weak) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *elevationLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentSpeedLabel;
@property (nonatomic, weak) IBOutlet UIImageView *compassNeedle;
@property (nonatomic, weak) IBOutlet UIImageView *compassBackground;
@property (nonatomic, weak) IBOutlet UIButton *locateMeButton;

/** @section Non UI Properties */
///Current trip state
@property (nonatomic, readwrite) GTTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;
///The trip name as set in the launch controller UIAlertView
@property (nonatomic, weak) NSString *tripName;
///handles recording states
@property (nonatomic, readwrite) BOOL isRecording;
///
@property (nonatomic, readwrite) BOOL isResuming;

/** @section Button handlers */
-(IBAction)startTrackingButtonHandler:(id)sender;
-(IBAction)stopTrackingButtonHandler:(id)sender;
-(IBAction)addButtonHandler:(id)sender;

@end
