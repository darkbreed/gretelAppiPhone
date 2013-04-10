//
//  HistoryViewController.m
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "HistoryViewController.h"
#import "GeoManager.h"
#import "Trip.h"
#import "TripDetailViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController {
    TripManager *tripManager;
    ShareManager *shareManager;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripDeleteSuccess:) name:GTTripDeletedSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingSuccessHandler:) name:SMMailSendingSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingFailedHandler:) name:SMMailSendingFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingCancelHandler:) name:SMMailSendingCancelled object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSendingSavedHandler:) name:SMMailSaved object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteMultipleTrips)];
    [self.deleteButton setTintColor:[UIColor redColor]];
    [self.deleteButton setEnabled:NO];
    
    self.shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(shareMultipleTrips)];
    [self.shareButton setEnabled:NO];
    
    [self setToolbarItems:[NSArray arrayWithObjects:self.shareButton, self.deleteButton, nil]];
    
    self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:@""
                                                                showActivity:NO
                                                          inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                      inView:self.tableView];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
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

- (void)viewDidAppear:(BOOL)animated {
    
    tripManager = [TripManager sharedManager];
    tripManager.allTrips.delegate = self;
    
    [tripManager fetchAllTrips];
    
    if([tripManager.allTrips.fetchedObjects count] == 0){
        self.noResultsToDisplay = YES;
    }else{
        self.noResultsToDisplay = NO;
    }
    
    [self.tableView reloadData];
    
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [super setEditing:editing animated:animated];
    
    if(editing){
        [self.navigationController setToolbarHidden:NO animated:YES];
    }else{
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    tripManager.allTrips.delegate = nil;
    tripManager = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    if(self.editing){
        [self setEditing:NO animated:YES];
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
    
    if(self.noResultsToDisplay){
        
        return 1;
        
    }else{
        int sections = [[tripManager.allTrips sections] count];
        return sections;
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[tripManager.allTrips sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.noResultsToDisplay){
        return 1;
        
    }else{
        
        id<NSFetchedResultsSectionInfo> sectionInfo = [[tripManager.allTrips sections] objectAtIndex:section];
        int rows = [sectionInfo numberOfObjects];
        
        // Return the number of rows in the section.
        return rows;
    
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if(self.noResultsToDisplay){
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        cell.textLabel.text = @"No results to display";
        
        return cell;
        
    }else{
        
        TripHistoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Trip *trip = [tripManager tripWithIndexPath:indexPath];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell.distanceLabel setText:[NSString stringWithFormat:@"%.1f %@",[trip.totalDistance floatValue],[[SettingsManager sharedManager] unitLabelDistance]]];
        
        NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:[trip.tripDuration floatValue]];
        
        NSDateFormatter *timerDateFormatter = [[NSDateFormatter alloc] init];
        [timerDateFormatter setDateFormat:@"HH:mm:ss"];
        [timerDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        
        [cell.recordedPointsLabel setText:[NSString stringWithFormat:@"%i TRACKPOINTS",[trip.points count]]];
        [cell.tripDurationLabel setText:[timerDateFormatter stringFromDate:timerDate]];
        [cell.tripNameLabel setText:[NSString stringWithFormat:@"%@",trip.tripName]];
        
        return cell;
    }
    
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 64.0f;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tripManager deleteTrips:[NSArray arrayWithObject:indexPath]];
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.tableView.editing){
        
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        
        [self.shareButton setTitle:[NSString stringWithFormat:@"Share (%i)",selectedRows.count]];
        [self.deleteButton setTitle:[NSString stringWithFormat:@"Delete (%i)",selectedRows.count]];
        
        [self.shareButton setEnabled:YES];
        [self.deleteButton setEnabled:YES];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            break;
        case NSFetchedResultsChangeInsert:
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
        default:
            break;
    }
    
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if(self.tableView.editing || self.noResultsToDisplay){
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Table view delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"pushCompletedTripScreen"]){
                
        [tripManager setTripForDetailView:[[tripManager allTrips] objectAtIndexPath:[self.tableView indexPathForSelectedRow]]];
        
    }
    
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [tripManager searchTripsByKeyword:searchText];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [tripManager fetchAllTrips];
}

-(void)shareMultipleTrips {
    
    NSMutableArray *tripsToShare = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        
        Trip *trip = [tripManager.allTrips objectAtIndexPath:indexPath];
        [tripsToShare addObject:trip];
    }
    
    shareManager = [[ShareManager alloc] initWithShareType:ShareManagerShareTypeEmail fromViewController:self];
    [shareManager shareTripDataByEmail:tripsToShare];
    
}

-(void)tripDeleteSuccess:(NSNotification *)notification {
    
    [self.deleteButton setTitle:@"Delete"];
    [self.shareButton setTitle:@"Share"];
    [self.tableView setEditing:NO animated:YES];
    [self setEditing:NO animated:YES];
    
}

-(void)deleteMultipleTrips {
    
    [tripManager deleteTrips:[self.tableView indexPathsForSelectedRows]];
    
}

@end