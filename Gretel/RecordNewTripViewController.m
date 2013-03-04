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

@implementation RecordNewTripViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                           showActivity:NO
                                                     inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                 inView:self.mapView];
    
    [self setUpViewForNewTrip];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompassWithHeading) name:GTLocationHeadingDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseRecording) name:GTLocationDidPauseUpdates object:nil];
    
    [self setInitialLocate:YES];
    
    [self.currentSpeedLabel setText:[NSString stringWithFormat:@"0.0 %@",[[SettingsManager sharedManager] unitLabel]]];
    
    if([[GeoManager sharedManager] locationServicesEnabled]){
        
        NSLog(@"Location services enabled: %i",[[GeoManager sharedManager] locationServicesEnabled]);
        
        [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolEnabled.png"] forState:UIControlStateNormal];
    }
    
    tripManager = [TripManager sharedManager];

}

- (void)viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:animated];
        
    //If we are, set up the button accordingly
    if(tripManager.isRecording){
        [self setViewStateForTripState:kTripStateRecording];
    }
    
    [self setTitle:tripManager.currentTrip.tripName];
    
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
    
    tripManager.currentTrip = nil;
    tripManager.isRecording = NO;
    //recordedPoints = [[NSMutableArray alloc] init];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self setViewStateForTripState:kTripStateNew];
}

-(void)displayLocationServicesDisabledAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services disabled" message:@"Gretel cannot track your location as your location services have been disabled. Please enable them in the Settings, then return to the app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    
    [self.locateMeButton setBackgroundImage:[UIImage imageNamed:@"locationSymbolDisabled.png"] forState:UIControlStateNormal];
}

-(void)setViewStateForTripState:(kTripState)tripState {
    
    switch (tripState) {
            
        case kTripStateNew: {
            
            [self.recordingIndicatorContainer setHidden:YES];
            [self.notificationView hide:YES];
            [self.stopButton setEnabled:NO];
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            
            break;
            
        }
            
        case kTripStatePaused: {
            //we are recording, the user has paused the tracking
            self.isRecording = NO;
            
            //Start tracking the users location
            [[GeoManager sharedManager] stopTrackingPosition];
            
            //change the recording button to pause
            [tripManager setCurrentTripState:kTripStatePaused];
            
            //Notify the user
            [self.notificationView setTextLabel:@"Recording paused"];
            [self.notificationView show:YES];
            
            [self.recordingIndicatorContainer setHidden:YES];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            
            [self.stopButton setEnabled:YES];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nil];
            
            break;
        }
            
        case kTripStateRecording: {
            //We are paused, the user is resuming tracking
            self.isRecording = YES;
            
            //Start tracking the users location
            [[GeoManager sharedManager] startTrackingPosition];
            
            //change the recording button to pause
            [tripManager setCurrentTripState:kTripStateRecording];
            
            [self.notificationView setTextLabel:@"Recording"];
            [self.notificationView showAndDismissAutomaticallyAnimated];
            [self.recordingIndicatorContainer setHidden:NO];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            
            [self.stopButton setEnabled:YES];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            
            break;
        }
    }
    
}


#pragma Button Handlers
-(IBAction)startTrackingButtonHandler:(id)sender {
    
    switch (tripManager.tripState) {
        case kTripStateNew:
            
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
            
            [tripManager beginRecording];
            
            break;
        
        case kTripStateRecording:
            [tripManager pauseRecording];
            [self setViewStateForTripState:kTripStatePaused];
            break;
            
        case kTripStatePaused:
            [self setViewStateForTripState:kTripStateRecording];
            [tripManager resumeRecording];
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
            [self saveAndFinishTrip];
        }
        
    }else if(alertView.tag == GTAlertViewTagBeginRecordingAlert){
        
        if(buttonIndex == 1){
            self.tripName = [[alertView textFieldAtIndex:0] text];
            
            [self setViewStateForTripState:kTripStateRecording];
            [tripManager setIsRecording:YES];
            
            [self createNewTrip];
        }
    }
}

-(void)resumeTripWithTrip:(Trip *)trip {
    //Load the trip
    self.currentTrip = trip;
    //Draw the route on the map
    [self drawRoute:[self.currentTrip.points allObjects] onMapView:self.mapView];
    
    //recordedPoints = [[[self.currentTrip points] allObjects] mutableCopy];
    [tripManager setCurrentTripState:kTripStateRecording];
    [self setViewStateForTripState:kTripStateRecording];
    
    resumingTrip = YES;
}

-(void)createNewTrip {
    [self setTitle:self.tripName];
    
    //Create a new trip object and save it
    [tripManager createNewTrip];
    [tripManager.currentTrip setStartDate:[NSDate date]];
    [tripManager.currentTrip setTripName:self.tripName];
    [tripManager.currentTrip setRecordingState:[Trip recordingStateStringForRecordingState:TripRecordingStateRecording]];
    [tripManager saveTrip];
}

-(void)saveAndFinishTrip {
    
    [tripManager.currentTrip setFinishDate:[NSDate date]];
    [tripManager.currentTrip setRecordingState:[Trip recordingStateStringForRecordingState:TripRecordingStateStopped]];
    [tripManager saveTrip];
    
    [tripManager setCurrentTrip:nil];
    [tripManager setCurrentTripState:kTripStateNew];
    [self setUpViewForNewTrip];

}

-(void)updateLocation {
    
    if(tripManager.isRecording){
    
        //Store the data point
        [tripManager storeLocation];
        [self drawRoute:[tripManager fectchPointsForDrawing] onMapView:self.mapView];
        
    }
    
    //Update the views
    self.latLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.latitude];
    self.lonLabel.text = [NSString stringWithFormat:@"%.3f",self.mapView.userLocation.coordinate.longitude];
    
    float currentSpeed = 0.0f;
    
    if([[SettingsManager sharedManager] getApplicationUnitType] == GTAppSettingsUnitTypeKPH){
        currentSpeed = [[GeoManager sharedManager] currentSpeed] * 2.23693629;
    }else {
        currentSpeed = [[GeoManager sharedManager] currentSpeed] * 3.6;
    }
    
    self.currentSpeedLabel.text = [NSString stringWithFormat:@"%.2f %@",currentSpeed,[[SettingsManager sharedManager] unitLabel]];

}

-(void)updateCompassWithHeading {
    
    CABasicAnimation *theAnimation;
    
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    theAnimation.fromValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] fromHeadingAsRad]];
    theAnimation.toValue = [NSNumber numberWithFloat:[[GeoManager sharedManager] toHeadingAsRad]];
    
    [self.compassNeedle.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    self.compassNeedle.transform = CGAffineTransformMakeRotation([[GeoManager sharedManager] toHeadingAsRad]);
}


#pragma memory handling
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
