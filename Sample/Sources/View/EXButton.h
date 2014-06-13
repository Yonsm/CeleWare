
//
#define UIButtonTypeNavigationBack		(UIButtonType)100
#define UIButtonTypeNavigationItem		(UIButtonType)101
#define UIButtonTypeNavigationDone		(UIButtonType)102
@interface UIButton (EXButton)
@property(nonatomic,retain) UIColor *tintColor;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width font:(UIFont *)font;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name;
+ (id)buttonWithTitle:(NSString *)title width:(CGFloat)width;
+ (id)buttonWithTitle:(NSString *)title;
+ (id)longButtonWithTitle:(NSString *)title;
+ (id)minorButtonWithTitle:(NSString *)title width:(CGFloat)width;
+ (id)minorButtonWithTitle:(NSString *)title;
+ (id)longMinorButtonWithTitle:(NSString *)title;
+ (id)buttonWithImage:(UIImage *)image;
+ (id)buttonWithImageNamed:(NSString *)imageName;
+ (id)checkButtonWithTitle:(NSString *)title frame:(CGRect)frame;
+ (id)linkButtonWithTitle:(NSString *)title frame:(CGRect)frame;
+ (id)linkButtonWithTitle:(NSString *)title;
+ (id)colorButtonWithTitle:(NSString *)title width:(CGFloat)width;
+ (id)colorButtonWithTitle:(NSString *)title;
+ (id)roundButtonWithTitle:(NSString *)title color:(UIColor *)color color_:(UIColor *)color_ frame:(CGRect)frame;
@end
