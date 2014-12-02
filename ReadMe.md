PQSliderPreview  -  UISlider subclass
============


[![Twitter: @KauseFx](http://img.shields.io/badge/contact-@quadrani-blue.svg?style=flat)](https://twitter.com/quadrani)
[![License](https://img.shields.io/hexpm/l/plug.svg?style=flat)](http://www.apache.org/licenses/LICENSE-2.0)


-------
### Device Compatibility:
iPhone - iPad

### IDE Requirements:
Xcode 4

PQSliderPreview is a subclass of the UISlider and allows you to make a 
preview of an array of path of images or a PDF document by extracting 
the array of PDF pages in it.

To use it simply drag the **PQSliderPreview.{h,m}** files into your Xcode 
project and instantiate it as a standard UISlider or connect it to a 
UISlider placed into the User Interface using the Interface Builder.

To pass to the PQSliderPreview the content to which make a preview call
one of the two function below:

- **previewPDF: withPassword: error:**

or

- **previewImages: error:**

### Example Usage
Example code is shown in the PreviewSliderViewController.m

The class is fully documented using Doxygen style.

If you use the class into one or more of your project, please let me know
so we can cross link the project references.
