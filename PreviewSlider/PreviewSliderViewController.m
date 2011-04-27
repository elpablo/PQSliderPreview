//
//  PreviewSliderViewController.m
//  PreviewSlider
//
//  Created by Paolo Quadrani on 20/04/11.
//  Copyright 2011 Paolo Quadrani. All rights reserved.
//

#import "PreviewSliderViewController.h"

@implementation PreviewSliderViewController
@synthesize sliderPreview;
@synthesize sliderPreviewUp;

- (void)dealloc {
    [sliderPreview release];
    [sliderPreviewUp release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *e;

    // Ask the upper slider to make a preview of the test images.
    NSArray *images = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"."];
    if ([sliderPreviewUp previewImages:images error:&e] == NO) {
        // Some error occourred; do something to notify the user...
        NSLog(@"%@", [e localizedDescription]);
    }
    sliderPreviewUp.tag = 0;
    [sliderPreviewUp addTarget:self action:@selector(lastPreviewedImage:) forControlEvents:UIControlEventTouchUpInside];
    
    // Ask the bottom slider to make a preview of the test PDF document.
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"PQSliderPreview" ofType:@"pdf"];
    if ([sliderPreview previewPDF:pdfPath withPassword:nil error:&e] == NO) {
        // Some error occourred; do something to notify the user...
        NSLog(@"%@", [e localizedDescription]);
    }
    sliderPreview.tag = 1;
    [sliderPreview addTarget:self action:@selector(lastPreviewedImage:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)lastPreviewedImage:(PQSliderPreview *)sender {
    NSString *slider = sender.tag ? @"PDF Previewer" : @"Image Previewer";
    NSLog(@"'%@' - Last previewed index: %d", slider, sender.lastIndex);
}

- (void)viewDidUnload {
    [self setSliderPreview:nil];
    [self setSliderPreviewUp:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
