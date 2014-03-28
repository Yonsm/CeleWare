

//
#ifdef _ImageEx
@interface UIImage (ImageEx)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)stretchableImage;
- (UIImage *)scaleImageToSize:(CGSize)size;
- (UIImage *)cropImageInRect:(CGRect)rect;
//- (UIImage *)cropImageToRect:(CGRect)rect;
- (UIImage *)maskImageWithImage:(UIImage *)mask;
- (CGAffineTransform)orientationTransform:(CGSize *)newSize;
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension;

@end
#endif

//
#ifdef _ViewEx
@interface UIView (ViewEx)
- (void)removeSubviews;

- (void)hideKeyboard;
- (UIView *)findFirstResponder;
- (UIView *)findSubview:(NSString *)cls;

- (UIActivityIndicatorView *)showActivityIndicator:(BOOL)show;

- (void)fadeForAction:(SEL)action target:(id)target;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration delay:(CGFloat)delay;

- (void)shakeAnimatingWithCompletion:(void (^)(BOOL finished))completion;
- (void)shakeAnimating;

- (UIImage*)screenshot;
- (UIImage*)screenshotWithOptimization:(BOOL)optimized;

- (UIView *)superviewWithClass:(Class)viewClass;

@end
#endif

//
@protocol AlertViewExDelegate
@required
- (void)taskForAlertView:(UIAlertView *)alertView;
@end

//
#ifdef _AlertViewEx
@interface UIAlertView (AlertViewEx)

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ...;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title;

//
- (UIActivityIndicatorView *)activityIndicator;
- (void)dismissOnMainThread;
- (void)dismiss;

@end
#endif

//
#ifdef _TabBarControllerEx
@interface UITabBarController (TabBarControllerEx)
- (UIViewController *)currentViewController;
@end
#endif


//
#ifdef _ViewControllerEx
@interface UIViewController (ViewControllerEx)
- (void)dismissModalViewController;
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated dismissButtonTitle:(NSString *)dismissButtonTitle;
@end
#endif

//
#ifdef _ButtonEx
#define UIButtonTypeNavigationBack		(UIButtonType)100
#define UIButtonTypeNavigationItem		(UIButtonType)101
#define UIButtonTypeNavigationDone		(UIButtonType)102
@interface UIButton (UIButtonEx)
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
#endif


//
#ifdef _BarButtonItemEx
@interface UIBarButtonItem (BarButtonItemEx)
+ (id)buttonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action;
+ (id)buttonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (id)buttonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
@end
#endif

#ifdef _LabelEx
@interface UILabel (LabelEx)

//
+ (id)labelAtPoint:(CGPoint)point
			 width:(float)width
			  text:(NSString *)text
			 color:(UIColor *)color
			  font:(UIFont*)font
		 alignment:(NSTextAlignment)alignment;
//
+ (id)labelWithFrame:(CGRect)frame
				text:(NSString *)text
			   color:(UIColor *)color
				font:(UIFont *)font
		   alignment:(NSTextAlignment)alignment;
@end
#endif

//
#ifdef _TapGestureRecognizer
@interface TapGestureRecognizer : UITapGestureRecognizer <UIGestureRecognizerDelegate>
@end

//
@interface UIView (GestureRecognizer)
- (TapGestureRecognizer *)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (UILongPressGestureRecognizer *)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action;
@end

#endif