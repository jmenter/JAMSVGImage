JAMSVGImage
===========

A class for parsing and displaying resolution independent SVG image graphics in iOS. The goal with this class is simplicity: it only supports paths and their appearance—primitive shapes, bezier paths (including elliptical arcs), stroke & fill, opacity, gradient fills, and affine transformations. It's easy to use and since the SVG commands are converted to Core Graphics objects it is quite performant.

Use JAMSVGImage and JAMSVGImageView in lots of places where you would normally use UIImage and UIImageView. The benefits of using SVG are:

1. Graphics are scalable and maintain quality at any size
2. Graphic file sizes tend to be much smaller
3. Built-in "flat look" (haha)

There are two main ways to use these classes. The first is to simply create a new JMSVGImage object and use the instance's drawing methods to draw in a graphics context, like so:

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    [tiger drawInCurrentContext];

This parses the file named "tiger.svg" in your app's main bundle and draws it in the current graphics context at its natural size.

The second way to use is to put the JMSVGImage in a JMSVGImageView and add that subview to your view, like so:

    JAMSVGImage *tiger = [JAMSVGImage imageNamed:@"tiger"];
    JAMSVGImageView *tigerImageView = [JAMSVGImageView.alloc initWithSVGImage:tiger];
    tigerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tigerImageView];

This creates a JAMSVGImageView, populated with the tiger svg, sets the contentMode, and adds it to the view heirarchy. The JAMSVGImageView respects all UIViewContentMode types and draws itself in high-resolution no matter what size the view is scaled to.

You can also call [tiger image] or .CGImage to get a raster UIImage or CGImageRef.

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
