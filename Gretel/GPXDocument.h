//
//  GPXDocument.h
//  Gretel
//
//  Created by Ben Reed on 08/03/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPXDocument : UIDocument  {
    NSString *gpxString;
}

@property (strong, nonatomic) NSString *gpxString;

@end
