//
//  GTThemeManager.m
//  Gretel
//
//  Created by Ben Reed on 17/05/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import "GTThemeManager.h"

@implementation GTThemeManager

+(UIImage*)listIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setSize:18.0];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor whiteColor], nil]];
    [iconFactory setSquare:YES];
    [iconFactory setStrokeColor:[UIColor blackColor]];
    [iconFactory setStrokeWidth:0.2];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconList];
    
}

+(UIImage *)altListIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconListAlt];
    
}

+(UIImage *)envelopeIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconEnvelope];
    
}


+(UIImage *)cogsIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconCogs];
    
}

+(UIImage *)infoIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconInfoSign];
    
}

+(UIImage *)questionMarkIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    return [iconFactory createImageForIcon:NIKFontAwesomeIconQuestionSign];
    
}

+(UIImage *)mapMarkerIcon {
    
    NIKFontAwesomeIconFactory *iconFactory = [[NIKFontAwesomeIconFactory alloc] init];
    [iconFactory setColors:[NSArray arrayWithObjects:[UIColor grayColor],[UIColor grayColor], nil]];
    [iconFactory setSquare:YES];
    
    return [iconFactory createImageForIcon:NIKFontAwesomeIconMapMarker];
    
}



@end
