JAMSVGImage
===========

A class for parsing and displaying resolution independent SVG image graphics in iOS. The goal with this class is simplicity: it only supports a subset of the SVG spec (primitive shapes, bezier curves, stroke and fill), but it's easy to use and quite performant.

Use JAMSVGImage and JAMSVGImageView in lots of places where you would normally use UIImage and UIImageView. The benefits of using SVG are:

1. Graphics are scalable and maintain quality at any size
2. Graphic file sizes tend to be much smaller
3. Built-in "flat look" (haha)

There are two main ways to use these classes. The first is to simply create a new JMSVGImage object and use the drawing methods, like so:

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

Note: the parser only supports the common subset of graphics primitives. Supported shapes/features:

Shape Primitives:
- Circle
- Ellipse
- Rectangle
- Line
- Polyline
- Bezier Path

Shape Appearance:
- Fill Color (in hex "#xxxxxx" format)
- Stroke Color (in hex "#xxxxxx" format)
- Stroke Weight
- Line Dashes
- Line Join/Cap (Butt/Round/Miter)

SVG Document Properties:
- viewBox

If there are any svg parts you're missing out on then: fork, fix, and issue a pull request!
