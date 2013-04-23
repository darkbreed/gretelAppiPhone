//
//  CompletedTripViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "TripDetailViewController.h"
#import "ShareManager.h"

NSString * const GTTripIsResuming = @"tripIsResuming";

@interface TripDetailViewController ()

@end

@implementation TripDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripDeletionHandler:) name:GTTripDeletedSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripImportBeganHandler:) name:TRIP_IMPORT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripImportSuccessHandler:) name:GTTripImportedSuccessfully object:nil];
    
    
    self.title = [[tripManager currentTrip] tripName];
    
    tripManager = [TripManager sharedManager];
    
    self.tripNameField.delegate = self;
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:self.view];
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setSize:18.0];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor whiteColor], nil]];
    [iconFactory setSquare:YES];
    [iconFactory setStrokeColor:[UIColor blackColor]];
    [iconFactory setStrokeWidth:0.2];
    
    [self.navigationItem.leftBarButtonItem setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconList]];
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:[tripManager.tripForDetailView.tripDuration floatValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.durationLabel.text = timeString;
    
    float distance = [tripManager.tripForDetailView.totalDistance floatValue];
    
    if([[SettingsManager sharedManager] unitType] == GTAppSettingsUnitTypeMPH){
        distance = distance * [[SettingsManager sharedManager] distanceMultiplier];
    }else{
        distance = distance / [[SettingsManager sharedManager] distanceMultiplier];
    }
    
    //self.durationLabel.text = [NSString stringWithFormat:@"%.2f",[tripManager.tripForDetailView.tripDuration floatValue]];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f %@",distance,[[SettingsManager sharedManager] unitLabelDistance]];
    self.pointsRecordedLabel.text = [NSString stringWithFormat:@"%i",[tripManager.tripForDetailView.points count]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.notificationView setTextLabel:@"Drawing route"];
    [self.notificationView setShowActivity:YES animated:YES];
    [self.notificationView show:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *points = [tripManager fectchPointsForDrawing:YES];
        
        self.title = tripManager.tripForDetailView.tripName;
        
        [self drawRoute:points onMapView:self.mapView willRefreh:NO];
        [self addAnnotationsToMapView:self.mapView fromArray:points];
        [self zoomToFitMapView:self.mapView toFitRoute:points animated:NO];
        
        [self.notificationView hideAnimated];
        
    });
}

-(void)viewDidDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == TripActionSheetTypeDelete){
        
        switch (buttonIndex) {
            case CompletedTripOptionTypeDelete:
                [[TripManager sharedManager] deleteTrip:tripManager.tripForDetailView];
                break;
            default:
                break;
        }
        
    }else if(actionSheet.tag == TripActionSheetTypeMapStyle){
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
    
}

-(IBAction)deleteButtonHandler:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@? This cannot be undone.", tripManager.tripForDetailView.tripName];
    
    UIActionSheet *confirmSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
    [confirmSheet setTag:TripActionSheetTypeDelete];
    [confirmSheet showInView:self.view];
}

-(IBAction)shareButtonHandler:(UIButton *)sender {
    [self.tripEditForm setHidden:YES];
    [self.tripShareForm setHidden:NO];
    [self hideMapViewAndOptions:YES];
}

-(IBAction)editButtonHandler:(UIButton *)sender {
    [self.tripShareForm setHidden:YES];
    [self.tripEditForm setHidden:NO];
    [self hideMapViewAndOptions:YES];
}

-(IBAction)resumeButtonHandler:(id)sender {
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resume trip?" message:@"Would you like to resume this trip? If you have trips in progress these will be stopped and saved. If you are resuming a trip imported from an external source, it will appear in the recordings section from now on." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resume", nil];
    
    [alertView show];
    
}

-(IBAction)saveTripButtonHandler:(id)sender {
    
    [tripManager.tripForDetailView setTripName:self.tripNameField.text];
    self.title = self.tripNameField.text;
    [[TripManager sharedManager] saveTrip];
    [self.tripNameField resignFirstResponder];
    [self hideMapViewAndOptions:NO];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1){
        
        [tripManager.tripForDetailView setReceivedFromRemote:[NSNumber numberWithBool:NO]];
        [[TripManager sharedManager] saveTripAndStop];
        [[TripManager sharedManager] setCurrentTrip:tripManager.tripForDetailView];
        [[TripManager sharedManager] setTripForDetailView:nil];
        [[TripManager sharedManager] setTripState:GTTripStateRecording];
        [[TripManager sharedManager] setIsResuming:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GTTripIsResuming object:nil];
    }
}

-(IBAction)cancelButtonHandler:(UIButton *)sender {
    [self hideMapViewAndOptions:NO];
}

-(IBAction)shareByBluetoothButtonHandler:(id)sender {
    
}

-(IBAction)shareByEmailButtonHandler:(id)sender {
    
    if(!shareManager){
        shareManager = [[ShareManager alloc] initWithShareType:ShareManagerShareTypeEmail fromViewController:self];
    }
    
    [shareManager shareTripDataByEmail:[NSArray arrayWithObject:tripManager.tripForDetailView]];
    
}

-(IBAction)actionButtonHandler:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set map type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Standard",@"Satellite",@"Hybrid", nil];
    [actionSheet setTag:TripActionSheetTypeMapStyle];
    [actionSheet showInView:self.view];
}


#pragma mark TripDeletion handlers
-(void)tripDeletionHandler:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
