
#import "SplitImageView.h"

@interface SplitImageView ()
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) CAShapeLayer *leftMaskLayer;

@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) CAShapeLayer *rightMaskLayer;

@property (nonatomic) UIView *splitterView;
@property (nonatomic) UIView *thumbView;
@end

@implementation SplitImageView

- (instancetype)init; { if (!(self = [super init])) { return nil; } return [self commonInit]; }
- (instancetype)initWithCoder:(NSCoder *)aDecoder; { if (!(self = [super initWithCoder:aDecoder])) { return nil; } return [self commonInit]; }
- (instancetype)initWithFrame:(CGRect)frame; { if (!(self = [super initWithFrame:frame])) { return nil; } return [self commonInit]; }

- (instancetype)commonInit;
{
    self.leftImageView = UIImageView.new;
    self.leftImageView.contentMode = self.contentMode;
    self.leftMaskLayer = CAShapeLayer.layer;
    self.leftImageView.layer.mask = self.leftMaskLayer;
    [self addSubview:self.leftImageView];
    
    self.rightImageView = UIImageView.new;
    self.rightImageView.contentMode = self.contentMode;
    self.rightMaskLayer = CAShapeLayer.layer;
    self.rightImageView.layer.mask = self.rightMaskLayer;
    [self addSubview:self.rightImageView];
    
    self.splitterView = UIView.new;
    self.splitterView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.splitterView.backgroundColor = UIColor.darkGrayColor;
    self.splitterView.layer.cornerRadius = 1;
    [self addSubview:self.splitterView];
    
    self.thumbView = UIView.new;
    self.thumbView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.thumbView.backgroundColor = UIColor.lightGrayColor;
    self.thumbView.layer.cornerRadius = 3;
    self.thumbView.layer.borderWidth = 1.5;
    self.thumbView.layer.borderColor = UIColor.grayColor.CGColor;
    [self addSubview:self.thumbView];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

    return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    CGFloat xPosition = [touches.anyObject locationInView:self].x;
    [self setImageSplit: (xPosition < 0) ? 0 : (xPosition > self.bounds.size.width) ? self.bounds.size.width : xPosition];
}

- (void)layoutSubviews;
{
    self.leftImageView.frame = self.leftMaskLayer.frame = self.rightImageView.frame = self.rightMaskLayer.frame = self.bounds;
    
    self.splitterView.frame = CGRectMake(0, -2, 2, self.bounds.size.height + 4);
    self.thumbView.frame = CGRectMake(0, 0, 10, 44);
    
    [self setImageSplit:CGRectGetMidX(self.bounds)];
}

- (void)setImageSplit:(CGFloat)xPosition;
{
    self.splitterView.center = CGPointMake(xPosition, CGRectGetMidY(self.bounds));
    self.thumbView.center = CGPointMake(xPosition, CGRectGetMidY(self.bounds));
    
    self.leftMaskLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, xPosition, self.bounds.size.height)].CGPath;
    self.rightMaskLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(xPosition, 0, self.bounds.size.width - xPosition, self.bounds.size.height)].CGPath;
}

- (void)setContentMode:(UIViewContentMode)contentMode; { self.leftImageView.contentMode = self.rightImageView.contentMode = super.contentMode = contentMode; }
- (void)setLeftImage:(UIImage *)leftImage; { self.leftImageView.image = leftImage; }
- (void)setRightImage:(UIImage *)rightImage; { self.rightImageView.image = rightImage; }
- (UIImage *)leftImage; { return self.leftImageView.image; }
- (UIImage *)rightImage; { return self.rightImageView.image; }

@end
