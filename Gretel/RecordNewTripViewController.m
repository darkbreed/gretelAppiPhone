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

@interface RecordNewTripViewController ()

@end

@implementation RecordNewTripViewController {
    SettingsManager *settingsManager;
    double tripTimeElapsed;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tripManager = [TripManager sharedManager];
    settingsManager = [SettingsManager sharedManager];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompassWithHeading) name:GTLocationHeadingDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseRecording) name:GTLocationDidPauseUpdates object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChange) name:SMSettingsUpdated object:nil];
    
    [self setInitialLocate:YES];
    
    [self.currentSpeedLabel setText:[NSString stringWithFormat:@"0.0 %@",settingsManager.unitLabelSpeed]];
    
    if([[GeoManager sharedManager] locationServicesEnabled]){
    
        [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolEnabled.png"] forState:UIControlStateNormal];
    }
    
    tripTimeElapsed = 0.0;
    
    [self setUpViewForNewTrip];
}

- (void)viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:animated];
    
    if(!tripManager.currentTrip){
        [self setUpViewForNewTrip];
        [self setViewStateForTripState:GTTripStateNew];
    }
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:self.mapView];
    
    if(tripManager.isResuming){
        [self setViewStateForTripState:GTTripStateRecording];
        tripManager.isResuming = NO;
    }
}

-(IBAction)locateMeButtonHandler:(id)sender {
    
    if([[GeoManager sharedManager] locationServicesEnabled]){
        [[GeoManager sharedManager] startTrackingPosition];
        [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolEnabled.png"] forState:UIControlStateNormal];
    }else{
        [self displayLocationServicesDisabledAlert];
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
    
    [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolDisabled.png"] forState:UIControlStateNormal];
}

-(void)setViewStateForTripState:(GTTripState)tripState {
    
    switch (tripState) {
            
        case GTTripStateNew: {
            
            [self.recordingIndicatorContainer setHidden:YES];
            [self.notificationView hide:YES];
            [self.stopButton setEnabled:NO];
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            
            break;
            
        }
            
        case GTTripStatePaused: {
            //we are recording, the user has paused the tracking
           
            //Start tracking the users location
            [[GeoManager sharedManager] stopTrackingPosition];
            
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
        
            //Start tracking the users location
            [[GeoManager sharedManager] startTrackingPosition];
            
            //change the recording button to pause
            [tripManager beginRecording];
            
            [self.notificationView setTextLabel:@"Recording"];
            //[self.notificationView showAndDismissAutomaticallyAnimated];
            [self.recordingIndicatorContainer setHidden:NO];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            [self.stopButton setEnabled:YES];
            
            break;
        }
    }
    
}


#pragma Button Handlers
-(IBAction)startTrackingButtonHandler:(id)sender {
    
    switch (tripManager.tripState) {
        case GTTripStateNew:
            
            if([[GeoManager sharedManager] locationServicesEnabled]){
                if(!tripManager.currentTrip){
                    
                    UIAlertView *newTripAlertView = [[UIAlertView alloc] initWithTitle:@"Name your trip" message:@"Give your trip a name, this can be changed later" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Start recording", nil];
                    [newTripAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[newTripAlertView textFieldAtIndex:0] setPlaceholder:@"Trip name..."];
                    [newTripAlertView setTag:GTAlertViewTagBeginRecordingAlert];
                    [newTripAlertView show];
                }
            }else{
                [self displayLocationServicesDisabledAlert];
            }
            
            break;
        
        case GTTripStateRecording:
            [tripManager pauseRecording];
            [self setViewStateForTripState:GTTripStatePaused];
            [self pauseTimer];
            break;
            
        case GTTripStatePaused:
            [self setViewStateForTripState:GTTripStateRecording];
            [tripManager beginRecording];
            [self resumeTimer];
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
}

-(IBAction)displayMap:(id)sender {
    [self hideMapViewAndOptions:NO];
}

#pragma mark UIAlertView message
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == GTAlertViewTagStopRecordingAlert){
       
        if(buttonIndex == 1){
            [tripManager saveTripAndStop];
            [[GeoManager sharedManager] stopTrackingPosition];
            [self performSegueWithIdentifier:@"displayHistoryView" sender:self];
            [self pauseTimer];
        }
        
    }else if(alertView.tag == GTAlertViewTagBeginRecordingAlert){
        
        if(buttonIndex == 1){
            self.tripName = [[alertView textFieldAtIndex:0] text];
            [self setViewStateForTripState:GTTripStateRecording];
            [tripManager createNewTripWithName:self.tripName];
            [self setTitle:self.tripName];
            [self startTripTimer];
            
            
        }
    }
}

-(void)startTripTimer {
    
    if(!tripTimer){
        
        startTime = [NSDate timeIntervalSinceReferenceDate];
        
        tripTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                     target:self
                                                   selector:@selector(updateTimer)
                                                   userInfo:nil
                                                    repeats:YES];
        
        resumingTrip = NO;
    }
}


- (void)resumeTimer {
    if(tripTimer) {
        [tripTimer invalidate];
        tripTimer = nil;
    }
    tripTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    resumingTrip = YES;
}

- (void)pauseTimer {
    [tripTimer invalidate];
    tripTimer = nil;
    pausedTime = [NSDate timeIntervalSinceReferenceDate];
}



-(void)updateTimer {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    //NSTimeInterval elapsed = 0.0;
    
    if(!resumingTrip){
        tripTimeElapsed = currentTime - startTime;
    }else{
        tripTimeElapsed = currentTime - pausedTime;
    }
    
    long time = tripTimeElapsed;
	int seconds = ((time) % 60);
	int minutes = ((time/60) % 60);
	int hours = ((time/3600) % 24);
    
    NSString *timeString = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
        
    [self.tripTimerLabel setText:timeString];
    [tripManager.currentTrip setTripDurationMinutes:[NSNumber numberWithInt:minutes]];
    [tripManager.currentTrip setTripDurationSeconds:[NSNumber numberWithInt:seconds]];
    [tripManager.currentTrip setTripDurationHours:[NSNumber numberWithInt:hours]];
    
    [tripManager.currentTrip setTripDuration:[NSNumber numberWithDouble:time]];
    
}

-(void)updateLocation {
    
    if(tripManager.tripState == GTTripStateRecording){
    
        //Store the data point
        [tripManager storeLocation];
        [self drawRoute:[tripManager fectchPointsForDrawing:NO] onMapView:self.mapView];
        
    }
    
    //Update the views
    self.latLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.latitude];
    self.lonLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.longitude];
    

    
    float currentSpeed = [[GeoManager sharedManager] currentSpeed] * settingsManager.speedMultiplier;
    
    if(currentSpeed < 0.0){
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"0.0 %@",settingsManager.unitLabelSpeed];
    }else{
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"%.2f %@",currentSpeed,settingsManager.unitLabelSpeed];
    }
}

-(void)updateCompassWithHeading {
    
    CABasicAnimation *theAnimation;
    
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    theAnimation.fromValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] fromHeadingAsRad]];
    theAnimation.toValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] toHeadingAsRad]];
    
    [self.compassNeedle.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    self.compassNeedle.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
    self.compassBackground.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
}

-(void)handleSettingsChange {
    [self updateLocation];
}


#pragma memory handling
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
