//
//  PreviewSliderAppDelegate.h
//  PreviewSlider
//
//  Created by Paolo Quadrani on 20/04/11.
//  Copyright 2011 Paolo Quadrani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PreviewSliderViewController;

@interface PreviewSliderAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PreviewSliderViewController *viewController;

@end
