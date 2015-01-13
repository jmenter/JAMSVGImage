JAMSVGImage
===========

A set of classes for parsing and rendering resolution-independent SVG (Scalable Vector Graphics) files in your iOS application.

The nerdy details: JAMSVGImage parses SVG files and transforms all 'path' elements into a collection of stylized UIBezierPath objects which are rendered (at any scale) at the device's native resolution at runtime. SVG files are typically produced with 2D drawing applications such as Adobe Illustrator or Inkscape.

![JAMSVGImageView Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/master/example.png)

Why SVG?
--------

__Look__: they look great no matter if they are scaled up or down since SVG images are described with mathematical curves rather than discrete pixels as with PNG or JPG.

__Convenience__: there's no need to generate @2x and @3x versions of your art assets. A single SVG is all you need.

__File Size__: SVG and SVGZ (gzipped SVG) are typically a fraction of the file size of a set of PNG or JPG art assets.

Usage
-----

Use JAMSVGImage and JAMSVGImageView in places where you would normally use UIImage, UIImageView, or where you would programmatically draw your own graphics. There are a few ways to use these classes.

JAMSVGImageView is IBDesignable and IBInspectable so you can drag a UIView to your layout in Interface Builder, set the class type to "JAMSVGImageView", and then type the name of the SVG image like so:

![JAMSVGImageView Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/develop/svgImageViewExample.png)

Secondly, you can programmatically alloc and init a new JAMSVGImageView with a JAMSVGImage, and add it to your view heirarchy

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    JAMSVGImageView *tigerImageView = [JAMSVGImageView.alloc initWithSVGImage:tiger];
    tigerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tigerImageView];

The SVG image will draw at high resolution no matter what the density or scale of the device's display.

Third, you can create a JAMSVGImage instance and use the drawInCurrentContext method in your current graphics context like so:

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];

You can also call [tiger image] or .CGImage to get a raster UIImage or CGImageRef and use that anywhere you would use a UIImage or CGImageRef. You can set the scale before getting the image if you need it bigger or smaller, or you can pass in a rect to have the SVG rendered in that rect at the proper scale for your device (whether it's a @1x, @2x, or @3x screen):

    [self.button setBackgroundImage:[[JAMSVGImage imageNamed:@"fancyButton"] imageAtSize:self.button.bounds.size] forState:UIControlStateNormal];
    
Last, there is a JAMSVGButton subclass of UIButton that allows setting the four button states to SVG files via Interface Builder.

![JAMSVGButton Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/develop/svgButtonExample.png)

Supported SVG Shape Features & Appearance:
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
- Gradient Fill
- Opacity
- Stroke Color
- Stroke Weight
- Line Dashes
- Line Join/Cap (Butt/Round/Miter)
- Affine Transformations
- Inherited Group Level Appearance

SVG Document Properties:
- viewBox
- width, height

Note on using JAMSVGImage with Cocoapods
----

To use the IBDesignable and IBInspectable attributes in Interface Builder while bringing JAMSVGImage in via cocoapods requires a bit of hackery:

1. Make sure you're using Cocoapods 0.36.0.beta.1 or newer
2. Add use_frameworks! at the top of your Podfile to enable Framework opt-in
3. Add all SVGs have to a "Copy Files" build phase for the JAMSVGImage framework in your Pods project, like so:

![Pods Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/develop/podsInstructions.png)

Keep in mind that if you go this route, you will probably have to repeat these steps every time you run pod install.

An alternative to this workaround is to just drag the class files directly to your project (make sure you link to "libz.dylb").

Etc.
----

Why not use vector PDF with Xcode 6+ and iOS 7+? Xcode's vector PDF functionality is limited to rendering @1x, @2x, and @3x bitmaps at their natural size at build time. JAMSVGImage is far more versatile since SVGs are rendered at arbitrary size at runtime.

If you're using this in a production app, please let me know! I'd love to get feedback and figure out how to make it better. If there are any SVG parts you're missing out on you should fork, fix, and issue a pull request. The only supported SVG elements are "path" elements and associated styling information. JAMSVGImage passes all 19 of the SVG1.1 conformance tests for the "path" element.
