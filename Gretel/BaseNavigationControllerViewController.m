//
//  BaseNavigationControllerViewController.m
//  Gretel
//
//  Created by Ben Reed on 18/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "BaseNavigationControllerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseNavigationControllerViewController ()

@end

@implementation BaseNavigationControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSLog(@"Top VC: %@", self.topViewController);
    
    self.topViewController.navigationController.view.layer.shadowOpacity = 0.75f;
    self.topViewController.navigationController.view.layer.shadowRadius = 10.0f;
    self.topViewController.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
