//
//  CompletedTripViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "TripDetailViewController.h"
#import "GPXFactory.h"
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
    self.title = self.trip.tripName;
    
    GPXFactory *factory = [[GPXFactory alloc] init];
    route = [factory createArrayOfPointsFromSet:self.trip.points];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self drawRoute:route onMapView:self.mapView];
    [self addAnnotationsToMapView:self.mapView fromArray:route];
    [self zoomToFitMapView:self.mapView toFitRoute:route animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case CompletedTripOptionTypeDelete:
            [self.trip deleteInContext:[NSManagedObjectContext defaultContext]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
    
}

-(IBAction)deleteButtonHandler:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@? This cannot be undone.", self.trip.tripName];
    
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
    
    //Check all routes to see if any are recording
    NSArray *trips = [Trip findAll];
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resume trip" message:@"Would you like to resume this trip? If you have trips in progress these will be stopped and saved" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resume", nil];
    
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1){
        NSLog(@"Cancel");
        
        RecordNewTripViewController *recordTripController =[self.navigationController.viewControllers objectAtIndex:0];
        [recordTripController resumeTripWithTrip:self.trip];
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
        [shareManager setDelegate:self];
    }
    
    [shareManager shareTripDataByEmail:self.trip];
    
}

#pragma mark ShareManagerDelegate methods
-(void)shareManagerDidFinishSharingSuccessfully:(ShareManager *)manager {
    
}

@end