//
//  LaunchViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "LaunchViewController.h"


@interface LaunchViewController ()

@end

@implementation LaunchViewController {
    NSString *newTripName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //Check if we are in the middle of a trip
    BOOL recording = [[GeoManager sharedManager] recording];
    
    //If so, set the button state accordingly
    if(recording){
        [self.startNewTripButton setTitle:@"View current trip" forState:UIControlStateNormal];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //Creating a new tip
    if([segue.destinationViewController isKindOfClass:[RecordNewTripViewController class]]){
        
        //Create the trip set the trip state and set the name that the user typed into the alert view field
        RecordNewTripViewController *recordNewTripViewController = segue.destinationViewController;
        [recordNewTripViewController setCurrentTripState:kTripStateNew];
        [recordNewTripViewController setTripName:newTripName];
    }
        
}

/**
 * Prompts the user to enter a name for the trip they are about to make
 * @param void
 * @return void
 */
-(IBAction)newTripButtonHandler:(id)sender {
    
    UIAlertView *newTripNameAlertView = [[UIAlertView alloc] initWithTitle:@"Create a new trip?" message:@"Give this trip a name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create trip", nil];
    
    [newTripNameAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newTripNameAlertView show];
}

#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case TripAlertViewButtonIndexCancel:
            //Cancel the creation of a trip
            break;
            
        case TripAlertViewButtonIndexCreate:
            //Create the new trip
            newTripName = [[alertView textFieldAtIndex:0] text];
            [self performSegueWithIdentifier:@"pushNewTripScreen" sender:self];
            
        default:
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
