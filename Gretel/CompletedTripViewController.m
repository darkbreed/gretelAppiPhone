//
//  CompletedTripViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "CompletedTripViewController.h"
#import "GPXFactory.h"
#import "ShareManager.h"

@interface CompletedTripViewController ()

@end

@implementation CompletedTripViewController

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
    
    [self drawRoute:route onMapView:self.mapView];
    [self addAnnotationsToMapView:self.mapView fromArray:route];
    [self zoomToFitMapView:self.mapView toFitRoute:route animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Handlers
- (IBAction)shareButtonTapped:(id)sender {
    
    [[ShareManager sharedManager] displayShareOptionsInViewController:self withTripData:self.trip];

}

- (IBAction)deleteButtonTapped:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"Permanently delete %@?", self.trip.tripName];
   
    UIActionSheet *confirmSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    [confirmSheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self.trip deleteInContext:[NSManagedObjectContext defaultContext]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
    
}

@end
