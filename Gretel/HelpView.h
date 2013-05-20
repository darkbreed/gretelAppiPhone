//
//  HelpView.h
//  Gretel
//
//  Created by Ben Reed on 22/04/2013.
//  Copyright (c) 2013 Ben Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTThemeManager.h"

@interface HelpView : UIView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@end
