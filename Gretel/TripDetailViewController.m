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
    self.title = [[tripManager currentTrip] tripName];
    
    tripManager = [TripManager sharedManager];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSArray *points = [tripManager fectchPointsForDrawing:YES];
    
    self.title = tripManager.tripForDetailView.tripName;
    
    [self drawRoute:points onMapView:self.mapView];
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
            
            [tripManager.tripForDetailView deleteInContext:[NSManagedObjectContext defaultContext]];
            [[NSManagedObjectContext defaultContext] saveNestedContexts];
            [tripManager fetchAllTrips];
            
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
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resume trip" message:@"Would you like to resume this trip? If you have trips in progress these will be stopped and saved" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resume", nil];
    
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1){
        [[TripManager sharedManager] saveTripAndStop];
        [[TripManager sharedManager] setCurrentTrip:tripManager.tripForDetailView];
        [[TripManager sharedManager] setTripForDetailView:nil];
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


@end
