//
//  CompletedTripViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "TripDetailViewController.h"
#import "ShareManager.h"

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
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripDeleteSuccess:) name:GTTripDeletedSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingSuccessHandler:) name:SMMailSendingSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingFailedHandler:) name:SMMailSendingFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingCancelHandler:) name:SMMailSendingCancelled object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingSavedHandler:) name:SMMailSaved object:nil];
    
    self.title = [[tripManager currentTrip] tripName];
    
    tripManager = [TripManager sharedManager];
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:self.view];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSArray *points = [tripManager fectchPointsForDrawing:YES];
    
    self.title = tripManager.tripForDetailView.tripName;
    
    [self drawRoute:points onMapView:self.mapView willRefreh:NO];
    [self addAnnotationsToMapView:self.mapView fromArray:points];
    [self zoomToFitMapView:self.mapView toFitRoute:points animated:NO];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case CompletedTripOptionTypeDelete:
            [[TripManager sharedManager] deleteTrip:tripManager.tripForDetailView];
            break;
        default:
            break;
    }
    
}

-(IBAction)deleteButtonHandler:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@? This cannot be undone.", tripManager.tripForDetailView.tripName];
    
    UIActionSheet *confirmSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
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
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resume trip" message:@"Would you like to resume this trip? If you have trips in progress these will be stopped and saved" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resume", nil];
    
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
        [[TripManager sharedManager] saveTripAndStop];
        [[TripManager sharedManager] setCurrentTrip:tripManager.tripForDetailView];
        [[TripManager sharedManager] setTripForDetailView:nil];
        [[TripManager sharedManager] setTripState:GTTripStateRecording];
        [[TripManager sharedManager] setIsResuming:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)mailSendingSuccessHandler:(NSNotification *)notification {
    [self.notificationView setTextLabel:@"Mail sent"];
    [self.notificationView showAndDismissAfter:2.0];
}

-(void)mailSendingCancelHandler:(NSNotification *)notification {
    [self.notificationView setTextLabel:@"Mail cancelled"];
    [self.notificationView showAndDismissAfter:2.0];
}

-(void)mailSendingFailedHandler:(NSNotification *)notification {
    [self.notificationView setTextLabel:@"Could not send mail"];
    [self.notificationView showAndDismissAfter:2.0];
}

-(void)mailSendingSavedHandler:(NSNotification *)notification {
    [self.notificationView setTextLabel:@"Mail saved to drafts"];
    [self.notificationView showAndDismissAfter:2.0];
}

#pragma mark TripDeletion handlers
-(void)tripDeletionHandler:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
