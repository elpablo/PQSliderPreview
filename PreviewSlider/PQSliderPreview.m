/***************************************************************************
 Copyright [2011] [Paolo Quadrani]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 ***************************************************************************/

#import "PQSliderPreview.h"

#define kIPhoneScaleFactor .3


@interface PQSliderPreview(/* Private */)

/// Initialize internal variables.
- (void)_initializeProperties;

/// Allows to shoe/hide the UIImageView representing the preview.
/**
 @param show        Boolean value used to hise/show the UIImageView
 @param animated    Boolean value used to perform the hide/show animated or no.
 */
- (void)_showPreviewThumb:(BOOL)show animated:(BOOL)animated;

/// Check from which element the preview has to be done (PDF, array of images) and create the preview image at the given index.
/**
 @param index Index of the element in array from which generate the preview.
 */
- (void)_updatePreviewAtIndex:(NSInteger)index;

/// Create the PDF page preview.
/**
 @param page Page number to extract and draw from PDF Document.
 */
- (void)_createPreviewForPDFPage:(NSNumber *)page;

/// Create the image preview.
/**
 @param page Page number to extract and draw from contentArray.
 */
- (void)_createPreviewForImage:(NSNumber *)page;

@end

@implementation PQSliderPreview

@synthesize lastIndex = _lastIndex;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	if(self) {
        [self _initializeProperties];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initializeProperties];
    }
    return self;
}

- (void)_initializeProperties {
    _generatingPreview = NO;
    self.value = 0.;
    _lastIndex = -1; // invalidate the last index updated.
    
    [self addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(hidePreview) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rect;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat minDim = MIN(screenRect.size.width, screenRect.size.height);
        CGFloat w = minDim * kIPhoneScaleFactor;
        rect = CGRectMake(0, 0, w, round(w * 1.3));
    } else {
        rect = CGRectMake(0, 0, 100, 130);
    }
    
    _imageViewPreview = [[UIImageView alloc] initWithFrame:rect];
    [_imageViewPreview setBackgroundColor:[UIColor grayColor]];
    [_imageViewPreview setContentMode:UIViewContentModeScaleAspectFit];
    [_imageViewPreview setAlpha:0.];
    [self addSubview:_imageViewPreview];
    [self setClipsToBounds:NO];
}

- (void)setMinimumValue:(float)minimumValue {
    if (_pdf) {
        // PDF preview. Index are 1..N
        [super setMinimumValue:(minimumValue < 1) ? 1 : minimumValue];
    } else {
        // Array of images. Index are 0..(N-1)
        [super setMinimumValue:(minimumValue < 0) ? 0 : minimumValue];
    }
}

- (void)setMaximumValue:(float)maximumValue {
    if (_pdf) {
        // PDF preview. Index are 1..N
        [super setMaximumValue:(maximumValue < 1) ? 1 : maximumValue];
    } else {
        // Array of images. Index are 0..(N-1)
        [super setMaximumValue:(maximumValue < 0) ? 0 : maximumValue];
    }
}

- (void)setValue:(float)value {
    if (_pdf) {
        // PDF preview. Index are 1..N
        [super setValue:(value < 1) ? 1 : value];
    } else {
        // Array of images. Index are 0..(N-1)
        [super setValue:(value < 0) ? 0 : value];
    }
}

- (void)_showPreviewThumb:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
    }
    
    [_imageViewPreview setAlpha:show ? 1. : 0.];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (BOOL)previewPDF:(NSString *)path withPassword:(NSString *)pwd error:(NSError **)error {
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    _pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    CFRetain(_pdf);
    BOOL res = YES;
    
	if (_pdf == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"PQSliderPreview"
                                         code:PQSliderErrorCodeFailOpen 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Unable to open file [%@]", pdfURL ], NSLocalizedDescriptionKey, nil]];
        }
        res = NO;
	} else {
        if (CGPDFDocumentIsEncrypted(_pdf)) {
            if (!CGPDFDocumentUnlockWithPassword (_pdf, [pwd UTF8String])) {
                if (error != NULL) {
                    *error = [NSError errorWithDomain:@"PQSliderPreview"
                                                  code:PQSliderErrorCodeWrongPassword 
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Wrong password [%@]", pwd ], NSLocalizedDescriptionKey, nil]];
                }
                res = NO;
            }
        }
	}

    if (res == YES) {
        [_contentArray removeAllObjects];
        [_contentArray release];
        _contentArray = nil;
        
        self.minimumValue = 1;
        self.value = 1;
        self.maximumValue = CGPDFDocumentGetNumberOfPages(_pdf);
    }
    
    return res;
}

- (BOOL)previewImages:(NSArray *)imagesPath error:(NSError **)error {
    BOOL res = YES;
    if (imagesPath != _contentArray) {
        // Check the existance of image path.
        NSFileManager *manager = [NSFileManager defaultManager];
        for (NSString *f in imagesPath) {
            if ([manager fileExistsAtPath:f] == NO) {
                if (error != NULL) {
                    *error = [NSError errorWithDomain:@"PQSliderPreview"
                                                  code:PQSliderErrorCodeFileNotFound 
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"File not found at path [%@]", f ], NSLocalizedDescriptionKey, nil]];
                }
                res = NO;
                break;
            }
        }

        if (res == YES) {
            [_contentArray release];
            _contentArray = [imagesPath mutableCopy];
            
            if (_pdf) {
                CFRelease(_pdf);
            }
            
            // Reset the slider range to access the entair array.
            [self setMinimumValue:0.];
            [self setMaximumValue:[_contentArray count]-1];
            [self setValue:0.];
            _lastIndex = -1;
        }
        
        if (_pdf != NULL) {
            CFRelease(_pdf);
            _pdf = NULL;
        }
    }
    return res;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGPoint sliderOrigin = self.frame.origin;
    CGSize size = self.frame.size;
    CGSize previewSize = _imageViewPreview.bounds.size;
    if (sliderOrigin.y < previewSize.height) {
        _yCoordPreview = size.height * 1.5;
    } else {
        _yCoordPreview = -previewSize.height - (size.height * .5);
    }
}

- (void)_updatePreviewAtIndex:(NSInteger)index {
    if (index == _lastIndex || _generatingPreview) {
        return;
    }
    if (_pdf) {
        // Preview PDF document's pages...
        [NSThread detachNewThreadSelector:@selector(_createPreviewForPDFPage:) toTarget:self withObject:[NSNumber numberWithInt:index]];
    } else if ([_contentArray count] > 0) {
        // Preview Images...
        [NSThread detachNewThreadSelector:@selector(_createPreviewForImage:) toTarget:self withObject:[NSNumber numberWithInt:index]];
    } else {
        NSLog(@"Nothing to preview at index %d", index);
    }
    _lastIndex = index;
}

#pragma mark - Thumb preview creation

- (void)_createPreviewForPDFPage:(NSNumber *)page {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @synchronized(self) {
        _generatingPreview = YES;
        
        // Calculate the scaling factor to scale the PDF page into the UIImageView
        // preview rectangle.
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(_pdf, [page intValue]);
        CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        
        CGSize previewSize = _imageViewPreview.bounds.size;
        float scaleX = previewSize.width  / pageRect.size.width;
        float scaleY = previewSize.height / pageRect.size.height;
        
        float scaleFactor = MIN(scaleX, scaleY);
        pageRect.size = CGSizeMake(pageRect.size.width * scaleFactor, pageRect.size.height * scaleFactor);
        
        UIGraphicsBeginImageContext(pageRect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context != nil) {
            CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
            CGContextFillRect(context, pageRect);
            
            CGContextSaveGState(context);
            // Flip the context so that the PDF page is rendered
            // right side up.
            CGContextTranslateCTM(context, 0.0, pageRect.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            // Scale the context so that the PDF page is rendered 
            // at the correct size for the zoom level.
            CGContextScaleCTM(context, scaleFactor, scaleFactor);
            CGContextDrawPDFPage(context, pdfPage);
            
            CGContextRestoreGState(context);
            
            // Draw a border
            CGContextSetLineWidth(context, 2);
            CGContextStrokeRect(context, pageRect);
            
            UIImage *imageThumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();	
            
            // Shadow
            UIGraphicsBeginImageContext(CGSizeMake(imageThumbnail.size.width + 10, imageThumbnail.size.height + 10));
            CGContextRef imageShadowContext = UIGraphicsGetCurrentContext();
            if (imageShadowContext != nil) {
                CGContextSetShadow(imageShadowContext, CGSizeMake(2, 2), 5);
                [imageThumbnail drawInRect:CGRectMake(5, 5, imageThumbnail.size.width, imageThumbnail.size.height)];
                imageThumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [_imageViewPreview setBackgroundColor:[UIColor clearColor]];
                [_imageViewPreview setImage:imageThumbnail];
            } else {
                [_imageViewPreview setBackgroundColor:[UIColor grayColor]];
            }
        } else {
            [_imageViewPreview setBackgroundColor:[UIColor grayColor]];
        }
        _generatingPreview = NO;
    }
    
    [pool release];
}

- (void)_createPreviewForImage:(NSNumber *)page {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @synchronized(self) {
        _generatingPreview = YES;
        
        UIImage *img = [UIImage imageWithContentsOfFile:[_contentArray objectAtIndex:[page intValue]]];
        if (img) {
            CGSize previewSize = _imageViewPreview.bounds.size;
            UIGraphicsBeginImageContext(previewSize);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, 0.0, previewSize.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, previewSize.width, previewSize.height), img.CGImage);
            
            // Draw a border
            CGContextSetLineWidth(context, 2);
            CGContextStrokeRect(context, _imageViewPreview.bounds);
            
            UIImage* imageThumbnail = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();

            // Shadow
            UIGraphicsBeginImageContext(CGSizeMake(imageThumbnail.size.width + 10, imageThumbnail.size.height + 10));
            CGContextRef imageShadowContext = UIGraphicsGetCurrentContext();
            if (imageShadowContext != nil) {
                CGContextSetShadow(imageShadowContext, CGSizeMake(2, 2), 5);
                [imageThumbnail drawInRect:CGRectMake(5, 5, imageThumbnail.size.width, imageThumbnail.size.height)];
                imageThumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [_imageViewPreview setBackgroundColor:[UIColor clearColor]];
                [_imageViewPreview setImage:imageThumbnail];
            } else {
                [_imageViewPreview setBackgroundColor:[UIColor grayColor]];
            }
        } else {
            [_imageViewPreview setBackgroundColor:[UIColor grayColor]];
        }
        _generatingPreview = NO;
    }
    
    [pool release];
}

#pragma mark - Slider callbacks

- (void)hidePreview {
    [self _showPreviewThumb:NO animated:YES];
}

- (void)valueChanged {
    [self _updatePreviewAtIndex:round(self.value)];

    CGRect previewRect = _imageViewPreview.bounds;
    CGSize previewSize = previewRect.size;
    CGSize size = self.frame.size;

    CGFloat valueMaxSize = self.maximumValue - self.minimumValue;
    CGFloat valueOffset = self.value - self.minimumValue;
    
    CGFloat xCoord = (valueOffset / valueMaxSize) * (size.width - previewSize.width);
    CGPoint originPreview = CGPointMake(xCoord, _yCoordPreview);
    previewRect.origin = originPreview;
    [_imageViewPreview setFrame:previewRect];
    if ([_imageViewPreview alpha] < 1.) {
        [self _showPreviewThumb:YES animated:YES];
    }
}

#pragma mark - Memory Management

- (void)dealloc {
    CFRelease(_pdf);
    [_contentArray release]; _contentArray = nil;
    [_imageViewPreview release]; _imageViewPreview = nil;
    [super dealloc];
}

@end
