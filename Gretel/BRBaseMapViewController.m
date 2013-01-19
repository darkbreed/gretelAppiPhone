//
//  BRBaseMapViewController.m
//  Gretel
//
//  Created by Ben Reed on 17/12/2012.
//  Copyright (c) 2012 Ben Reed. All rights reserved.
//

#import "BRBaseMapViewController.h"

@interface BRBaseMapViewController ()

@end

@implementation BRBaseMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    UIColor* transparentBlue = [UIColor colorWithRed: 0 green: 0.54 blue: 0.97 alpha: 0.65];
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = transparentBlue;
    polylineView.lineWidth = 5.0;
    
    return polylineView;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;  //return nil to use default blue dot view
    
    BRMapAnnotation *mapAnnotation = (BRMapAnnotation *)annotation;
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    
    if(mapAnnotation.type == kBRLocationTypeStart){
        [pinView setPinColor:MKPinAnnotationColorGreen];
    }else if(mapAnnotation.type == kBRLocationTypeFinish){
        [pinView setPinColor:MKPinAnnotationColorRed];
    }
    
    return pinView;
}

#pragma mark MkMapViewDelegate methods
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if(self.initialLocate){
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.1;
        mapRegion.span.longitudeDelta = 0.1;
        
        [self.mapView setRegion:mapRegion animated:YES];
        [self setInitialLocate:NO];
    }
    
}

/***
 
 Zooms a map to fit a route of points.
 Based on http://stackoverflow.com/questions/4169459/whats-the-best-way-to-zoom-out-and-fit-all-annotations-in-mapkit
 
 **/
- (void)zoomToFitMapView:(MKMapView*)mapView toFitRoute:(NSArray *)route animated:(BOOL)animated {
    
    if([route count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(GPSPoint *point in route)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [point.lon doubleValue]);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [point.lat doubleValue]);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [point.lon doubleValue]);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [point.lat doubleValue]);
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5,
                                                               topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1,
                                                 fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    
    [mapView regionThatFits:region];
    [mapView setRegion:region animated:animated];
    
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

-(void)addAnnotationsToMapView:(MKMapView *)mapView fromArray:(NSArray *)points {
    
    BRMapAnnotation *annotation = nil;
    
    for (int i = 0; i < [points count]; i++) {
        
        GPSPoint *point = (GPSPoint *)[points objectAtIndex:i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([point.lat doubleValue], [point.lon doubleValue]);
        
        if(i == 0){
            
            annotation = [[BRMapAnnotation alloc] initWithCoordinate:coord andType:kBRLocationTypeStart];
            
        }else if(i == [points count] - 1){
            
            annotation = [[BRMapAnnotation alloc] initWithCoordinate:coord andType:kBRLocationTypeFinish];
            
        }else{
            // annotation = [[BRMapAnnotation alloc] initWithCoordinate:coord andType:kBRLocationTypePoint];
        }
        
        [mapView addAnnotation:annotation];
        
    }
    
}

@end
