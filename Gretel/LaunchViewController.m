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

@implementation LaunchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    BOOL recording = [[GeoManager sharedManager] recording];
    
    if(recording){
        [self.startNewTripButton setTitle:@"View current trip" forState:UIControlStateNormal];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.destinationViewController isKindOfClass:[RecordNewTripViewController class]]){
        RecordNewTripViewController *recordNewTripViewController = segue.destinationViewController;
        [recordNewTripViewController setCurrentTripState:kTripStateNew];
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
