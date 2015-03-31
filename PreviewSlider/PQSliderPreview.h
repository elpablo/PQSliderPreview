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

#import <Foundation/Foundation.h>

typedef enum {
	PQSliderErrorCodeFailOpen,
    PQSliderErrorCodeWrongPassword,
    PQSliderErrorCodeFileNotFound
} PQSliderErrorCode;


/// UISlider subclass to define a slider that allows to preview image array or pages of a PDF document.
/**
 Class PQSliderPreview
 The PQSliderPreview allows you to perform a preview of an array of path to the images 
 or the pages of a PDF document. To use it, simply instantiate the class (or link it to the slider widget)
 and then call one of the methods below:
 
 - pdfPath:pdfPassword:error:
 
 to give the PDF document path (with optional password) or
 
 - imagesPathArray:error:
 
 for the array of path to the images.
 The lastIndexPreviewed readonly property allows you to get the last index of the preview that has been generated.
 */
@interface PQSliderPreview : UISlider {
    
@package
    NSMutableArray   *_contentArray;     ///< Array of items from which show the preview.
    UIImageView      *_imageViewPreview; ///< UIImageView that will show the preview image.
    NSInteger        _lastIndexPreviewed;///< Last index updated for the current array.
    CGPDFDocumentRef _pdf;               ///< PDF Document from which extract pages to perform the preview.
    CGFloat          _yCoordPreview;     ///< y coordinate of the UIImageView that show the preview image.
    BOOL             _generatingPreview; ///< Flag that indicate that the preview image is going to be generated.
}

@property (nonatomic, readonly) NSInteger lastIndexPreviewed;

/// Open the given PDF document with optional password.
/**
 @param path    String representing the file path of the PDF document.
 @param pwd     String representing the password with which open and encript the document. Give nil if no password is required.
 @param error   Error containing the problem occourred during the PDF opening.
 @return Return YES on success, NO if some problem occourred.
 */
- (BOOL)pdfPath:(NSString *)path pdfPassword:(NSString *)pwd error:(NSError **)error;

/// Assign the array of images to be previewed.
/**
 @param path    Array of images filenames.
 @param error   Error containing the problem found in image's paths given as input.
 @return Return YES on success, NO if some problem occourred.
 */
- (BOOL)imagesPathArray:(NSArray *)path error:(NSError **)error;

@end
