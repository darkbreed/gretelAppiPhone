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
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *modeChangeButton;
@property (nonatomic, strong) IBOutlet UIView *hudView;
@property (nonatomic, strong) IBOutlet UIView *mapHudContainer;
@property (nonatomic, strong) IBOutlet UIView *recordingIndicatorContainer;
@property (nonatomic, strong) IBOutlet UILabel *tripTimerLabel;
@property (nonatomic, strong) IBOutlet UIButton *hudButton;
@property (nonatomic, strong) GCDiscreetNotificationView *notificationView;
@property (nonatomic, strong) UIImageView *recordingLight;

/** @section HUD UI Properties */
@property (nonatomic, strong) IBOutlet UILabel *latLabel;
@property (nonatomic, strong) IBOutlet UILabel *lonLabel;
@property (nonatomic, strong) IBOutlet UILabel *elevationLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentSpeedLabel;
@property (nonatomic, strong) IBOutlet UIImageView *compassNeedle;
@property (nonatomic, strong) IBOutlet UIImageView *compassBackground;
@property (nonatomic, strong) IBOutlet UITextField *tripNameField;
@property (nonatomic, strong) IBOutlet UIButton *locateMeButton;

/** @section Non UI Properties */
///Current trip state
@property (nonatomic, readwrite) GTTripState tripState;
///Current trip to record points to
@property (nonatomic, strong) Trip *currentTrip;
///The trip name as set in the launch controller UIAlertView
@property (nonatomic, strong) NSString *tripName;
///handles recording states
@property (nonatomic, readwrite) BOOL isRecording;

/** @section Button handlers */
-(IBAction)startTrackingButtonHandler:(id)sender;
-(IBAction)stopTrackingButtonHandler:(id)sender;
-(IBAction)addButtonHandler:(id)sender;

@end
