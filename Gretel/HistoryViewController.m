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
    
    tripManager = [TripManager sharedManager];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
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
    
    NSLog(@"Trips: %@",tripManager.allTrips);
    
    // Return the number of rows in the section.
    return [tripManager.allTrips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *CellIdentifier = @"Cell";
    TripHistoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Trip *trip = [tripManager tripWithIndex:indexPath.row];
    
    NSLog(@"Trip state: %@",trip.recordingState);
    
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
        
        [tripManager deleteTripAtIndex:indexPath.row];
        
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
    
        [tripManager setCurrentTrip:[[tripManager allTrips] objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        
    }
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tripName contains [cd] %@",searchText];
    
    //trips = [[Trip findAllSortedBy:@"tripName" ascending:NO withPredicate:predicate] mutableCopy];
    
    [self.tableView reloadData];
    
}

@end
