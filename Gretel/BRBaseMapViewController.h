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

@interface BRBaseMapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
    CGRect mapOnFrame;
    CGRect mapOffFrame;
    CGRect optionsOnFrame;
    CGRect optionsOffFrame;
    NSMutableArray *polylines;
    int pointLimitForPolyline;
    int pointCountForPolyline;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) BOOL initialLocate;
@property (nonatomic, strong) MKPolylineView *polylineView;

///UIView container for transitions
@property (nonatomic, strong) IBOutlet UIView *formContainer;
///UIView for option buttons
@property (nonatomic, strong) IBOutlet UIView *optionButtonWrapper;

@property (nonatomic, strong) IBOutlet UIView *mapViewWrapper;

/**
 * Sets up the frames for animating the map and options views
 * @return void
 */
-(void)configureFrames;


/**
 * Shows and hides the map and options menu bar
 * @param BOOL shouldHide - determines whether the menu and map are on or off screen
 * @return void
 */
-(void)hideMapViewAndOptions:(BOOL)shouldHide;


- (void)zoomToFitMapView:(MKMapView*)mapView toFitRoute:(NSArray *)route animated:(BOOL)animated;
- (void)drawRoute:(NSArray *)route onMapView:(MKMapView *)mapView willRefreh:(BOOL)willRefresh;
- (void)addAnnotationsToMapView:(MKMapView *)mapView fromArray:(NSArray *)points;

@end
