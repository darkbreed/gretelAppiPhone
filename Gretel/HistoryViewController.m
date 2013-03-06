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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    tripManager = [TripManager sharedManager];
    tripManager.allTrips.delegate = self;

    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    tripManager.allTrips.delegate = nil;
    tripManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sections = [[tripManager.allTrips sections] count];
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[tripManager.allTrips sections] objectAtIndex:section];
    
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        
    id<NSFetchedResultsSectionInfo> sectionInfo = [[tripManager.allTrips sections] objectAtIndex:section];
    int rows = [sectionInfo numberOfObjects];
    
    // Return the number of rows in the section.
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *CellIdentifier = @"Cell";
    TripHistoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Trip *trip = [tripManager tripWithIndexPath:indexPath];
    
    if([trip.recordingState isEqualToString:[tripManager recordingStateForState:GTTripStatePaused]]){
        [cell.recordingBannerImage setImage:[UIImage imageNamed:@"completeLabel.png"]];
        [cell.recordingBannerLabel setText:[NSString stringWithFormat:@"%@",trip.startDate]];
    }
    
    [cell.tripNameLabel setText:[NSString stringWithFormat:@"%@",trip.tripName]];
    [cell zoomMapViewToFitTrip:trip];
    [cell.mapView setUserInteractionEnabled:NO];
    [cell.mapView setScrollEnabled:NO];
    
    return cell;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 150;
}

-(void)configureTableCellMapForTrip:(Trip *)trip {
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tripManager deleteTripAtIndexPath:indexPath];
        
    }
      
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
        case NSFetchedResultsChangeDelete:
            
            // Delete the row from the data source
            if([self.tableView numberOfRowsInSection:[indexPath section]] > 1) {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]]
                         withRowAnimation:UITableViewRowAnimationFade];
            }
            
            break;
        case NSFetchedResultsChangeInsert:
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
        default:
            break;
    }
    
    
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
//    selectedTrip = [trips objectAtIndex:[self.tableView indexPathForSelectedRow].row];
//    
//    if([selectedTrip.recordingState isEqualToString:[Trip recordingStateStringForRecordingState:TripRecordingStateRecording]]){
//        return NO;
//    }else{
//        return YES;
//    }
    
    return YES;
    
}

#pragma mark - Table view delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"pushCompletedTripScreen"]){
    
        //[tripManager setCurrentTrip:[[tripManager allTrips] objectAtIndexPath:[self.tableView indexPathForSelectedRow]]];
        
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

@end
