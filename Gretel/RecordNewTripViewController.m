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
    
    [self configureSettingsViewController];
    
    [self setUpViewForNewTrip];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompassWithHeading) name:GTLocationHeadingDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseRecording) name:GTLocationDidPauseUpdates object:nil];
    
    [self setInitialLocate:YES];
    
    
}

-(void)configureSettingsViewController {
    
    
}

-(IBAction)settingsButtonHandler:(id)sender {
    
    
}

- (void)viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:animated];
        
    //If we are, set up the button accordingly
    if(self.isRecording){
        [self setViewStateForTripState:kTripStateRecording];
    }
    
    [self setTitle:self.tripName];
}


-(void)setUpViewForNewTrip {
    
    self.currentTrip = nil;
    self.isRecording = NO;
    recordedPoints = [[NSMutableArray alloc] init];
    
    [self setViewStateForTripState:kTripStateNew];
}

- (void)setCurrentTripState:(kTripState)tripState {
    self.tripState = tripState;
}

-(void)beginRecording {
    
    if(!context){
        
        //Create a new trip object and save it
        context = [NSManagedObjectContext MR_contextForCurrentThread];
        Trip *trip = [Trip MR_createInContext:context];
        [trip setDate:[NSDate date]];
        [trip setTripName:self.tripName];
        
        [context MR_save];
        
        //Set the current trip so we can save points to it
        self.currentTrip = trip;
    }
    
    [self setViewStateForTripState:kTripStateRecording];
    [self setIsRecording:YES];
}

-(void)stopRecording {
    [self setIsRecording:NO];
}

-(void)pauseRecording {
    [self setIsRecording:NO];
    [self setViewStateForTripState:kTripStatePaused];
}

-(void)setViewStateForTripState:(kTripState)tripState {
    
    switch (tripState) {
            
        case kTripStateNew: {
            
            [self.recordingIndicatorContainer setHidden:YES];
            [self.notificationView hide:YES];
            
            break;
            
        }
            
        case kTripStatePaused: {
            //we are recording, the user has paused the tracking
            self.isRecording = NO;
            
            //Start tracking the users location
            [[GeoManager sharedManager] stopTrackingPosition];
            
            //change the recording button to pause
            [self setCurrentTripState:kTripStatePaused];
            
            //Notify the user
            [self.notificationView setTextLabel:@"Recording paused"];
            [self.notificationView show:YES];
            
            [self.recordingIndicatorContainer setHidden:YES];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"recordButton.png"] forState:UIControlStateNormal];
            
            
            break;
        }
            
        case kTripStateRecording: {
            //We are paused, the user is resuming tracking
            self.isRecording = YES;
            
            //Start tracking the users location
            [[GeoManager sharedManager] startTrackingPosition];
            
            //change the recording button to pause
            [self setCurrentTripState:kTripStateRecording];
            
            [self.notificationView setTextLabel:@"Recording"];
            [self.notificationView showAndDismissAutomaticallyAnimated];
            [self.recordingIndicatorContainer setHidden:NO];
            
            [self.startButton setBackgroundImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            
            break;
        }
    }
    
}


#pragma Button Handlers
-(IBAction)startTrackingButtonHandler:(id)sender {
    
    switch (self.tripState) {
        case kTripStateNew:
            [self beginRecording];
            break;
        
        case kTripStateRecording:
            [self pauseRecording];
            break;
            
        case kTripStatePaused:
            [self beginRecording];
            break;
            
        default:
            break;
    }
    
}

-(IBAction)stopTrackingButtonHandler:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Stop recording?" message:@"Stopping the recording will end the trip, stop now?" delegate:self cancelButtonTitle:@"Keep recording" otherButtonTitles:@"Stop and save", nil];
    
    [alertView show];
    
}

-(IBAction)addButtonHandler:(id)sender {
    
    [self hideMapViewAndOptions:YES];
    
}

-(IBAction)saveButtonHandler:(id)sender {
    
    
}

-(IBAction)displayMap:(id)sender {
    [self hideMapViewAndOptions:NO];
}


#pragma mark UIAlertView message
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //Do nothing and keep recording
            break;
            
        case 1:
        
            [self setTripState:kTripStateNew];
            [self setUpViewForNewTrip];
            
        default:
            break;
    }
    
}

-(void)updateLocation {
    
    if(self.isRecording){
    
        //Store the data point
        [self storeLocationPoint:[GeoManager sharedManager].currentLocation];
        
        //Check to see if the view is off screen as otherwise the frame is reset
        if(self.mapView.frame.origin.y != mapOffFrame.origin.y){
        
            //Update the views
            self.latLabel.text = [NSString stringWithFormat:@"%f",self.mapView.userLocation.coordinate.latitude];
            self.lonLabel.text = [NSString stringWithFormat:@"%f",self.mapView.userLocation.coordinate.longitude];
            self.currentSpeedLabel.text = [NSString stringWithFormat:@"%f",[[GeoManager sharedManager] currentSpeed]];
            
            [self drawRoute:recordedPoints onMapView:self.mapView];
            
        }
        
    }

}


#pragma CoreData methods
-(void)storeLocationPoint:(CLLocation *)location {
    
    if(location.coordinate.latitude != 0.0){
        //Create the GPS point
        GPSPoint *point = [GPSPoint MR_createEntity];
        point.altitude = [NSNumber numberWithDouble:location.altitude];
        point.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        point.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        point.timestamp = [NSDate date];
        point.pointID = [NSNumber numberWithInt:currentPointId++];
        
        //Add it to the current trip for storage
        [self.currentTrip addPointsObject:point];
        
        //Add it to the recorded points array to draw the line on the map
        [recordedPoints addObject:point];
        
        //Save
        [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContextsErrorHandler:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }
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
