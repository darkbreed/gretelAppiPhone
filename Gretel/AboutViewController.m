//
//  AboutViewController.m
//  Gretel
//
//  Created by Ben Reed on 11/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self.versionNumberLabel setText:[NSString stringWithFormat:@"VERSION %@",version]];
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setSize:18.0];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor whiteColor], nil]];
    [iconFactory setSquare:YES];
    [iconFactory setStrokeColor:[UIColor blackColor]];
    [iconFactory setStrokeWidth:0.2];
    
    [self.navigationItem.leftBarButtonItem setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconList]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
