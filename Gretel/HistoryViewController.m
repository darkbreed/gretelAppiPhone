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
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    tripManager = [TripManager sharedManager];
    tripManager.allTrips.delegate = self;
    
    [self.tableView reloadData];
    
    [self configureMapViewsForCells];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
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

-(void)configureMapViewsForCells {
    
    self.cachedMapViews = [NSMutableArray array];
    
    for (Trip *trip in [[tripManager allTrips] fetchedObjects]) {
        
        MKMapView *mapView = [[MKMapView alloc] init];
        [mapView setUserInteractionEnabled:NO];
        [mapView setScrollEnabled:NO];
        [mapView setFrame:self.view.frame];
        [self zoomMapView:mapView forTrip:trip];
        //[self.cachedMapViews addObject:mapView];
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[mapView layer] renderInContext:context];
        UIImage *thumbnail_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.cachedMapViews addObject:thumbnail_image];
    }
}


-(void)zoomMapView:(MKMapView *)mapView forTrip:(Trip *)trip {
    if([trip.points count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(GPSPoint *point in trip.points)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [point.lon doubleValue]);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [point.lat doubleValue]);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [point.lon doubleValue]);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [point.lat doubleValue]);
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5,
                                                               topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5,
                                                 fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5	);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [mapView regionThatFits:region];
    [mapView setRegion:region animated:NO];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self zoomMapView:cell.mapView forTrip:trip];
    [cell.mapView setUserInteractionEnabled:NO];
    [cell.mapView setScrollEnabled:NO];
        
    [cell.distanceLabel setText:[NSString stringWithFormat:@"%.1f %@",[tripManager calculateDistanceForPoints:trip],[[SettingsManager sharedManager] unitLabelDistance]]];
    [cell.recordedPointsLabel setText:[NSString stringWithFormat:@"%i TRACKPOINTS",[trip.points count]]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    [cell.tripNameLabel setText:[NSString stringWithFormat:@"%@",trip.tripName]];
    
    
    
    return cell;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 150;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.tableView.editing){
        
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        
        [self.shareButton setTitle:[NSString stringWithFormat:@"Share (%i)",selectedRows.count]];
        [self.deleteButton setTitle:[NSString stringWithFormat:@"Delete (%i)",selectedRows.count]];
        
        [self.shareButton setEnabled:YES];
        [self.deleteButton setEnabled:YES];
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

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if(self.tableView.editing){
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

-(void)deleteMultipleTrips {
    
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [tripManager deleteTripAtIndexPath:indexPath];
        [self.tableView setEditing:NO animated:YES];
        [self.deleteButton setTitle:@"Delete"];
        [self.shareButton setTitle:@"Share"];
    }
    
}

@end