//
//  TripHistoryTableViewCell.h
//  Gretel
//
//  Created by Ben Reed on 28/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Trip.h"
#import "GPSPoint.h"

@interface TripHistoryTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *mapImageView;
@property (nonatomic, strong) IBOutlet UILabel *tripNameLabel;
@property (nonatomic, strong) IBOutlet UIView *recordingBanner;
@property (nonatomic, strong) IBOutlet UIImageView *recordingBannerImage;
@property (nonatomic, strong) IBOutlet UILabel *recordingBannerLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *recordedPointsLabel;
@property (nonatomic, strong) IBOutlet UILabel *tripDurationLabel;

- (void)zoomMapViewToFitTrip:(Trip *)trip;
- (void)drawRoute:(NSArray *)route onMapView:(MKMapView *)mapView;

@end
