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
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:GTLocationUpdatedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompassWithHeading) name:GTLocationHeadingDidUpdate object:nil];
    
    recordedPoints = [[NSMutableArray alloc] init];
    
    [self setInitialLocate:YES];

}

- (void)viewWillAppear:(BOOL)animated {
   
    [super viewWillAppear:animated];
    
    //Check if we are recording a trip
    BOOL recording = [[GeoManager sharedManager] recording];
    
    //If we are, set up the button accordingly
    if(recording){
        [self setCurrentTripState:kTripStateRecording];
    }
    
    [self setTitle:self.tripName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}   

- (void)setCurrentTripState:(kTripState)tripState {
        
    switch (tripState) {
        case kTripStateNew:
            
            self.tripState = tripState;
            self.navigationItem.hidesBackButton = NO;
            [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
            
            break;
        
        case kTripStateRecording:
            
            self.tripState = tripState;
            self.navigationItem.hidesBackButton = YES;
            [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
            
            break;
            
        case kTripStatePaused:
            
            self.tripState = tripState;
            self.navigationItem.hidesBackButton = YES;
            [self.startButton setTitle:@"Resume" forState:UIControlStateNormal];
            
            break;
    }
}


#pragma Button Handlers
-(IBAction)startTrackingButtonHandler:(id)sender {
    
    switch (self.tripState) {
        case kTripStateNew:
            
            //Start a new trip
            [self startNewTrip];
            
            break;
            
        case kTripStatePaused:
            //We are paused, the user is resuming tracking
            
            //Start tracking the users location
            [[GeoManager sharedManager] startTrackingPosition];
            
            //change the recording button to pause
            [self setCurrentTripState:kTripStateRecording];
            
            break;
            
        case kTripStateRecording:
            //we are recording, the user has paused the tracking
            
            //Start tracking the users location
            [[GeoManager sharedManager] stopTrackingPosition];
            
            //change the recording button to pause
            [self setCurrentTripState:kTripStatePaused];
            
            break;
    }
    
}

-(void)startNewTrip {
    
    //Create a new trip object and save it
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Trip *trip = [Trip MR_createInContext:context];
    [trip setDate:[NSDate date]];
    [trip setTripName:self.tripName];
    
    [context MR_save];
    
    //Set the current trip so we can save points to it
    self.currentTrip = trip;
    
    //Start tracking the users location
    [[GeoManager sharedManager] startTrackingPosition];
    
    //change the recording button to pause
    [self setCurrentTripState:kTripStateRecording];
    
}

-(IBAction)stopTrackingButtonHandler:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Stop recording?" message:@"Stopping the recording will end the trip, stop now?" delegate:self cancelButtonTitle:@"Keep recording" otherButtonTitles:@"Stop and save", nil];
    
    [alertView show];
    
}

#pragma mark UIAlertView message
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //Do nothing and keep recording
            break;
            
        case 1:
            
            //Stop the location manager
            [[GeoManager sharedManager] stopTrackingPosition];
            [self setCurrentTripState:kTripStateNew];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        default:
            break;
    }
    
}
-(IBAction)addButtonHandler:(id)sender {
    
    [self hideMapViewAndOptions:YES];

}

-(void)updateLocation {
    
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


-(IBAction)displayMap:(id)sender {
    [self hideMapViewAndOptions:NO];
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

@end
