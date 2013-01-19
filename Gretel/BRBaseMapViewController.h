//
//  BRBaseMapViewController.h
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BRMapAnnotation.h"
#import "GPSPoint.h"

@interface BRBaseMapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) BOOL initialLocate;
@property (nonatomic, strong) MKPolylineView *polylineView;

- (void)zoomToFitMapView:(MKMapView*)mapView toFitRoute:(NSArray *)route animated:(BOOL)animated;
- (void)drawRoute:(NSArray *)route onMapView:(MKMapView *)mapView;
- (void)addAnnotationsToMapView:(MKMapView *)mapView fromArray:(NSArray *)points;

@end
