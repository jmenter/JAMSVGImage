JAMSVGImage
===========

A class for parsing and displaying resolution independent SVG image graphics in iOS. The goal with this class is simplicity: it only supports paths and their appearance: primitive shapes, bezier paths (including elliptical arcs), stroke & fill, opacity, gradient fills, and affine transformations.

![JAMSVGImageView Example](https://raw.githubusercontent.com/jmenter/JAMSVGImage/master/example.png)

Use JAMSVGImage and JAMSVGImageView in lots of places where you would normally use UIImage and UIImageView. The benefits of using SVG are:

1. Graphics are scalable and maintain quality at any size
2. Graphic file sizes tend to be much smaller
3. Built-in "flat look" (haha)

There are three main ways to use these classes.

JAMSVGImageView is IBDesignable and IBInspectable so you can drag a UIView to your layout in Interface Builder, set the class type to "JAMSVGImageView", and then type the name of the SVG image in the inspector like in the example above.

Programmatically alloc and init a new JAMSVGImageView with a JAMSVGImage, and add it to your view heirarchy

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    JAMSVGImageView *tigerImageView = [JAMSVGImageView.alloc initWithSVGImage:tiger];
    tigerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tigerImageView];

Create a JAMSVGImage instance and use the drawInCurrentContext method in your current graphics context

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];

You can also call [tiger image] or .CGImage to get a raster UIImage or CGImageRef and use that anywhere you would use a UIImage or CGImageRef.

Supported shapes/features:

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

SVG Document Properties:
- viewBox

If there are any svg parts you're missing out on then: fork, fix, and issue a pull request!
