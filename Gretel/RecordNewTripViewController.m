//
//  RecordNewTripViewController.h
//  Gretel
//
//
//  Created by Ben Reed on 10/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "RecordNewTripViewController.h"
#import "GPSPoint.h"
#import "SettingsMenuViewController.h"

@interface RecordNewTripViewController ()

@end

@implementation RecordNewTripViewController {
    SettingsManager *settingsManager;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tripManager = [TripManager sharedManager];
    settingsManager = [SettingsManager sharedManager];
    
    [self addAllObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteringBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReturnToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if(!tripManager.currentTrip){
        [self.currentSpeedLabel setText:[NSString stringWithFormat:@"0.0 %@",settingsManager.unitLabelSpeed]];
        [self setInitialLocate:YES];
        [self setUpViewForNewTrip];
    }
    
    [self.navigationItem.leftBarButtonItem setImage:[GTThemeManager listIcon]];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    if(self.isResuming){
        [self setViewStateForTripState:GTTripStateRecording];
    }
}

- (void)viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:animated];
    
    if(!tripManager.currentTrip){
        [self setUpViewForNewTrip];
        [self setViewStateForTripState:GTTripStateNew];
        [self setTitle:nil];
    }
    
    [self setTitle:tripManager.currentTrip.tripName];
    
    if(!self.notificationView){
        self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                    showActivity:NO
                                                              inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                          inView:self.mapView];
    }
    
    if(tripManager.isResuming){
        [self setViewStateForTripState:GTTripStateRecording];
        tripManager.isResuming = NO;
    }
    
    //set the menu view controller
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[SettingsMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsMenu"];
    }
        
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self checkForLocationServices];
}

-(void)handleEnteringBackground {
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    [self.mapView setShowsUserLocation:NO];
    [self removeAllObsververs];

}

-(void)handleReturnToForeground {
    
    [self addAllObservers];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self.mapView setShowsUserLocation:YES];
    [self checkForLocationServices];
    
}

-(void)checkForLocationServices {
    
    //Set up the view for no servicces
    if([[GeoManager sharedManager] locationServicesEnabled] == NO){
        [self.notificationView setTextLabel:@"Location services disabled"];
        [self.notificationView showAnimated];
        [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolDisabled.png"] forState:UIControlStateNormal];
    }else{
        [self.notificationView hideAnimatedAfter:0.5];
        [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolEnabled.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)locateMeButtonHandler:(id)sender {
    
    [self checkForLocationServices];
    
    if([[GeoManager sharedManager] locationServicesEnabled]){
        
        [[GeoManager sharedManager] startTrackingPosition];
        
        if(self.mapView.userTrackingMode == MKUserTrackingModeNone){
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }else if(self.mapView.userTrackingMode == MKUserTrackingModeFollow){
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        }else if(self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading){
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        }
        
    }else{
        [self displayLocationServicesDisabledAlert];
    }
}

-(IBAction)actionButtonHandler:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set map type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Standard",@"Satellite",@"Hybrid", nil];
    [actionSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
        
        case 1:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
            
        case 2:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
            
        default:
            break;
    }
    
}

-(void)setUpViewForNewTrip {
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self setTitle:nil];
    [self setViewStateForTripState:GTTripStateNew];
    
}

-(void)displayLocationServicesDisabledAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services disabled" message:@"Gretel cannot track your location as your location services have been disabled. Please enable them in the Settings, then return to the app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

-(void)setViewStateForTripState:(GTTripState)tripState {
    
    switch (tripState) {
            
        case GTTripStateNew: {
            
            [self.recordingIndicatorContainer setHidden:YES];
            [self.notificationView hide:YES];
            [self.stopButton setEnabled:NO];
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            [self.tripTimerLabel setText:@"--:--:--"];
            [self.currentSpeedLabel setText:[NSString stringWithFormat:@"0.0 %@",settingsManager.unitLabelSpeed]];
            break;
            
        }
            
        case GTTripStatePaused: {
            
            //change the recording button to pause
            [tripManager pauseRecording];
            
            //Notify the user
            [self.notificationView setTextLabel:@"Recording paused"];
            [self.notificationView show:YES];
            [self.recordingIndicatorContainer setHidden:YES];
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            [self.stopButton setEnabled:YES];
            
            break;
        }
            
        case GTTripStateRecording: {
            //We are paused, the user is resuming tracking
    
            //change the recording button to pause
            [tripManager beginRecording];
            
            NSArray *points = [tripManager fectchPointsForDrawing:NO];
            
            [self drawRoute:points onMapView:self.mapView willRefreh:YES];
            
            if([self.notificationView.textLabel isEqualToString:@"Recording paused"]){
                [self.notificationView setTextLabel:@"Recording"];
                [self.notificationView hideAnimatedAfter:1.0];
                
            }else{
                [self.notificationView setTextLabel:@"Recording"];
                [self.notificationView showAndDismissAutomaticallyAnimated];
            }
            
            [self.notificationView hideAnimatedAfter:1.0];
            
            [self.recordingIndicatorContainer setHidden:NO];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            [self.stopButton setEnabled:YES];
            
            break;
        }
    }
    
}

-(void)pauseRecording {
    [self setViewStateForTripState:GTTripStatePaused];
}

-(void)resumeRecording {
    [self setViewStateForTripState:GTTripStateRecording];
}

#pragma Button Handlers
-(IBAction)startTrackingButtonHandler:(id)sender {
    
    switch (tripManager.tripState) {
        case GTTripStateNew:
            
            if([[GeoManager sharedManager] locationServicesEnabled]){
                
                if(!tripManager.currentTrip){
                    
                    NSDateFormatter *formatter;
                    formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
                    self.tripName = [formatter stringFromDate:[NSDate date]];
                    
                    [tripManager createNewTripWithName:self.tripName];
                    [self setViewStateForTripState:GTTripStateRecording];
                    [self setTitle:self.tripName];
                    
                    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
                    
                }
                
            }else{
                [self displayLocationServicesDisabledAlert];
            }
            
            break;
        
        case GTTripStateRecording:
            [self setViewStateForTripState:GTTripStatePaused];
            break;
            
        case GTTripStatePaused:
            [self setViewStateForTripState:GTTripStateRecording];
            break;
            
        default:
            break;
    }
    
}

-(IBAction)stopTrackingButtonHandler:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Stop recording?" message:@"Stopping the recording will end the trip, stop now?" delegate:self cancelButtonTitle:@"Keep recording" otherButtonTitles:@"Stop and save", nil];
    [alertView setTag:GTAlertViewTagStopRecordingAlert];
    [alertView show];
    
}

-(IBAction)addButtonHandler:(id)sender {
    [self hideMapViewAndOptions:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

-(IBAction)displayMap:(id)sender {
    [self hideMapViewAndOptions:NO];
    if(!self.navigationItem.rightBarButtonItem){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonHandler:)];
    }
}

-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)updateTripTimerDisplay {
    //NSLog(@"Updating");
    self.tripTimerLabel.text = tripManager.timerValue;
}

#pragma mark UIAlertView message
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == GTAlertViewTagStopRecordingAlert){
       
        if(buttonIndex == 1){
            
            [self.notificationView setHidden:NO];
            [self.notificationView setTextLabel:@"Saving..."];
            [self.notificationView showActivity];
            
            [tripManager saveTripAndStop];
            [[GeoManager sharedManager] stopTrackingPosition];
            
            [self setUpViewForNewTrip];
            
         
        }
    }
}

-(void)updateLocation {

    //Update the views
    self.latLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.latitude];
    self.lonLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.longitude];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.2f M",[[[GeoManager sharedManager] currentLocation] horizontalAccuracy]];
    
    float currentSpeed = [[GeoManager sharedManager] currentSpeed] * settingsManager.speedMultiplier;
    
    if(currentSpeed < 0.0){
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"0.0 %@",settingsManager.unitLabelSpeed];
    }else{
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"%.2f %@",currentSpeed,settingsManager.unitLabelSpeed];
    }
    
    float elevation = [[GeoManager sharedManager] currentElevation];
    
    if(settingsManager.unitType == GTAppSettingsUnitTypeMPH){
        elevation = [[GeoManager sharedManager] currentElevation] * SMMetersToFeetMultiplier;
    }
    
    self.elevationLabel.text = [NSString stringWithFormat:@"%.2f %@",elevation,settingsManager.unitLabelHeight];
    
    NSArray *points = [tripManager fectchPointsForDrawing:NO];
    [self drawRoute:points onMapView:self.mapView willRefreh:YES];
    
}

-(void)updateCompassWithHeading {
    
    CABasicAnimation *theAnimation;
    
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    theAnimation.fromValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] fromHeadingAsRad]];
    theAnimation.toValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] toHeadingAsRad]];
    
    //If the user has selected the heading then update the button to highlight it.
    if(self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading){
        //self.locateMeButton.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
    }
    
    [self.compassNeedle.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    self.compassNeedle.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
    self.compassBackground.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
}

-(void)updateDistanceHandler:(NSNotification *)notification {
    
    float distance = [tripManager.currentTrip.totalDistance floatValue];
   
    if([[SettingsManager sharedManager] unitType] == GTAppSettingsUnitTypeMPH){
        distance = distance * [[SettingsManager sharedManager] distanceMultiplier];
    }else{
        distance = distance / [[SettingsManager sharedManager] distanceMultiplier];
    }
    
     [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f %@",distance,settingsManager.unitLabelDistance]];
    
}

-(void)handleSettingsChange {
    [self updateLocation];
}

-(void)tripSaveSuccessHandler:(NSNotification *)notification {
    [self.notificationView setHidden:NO];
    [self.notificationView setTextLabel:@"Trip saved successfully"];
    [self.notificationView showAndDismissAfter:2.0];
}

#pragma mark Import handlers
-(void)tripImportSuccessHandler:(NSNotification *)notification {
    [self.notificationView setShowActivity:NO animated:NO];
    [self.notificationView setTextLabel:@"New trip added to inbox"];
    [self.notificationView hideAnimatedAfter:2.0];
}

-(void)tripImportBeganHandler:(NSNotification *)notification {
    [self.notificationView setHidden:NO];
    [self.notificationView setTextLabel:@"Importing trip to inbox..."];
    [self.notificationView setShowActivity:YES animated:YES];
    [self.notificationView show:YES];
}

#pragma memory handling
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)addAllObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompassWithHeading) name:GTLocationHeadingDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseRecording) name:GTLocationDidPauseUpdates object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeRecording) name:GTLocationDidResumeUpdates object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChange) name:SMSettingsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTripTimerDisplay) name:GTTripTimerDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripSaveSuccessHandler:) name:GTTripSavedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDistanceHandler:) name:GTTripUpdatedDistance object:nil];
}

-(void)removeAllObsververs {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTLocationHeadingDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTLocationDidPauseUpdates object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTLocationDidResumeUpdates object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SMSettingsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTTripTimerDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTTripSavedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTTripUpdatedDistance object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
