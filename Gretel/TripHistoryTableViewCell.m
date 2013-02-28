//
//  TripHistoryTableViewCell.m
//  Gretel
//
//  Created by Ben Reed on 28/02/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "TripHistoryTableViewCell.h"

@implementation TripHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)zoomMapViewToFitTrip:(Trip *)trip {
    
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
        
    [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:NO];
    
}

- (void)drawRoute:(NSArray *)route onMapView:(MKMapView *)mapView {
    
    NSInteger numberOfSteps = route.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        
        GPSPoint *point = [route objectAtIndex:index];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([point.lat doubleValue], [point.lon doubleValue]);
        
        coordinates[index] = coord;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [mapView addOverlay:polyLine];
    
}



@end
