JAMSVGImage
===========

A class for parsing and displaying resolution independent SVG image graphics in iOS. The goal with this class is simplicity: it only supports paths and their appearance: primitive shapes, bezier paths (including elliptical arcs), stroke & fill, opacity, gradient fills, and affine transformations, either applied at the element or group level.

JAMSVGImage passes all 19 of the SVG1.1 conformance tests for the "path" element. 

(IMPORTANT NOTE: for now, the IBDesignable and IBInspectable features do not work if you're installing this with Cocoapods: https://github.com/CocoaPods/CocoaPods/issues/2792 To work around this, you'll have to drag the class files directly into your project. The class files have no dependencies, but you will need to make sure to link to "libz.dylib". This will hopefully be fixed soon.)

![JAMSVGImageView Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/master/example.png)

Usage
-----

Use JAMSVGImage and JAMSVGImageView in places where you would normally use a UIImageView or where you would programmatically draw your own graphics. The benefits of using SVG are:

1. Graphics are scalable and maintain quality at any size
2. No need to generate @2x, @3x, or any specific resolution assets for optimum quality
3. Graphic file sizes tend to be much smaller (especially .svgz)
4. Built-in "flat look" (haha)

There are a few ways to use these classes:

JAMSVGImageView is IBDesignable and IBInspectable so you can drag a UIView to your layout in Interface Builder, set the class type to "JAMSVGImageView", and then type the name of the SVG image in the inspector like in the example above.

Secondly, you can programmatically alloc and init a new JAMSVGImageView with a JAMSVGImage, and add it to your view heirarchy

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    JAMSVGImageView *tigerImageView = [JAMSVGImageView.alloc initWithSVGImage:tiger];
    tigerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tigerImageView];

The SVG image will draw at high resolution no matter what the density or scale of the device's display.

Third, you can create a JAMSVGImage instance and use the drawInCurrentContext method in your current graphics context like so:

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];

You can also call [tiger image] or .CGImage to get a raster UIImage or CGImageRef and use that anywhere you would use a UIImage or CGImageRef. You can set the scale before getting the image if you need it bigger or smaller, or you can pass in a rect to have the SVG rendered at the proper scale for your device (whether it's a @1x, @2x, or @3x screen):

    JAMSVGImage *buttonSvg = [JAMSVGImage imageNamed:@"fancyButton"];
    [self.button setBackgroundImage:[buttonSvg imageAtSize:self.button.bounds.size] forState:UIControlStateNormal];
    
Last, there is a JAMSVGButton subclass of UIButton that allows setting the four button states to SVG files via Interface Builder.

Supported features/shapes/appearances:
--------------------------

File Formats:
- SVG 1.1 documents either normal or gzipped (.svgz)

Shape Primitives:
- Circle
- Ellipse
- Rectangle
- Line
- Polyline
- Bezier Path
- Elliptical Arc

Shape Appearance:
- Fill Color
- Fill Rules
- Stroke Color
- Gradient Fill
- Stroke Weight
- Line Dashes
- Line Join/Cap (Butt/Round/Miter)
- Opacity
- "style =" for all the above
- Affine Transformations
- Group level appearance

SVG Document Properties:
- viewBox
- width, height

If you're using this in a production app, please let me know! I'd love to get feedback and figure out how to make it better. If there are any SVG parts you're missing out on you should fork, fix, and issue a pull request.