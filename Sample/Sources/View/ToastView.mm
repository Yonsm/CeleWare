

#import "ToastView.h"

@implementation ToastView

//
- (id)initWithTitle:(NSString *)title loading:(BOOL)loading
{
	UIFont *font = [UIFont systemFontOfSize:15];
	
	CGFloat width = [title sizeWithFont:font].width + 20;
	if (width < 100) width = 100;
	CGRect frame = {0, 0, width, loading ? 100 : 32};
	self = [super initWithFrame:frame];
	
	self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
	self.layer.cornerRadius = 6;
	self.clipsToBounds = YES;
	
	CGFloat y = 0;
	if (loading)
	{
		UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		activityView.center = CGPointMake(frame.size.width / 2, 38);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:activityView];
		[activityView startAnimating];
		y = CGRectGetMaxY(activityView.frame);
	}
	else
	{
		[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.5];
	}
	
	UILabel *label = [UILabel labelWithFrame:CGRectMake(0, y, frame.size.width, frame.size.height - y) text:title color:UIUtil::Color(0xf9f9f9) font:font alignment:NSTextAlignmentCenter];
	[self addSubview:label];
	
	return self;
}

////
//- (void)didMoveToSuperview
//{
//	if (self.superview)
//	{
//		self.alpha  = 0;
//		[UIView animateWithDuration:0.4 animations:^()
//		 {
//			 self.alpha  = 1;
//		 }];
//	}
//	[super didMoveToSuperview];
//}

//
//- (void)removeFromSuperview
//{
//	[UIView animateWithDuration:0.2 animations:^()
//	 {
//		 self.alpha  = 0;
//	 } completion:^(BOOL finished)
//	 {
//		 [super removeFromSuperview];
//	 }];
//}

@end

//
#define kToastViewTag 82671
@implementation UIView (ToastView)

//
- (ToastView *)showToast:(NSString *)title loading:(BOOL)loading
{
	ToastView *toastView = (ToastView *)[self viewWithTag:kToastViewTag];
	if (toastView == nil)
	{
		toastView = [[[ToastView alloc] initWithTitle:title loading:loading] autorelease];
		toastView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		toastView.tag = kToastViewTag;
		toastView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 40);
		[self addSubview:toastView];
	}
	return toastView;
}

//
- (ToastView *)showToast:(NSString *)title
{
	return [self showToast:title loading:NO];
}

//
- (void)showLoading
{
	[self showToast:@"正在加载" loading:YES];
}

//
- (void)hideLoading
{
	UIView *toastView = [self viewWithTag:kToastViewTag];
	toastView.tag = 0;
	[toastView removeFromSuperview];
}

//
+ (ToastView *)showToast:(NSString *)title loading:(BOOL)loading
{
	return [UIUtil::FrontViewController().view showToast:title loading:loading];
}

//
+ (ToastView *)showToast:(NSString *)title
{
	return [UIUtil::FrontViewController().view showToast:title];
}

//
+ (void)showLoading
{
	[UIUtil::FrontViewController().view showToast:@"正在加载" loading:YES];
}

//
+ (void)hideLoading
{
	[UIUtil::FrontViewController().view hideLoading];
}

@end

