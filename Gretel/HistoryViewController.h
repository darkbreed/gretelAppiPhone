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
#import "TripManager.h"
#import "ShareManager.h"
#import "SettingsManager.h"
#import <QuartzCore/QuartzCore.h>

@interface HistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;

@property (nonatomic, strong) NSMutableArray *cachedMapViews;

@end
