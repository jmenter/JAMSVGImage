JAMSVGImage
===========

A class for parsing and displaying resolution independent SVG image graphics in iOS. The goal with this class is simplicity: it only supports paths and their appearance: primitive shapes, bezier paths (including elliptical arcs), stroke & fill, opacity, gradient fills, and affine transformations, either applied at the element or group level.

As of version 1.4, JAMSVGImage passes all 19 of the SVG1.1 conformance tests for the "path" element. 

(IMPORTANT NOTE: for now, the IBDesignable and IBInspectable features do not work if you're installing this with cocoapods. You'll have to drag the class files directly into your project. The class files have no dependencies, but you will need to make syre to link to  "libz.dylib". This will hopefully be fixed soon.)

![JAMSVGImageView Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/master/example.png)

Usage
-----

Use JAMSVGImage and JAMSVGImageView in places where you would normally use a UIImageView or where you would programmatically draw your own graphics. The benefits of using SVG are:

1. Graphics are scalable and maintain quality at any size
2. Graphic file sizes tend to be much smaller (especially .svgz)
3. Built-in "flat look" (haha)

There are three main ways to use these classes.

Way the first: JAMSVGImageView is IBDesignable and IBInspectable so you can drag a UIView to your layout in Interface Builder, set the class type to "JAMSVGImageView", and then type the name of the SVG image in the inspector like in the example above.

Secondly, you can programmatically alloc and init a new JAMSVGImageView with a JAMSVGImage, and add it to your view heirarchy

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    JAMSVGImageView *tigerImageView = [JAMSVGImageView.alloc initWithSVGImage:tiger];
    tigerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tigerImageView];

The SVG image will draw at high resolution no matter what the density or scale of the device's display.

Lastly, you can create a JAMSVGImage instance and use the drawInCurrentContext method in your current graphics context like so:

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];

You can also call [tiger image] or .CGImage to get a raster UIImage or CGImageRef and use that anywhere you would use a UIImage or CGImageRef. You can set the scale before getting the image if you need it bigger or smaller.

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
- Fill Color (in hex "#xxxxxx" format)
- Fill Rules (evenodd)
- Stroke Color (in hex "#xxxxxx" format)
- Gradient Fill
- Stroke Weight
- Line Dashes
- Line Join/Cap (Butt/Round/Miter)
- Opacity
- Affine Transformations
- Group level appearance

SVG Document Properties:
- viewBox
- width, height

If there are any SVG parts you're missing out on then: fork, fix, and issue a pull request!