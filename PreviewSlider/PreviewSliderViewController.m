//
//  PreviewSliderViewController.m
//  PreviewSlider
//
//  Created by Paolo Quadrani on 20/04/11.
//  Copyright 2011 Paolo Quadrani. All rights reserved.
//

#import "PreviewSliderViewController.h"


@interface PreviewSliderViewController()

- (void)_initializeImageSlider:(PQSliderPreview *)slider;
- (void)_initializePDFSlider:(PQSliderPreview *)slider;

@end


//--------------------------------------------------------------------

@implementation PreviewSliderViewController
@synthesize sliderPreview;
@synthesize sliderPreviewUp;

- (void)dealloc {
    [images release];
    [pdfPath release];
    [sliderPreview release];
    [sliderPreviewUp release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setSliderPreview:nil];
    [self setSliderPreviewUp:nil];
    [super viewDidUnload];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imagesOnUpperSlider = YES;
    
    // Ask the upper slider to make a preview of the test images.
    images = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"."] retain];
    sliderPreviewUp.tag = 0;
    [sliderPreviewUp addTarget:self action:@selector(lastPreviewedImage:) forControlEvents:UIControlEventTouchUpInside];
    [self _initializeImageSlider:sliderPreviewUp];
    
    // Ask the bottom slider to make a preview of the test PDF document.
    pdfPath = [[[NSBundle mainBundle] pathForResource:@"PQSliderPreview" ofType:@"pdf"] retain];
    sliderPreview.tag = 1;
    [sliderPreview addTarget:self action:@selector(lastPreviewedImage:) forControlEvents:UIControlEventTouchUpInside];
    [self _initializePDFSlider:sliderPreview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions

- (void)lastPreviewedImage:(PQSliderPreview *)sender {
    NSString *slider = sender.tag ? @"PDF Previewer" : @"Image Previewer";
    NSLog(@"'%@' - Last previewed index: %ld", slider, (long)sender.lastIndexPreviewed);
}

- (IBAction)swapContent:(id)sender {
    // Switch the visualization (for testing pourposes...
    
    imagesOnUpperSlider = !imagesOnUpperSlider;
    
    if (imagesOnUpperSlider) {
        [self _initializePDFSlider:sliderPreview];
        [self _initializeImageSlider:sliderPreviewUp];
    } else {
        [self _initializePDFSlider:sliderPreviewUp];
        [self _initializeImageSlider:sliderPreview];
    }
}

#pragma mark - Private functions

- (void)_initializeImageSlider:(PQSliderPreview *)slider {
    NSError *e;
    if ([slider imagesPathArray:images error:&e] == NO) {
        // Some error occourred; do something to notify the user...
        NSLog(@"%@", [e localizedDescription]);
    }
}

- (void)_initializePDFSlider:(PQSliderPreview *)slider {
    NSError *e;
    if ([slider pdfPath:pdfPath pdfPassword:nil error:&e] == NO) {
        // Some error occourred; do something to notify the user...
        NSLog(@"%@", [e localizedDescription]);
    }
}

@end
