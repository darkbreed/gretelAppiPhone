//
//  SettingsMenuViewController.m
//  Gretel
//
//  Created by Ben Reed on 17/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "SettingsMenuViewController.h"
#import "SettingsMenuCell.h"
#import "RecordNewTripViewController.h"
#import "HistoryViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>

@interface SettingsMenuViewController ()

@property (nonatomic, strong) NSDictionary *viewControllers;

@property (nonatomic, readwrite) BOOL shouldLoadInbox;

@end

@implementation SettingsMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.shouldLoadInbox = NO;
    
    if(!self.viewControllers){
        
        RecordNewTripViewController *recordNewTripViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"recordTrip"];
        
        HistoryViewController *historyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tripHistory"];
        
        SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
        
        AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"about"];
        
        self.viewControllers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:recordNewTripViewController,historyViewController, settingsViewController, aboutViewController, nil] forKeys:[NSArray arrayWithObjects:@"recordTrip",@"tripHistory",@"settings",@"about", nil]];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    
    switch (section) {
        case 0:
            sectionTitle = @"Map";
            break;
        
        case 1:
            sectionTitle = @"Trips";
            break;
            
        case 2:
            sectionTitle = @"Settings";
            break;
    }
    
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int rowsInSection = 0;
    
    switch (section) {
        case 0:
            rowsInSection = 1;
            break;
        
        case 1:
            rowsInSection = 2;
            break;
        
        case 2:
            rowsInSection = 2;
            break;
    }
    
    // Return the number of rows in the section.
    return rowsInSection;

}

- (SettingsMenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SettingsMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.textColor = [UIColor lightGrayColor];
    [cell.titleLabel setBackgroundColor:[UIColor clearColor]];
    [cell.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    cell.titleLabel.shadowColor = [UIColor blackColor];
    cell.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    if(indexPath.section == 0){
        
        if(indexPath.row == 0){
            
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconMapMarker]];
            cell.titleLabel.text = [@"Map screen" uppercaseString];
            
        }
        
    }else if(indexPath.section == 1){
        
        if(indexPath.row == 0){
            
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconList]];
            cell.titleLabel.text = [@"Recorded" uppercaseString];
            
        }else if(indexPath.row == 1){
            
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconEnvelope]];
            cell.titleLabel.text = [@"Inbox" uppercaseString];
        
        }
        
    }else if(indexPath.section == 2){
        
        if(indexPath.row == 0){
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconCogs]];
            cell.titleLabel.text = [@"Settings" uppercaseString];
        }
        
        if(indexPath.row == 1){
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconInfoSign]];
            cell.titleLabel.text = [@"About" uppercaseString];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor grayColor]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, tableView.frame.size.width, 30)];
    [headerLabel setText:[[self tableView:tableView titleForHeaderInSection:section] uppercaseString]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    headerLabel.shadowColor = [UIColor lightGrayColor];
    headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [view addSubview:headerLabel];
    
    return  view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *identifier = nil;
    
    if(indexPath.section == 0){
        
        if(indexPath.row == 0){
            
            identifier = @"recordTrip";
            
        }
        
    }else if(indexPath.section == 1){
        
        if(indexPath.row == 0){
            
            identifier = @"tripHistory";
            
        }else if(indexPath.row == 1){
            
            identifier = @"tripHistory";
            self.shouldLoadInbox = YES;
            
        }
        
    }else if(indexPath.section == 2){
        
        if(indexPath.row == 0){
            
            identifier = @"settings";
            
        }else if(indexPath.row == 1){
            
            identifier = @"about";
            
        }
        
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        if([[self.viewControllers objectForKey:identifier] isKindOfClass:[HistoryViewController class]]){
            
            HistoryViewController *historyViewController = (HistoryViewController *)[self.viewControllers objectForKey:identifier];
            
            if(self.shouldLoadInbox){
                
                historyViewController.isInInboxMode = YES;
            }else{
                historyViewController.isInInboxMode = NO;
            }
        }
        
        self.slidingViewController.topViewController = [self.viewControllers objectForKey:identifier];
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
        
    }];
        
}

-(IBAction)menuButtonHandler:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
