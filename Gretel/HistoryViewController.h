//
//  HistoryViewController.h
//  Gretel
//
//  Created by Ben Reed on 13/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface HistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>{
    
    ///An array to hold the trips that will be pulled from CoreData
    NSMutableArray *trips;
    
    ///The selected trip to load the details for.
    Trip *selectedTrip;
    
}

@end
