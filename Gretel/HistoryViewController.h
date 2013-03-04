//
//  HistoryViewController.h
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "TripHistoryTableViewCell.h"

@interface HistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
    
    ///An array to hold the trips that will be pulled from CoreData
    NSMutableArray *trips;
    
    ///The selected trip to load the details for.
    Trip *selectedTrip;
    
    BOOL tripTappedInProgress;

}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end
