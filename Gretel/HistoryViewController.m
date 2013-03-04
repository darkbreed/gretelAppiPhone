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

@implementation HistoryViewController

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
    
    tripTappedInProgress = NO;

}

- (void)viewDidAppear:(BOOL)animated {
    
    trips = [[Trip findAllSortedBy:@"startDate" ascending:NO] mutableCopy];
    [self.tableView reloadData];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [trips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *CellIdentifier = @"Cell";
    TripHistoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Trip *trip = [trips objectAtIndex:indexPath.row];
        
    [cell.tripNameLabel setText:[NSString stringWithFormat:@"%@",trip.tripName]];
    [cell zoomMapViewToFitTrip:trip];
    [cell.mapView setUserInteractionEnabled:NO];
    [cell.mapView setScrollEnabled:NO];
    
    if([trip.recordingState isEqualToString:[Trip recordingStateStringForRecordingState:TripRecordingStateRecording]]){
        [cell.recordingBannerLabel setText:[NSString stringWithFormat:@"%@",@"In progress"]];
    }else if([trip.recordingState isEqualToString:[Trip recordingStateStringForRecordingState:TripRecordingStateStopped]]){
        [cell.recordingBannerImage setImage:[UIImage imageNamed:@"completeLabel.png"]];
        [cell.recordingBannerLabel setText:[NSString stringWithFormat:@"%@",trip.startDate]];
    }
    
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
    
    Trip *trip = [trips objectAtIndex:indexPath.row];
    
    if([trip.recordingState isEqualToString:[Trip recordingStateStringForRecordingState:TripRecordingStateStopped]]){
        return YES;
    }else{
        return NO;
    }
    
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Trip *tripToDelete = [trips objectAtIndex:indexPath.row];
        
        [tripToDelete deleteInContext:[NSManagedObjectContext MR_defaultContext]];
        [trips removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
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
    
    selectedTrip = [trips objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    
    if([selectedTrip.recordingState isEqualToString:[Trip recordingStateStringForRecordingState:TripRecordingStateRecording]]){
        return NO;
    }else{
        return YES;
    }
    
}

#pragma mark - Table view delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"pushCompletedTripScreen"]){
    
        TripDetailViewController *completedTripViewController = segue.destinationViewController;
        completedTripViewController.trip = selectedTrip;
        
    }
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@",searchText];
    trips = [[Trip findAllSortedBy:@"tripName" ascending:NO withPredicate:predicate] mutableCopy];
    
    [self.tableView reloadData];
    
}

@end
