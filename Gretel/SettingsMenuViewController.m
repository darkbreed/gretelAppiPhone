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
#import "BaseNavigationControllerViewController.h"
#import "TripDetailViewController.h"
#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString * const GTViewControllerRecordTrip = @"recordTrip";
NSString * const GTViewControllerTripHistory = @"tripHistory";
NSString * const GTViewControllerSettings = @"settings";
NSString * const GTViewControllerAbout = @"about";
NSString * const GTViewControllerHelp = @"help";

@interface SettingsMenuViewController ()

@property (nonatomic, strong) NSDictionary *viewControllers;
@property (nonatomic, readwrite) BOOL shouldLoadInbox;

@end

@implementation SettingsMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeHandler:) name:GTTripIsResuming object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInboxHandler:) name:GTTripGotoInbox object:nil];
    
    self.shouldLoadInbox = NO;
    
    if(!self.viewControllers){
        
        RecordNewTripViewController *recordNewTripViewController = [self.storyboard instantiateViewControllerWithIdentifier:GTViewControllerRecordTrip];
        HistoryViewController *historyViewController = [self.storyboard instantiateViewControllerWithIdentifier:GTViewControllerTripHistory];
        SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:GTViewControllerSettings];
        AboutViewController *aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:GTViewControllerAbout];
        
        self.viewControllers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:recordNewTripViewController,historyViewController, settingsViewController,aboutViewController, nil] forKeys:[NSArray arrayWithObjects:GTViewControllerRecordTrip,GTViewControllerTripHistory,GTViewControllerSettings,GTViewControllerAbout, nil]];
        
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
        case MenuSectionTypeMap:
            sectionTitle = @"Map";
            break;
        
        case MenuSectionTypeHistory:
            sectionTitle = @"Trips";
            break;
            
        case MenuSectionTypeOther:
            sectionTitle = @"Settings";
            break;
    }
    
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int rowsInSection = 0;
    
    switch (section) {
        case MenuSectionTypeMap:
            rowsInSection = 1;
            break;
        
        case MenuSectionTypeHistory:
            rowsInSection = 2;
            break;
        
        case MenuSectionTypeOther:
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
            cell.titleLabel.text = [@"Map" uppercaseString];
            
        }
        
    }else if(indexPath.section == 1){
        
        if(indexPath.row == 0){
            
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconListAlt]];
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
        
        if(indexPath.row == 2){
            [cell.iconView setImage:[iconFactory createImageForIcon:NIKFontAwesomeIconQuestionSign]];
            cell.titleLabel.text = [@"Help" uppercaseString];
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
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *identifier = nil;
    
    if(indexPath.section == MenuSectionTypeMap){
        if(indexPath.row == 0){
            identifier = GTViewControllerRecordTrip;
        }
    }else if(indexPath.section == MenuSectionTypeHistory){
        if(indexPath.row == 0){
            identifier = GTViewControllerTripHistory;
            self.shouldLoadInbox = NO;
        }else if(indexPath.row == 1){
            identifier = GTViewControllerTripHistory;
            self.shouldLoadInbox = YES;
        }
    }else if(indexPath.section == MenuSectionTypeOther){
        if(indexPath.row == 0){
            identifier = GTViewControllerSettings;
        }else if(indexPath.row == 1){
            identifier = GTViewControllerAbout;
        }else if(indexPath.row == 2){
            identifier = GTViewControllerHelp;
        }
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        if([[self.viewControllers objectForKey:identifier] isKindOfClass:[BaseNavigationControllerViewController class]]){
            
            BaseNavigationControllerViewController *navController = (BaseNavigationControllerViewController *)[self.viewControllers objectForKey:identifier];
            
            if([navController.topViewController isKindOfClass:[HistoryViewController class]]){
                
                HistoryViewController *historyViewController = (HistoryViewController *)navController.topViewController;
                
                if(self.shouldLoadInbox){
                    historyViewController.isInInboxMode = YES;
                }else{
                    historyViewController.isInInboxMode = NO;
                }
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

-(void)displayInboxHandler:(NSNotificationCenter *)notification {
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        BaseNavigationControllerViewController *historyNav = (BaseNavigationControllerViewController *)[self.viewControllers objectForKey:GTViewControllerTripHistory];
        
        HistoryViewController *history = (HistoryViewController *)[historyNav topViewController];
        history.isInInboxMode = YES;
        
        self.slidingViewController.topViewController = historyNav;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
        
    }];
}

-(void)resumeHandler:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            
            self.slidingViewController.topViewController = [self.viewControllers objectForKey:GTViewControllerRecordTrip];
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
            
        }];
        
    });
    
}

@end
