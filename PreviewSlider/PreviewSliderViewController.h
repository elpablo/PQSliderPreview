//
//  PreviewSliderViewController.h
//  PreviewSlider
//
//  Created by Paolo Quadrani on 20/04/11.
//  Copyright 2011 Paolo Quadrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQSliderPreview.h"

@interface PreviewSliderViewController : UIViewController {
    
    PQSliderPreview *sliderPreview;
    PQSliderPreview *sliderPreviewUp;
    
    BOOL imagesOnUpperSlider;
    NSArray *images;
    NSString *pdfPath;
}

@property (nonatomic, retain) IBOutlet PQSliderPreview *sliderPreview;
@property (nonatomic, retain) IBOutlet PQSliderPreview *sliderPreviewUp;

- (void)lastPreviewedImage:(PQSliderPreview *)sender;

- (IBAction)swapContent:(id)sender;

@end
