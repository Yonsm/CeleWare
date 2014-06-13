

#import "ToastView.h"

//
#define kToastViewTag 80671
@implementation UIView (ToastView)

//
- (ToastView *)toastWithTitle:(NSString *)title type:(ToastViewType)type
{
	ToastView *toastView = (ToastView *)[self viewWithTag:kToastViewTag];
	if (toastView == nil)
	{
		toastView = [[ToastView alloc] initWithTitle:title type:type];
		toastView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		toastView.tag = kToastViewTag;
		toastView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 20);
		[self addSubview:toastView];
	}
	return toastView;
}

//
- (ToastView *)toastWithTitle:(NSString *)title
{
	return [self toastWithTitle:title type:ToastViewDefault];
}

//
- (ToastView *)toastWithInfo:(NSString *)info
{
	return [self toastWithTitle:info type:ToastViewInfo];
}

//
- (ToastView *)toastWithError:(NSString *)error
{
	return [self toastWithTitle:error type:ToastViewError];
}

//
- (ToastView *)toastWithCancel:(NSString *)cancel
{
	return [self toastWithTitle:cancel type:ToastViewCancel];
}

//
- (ToastView *)toastWithSuccess:(NSString *)success
{
	return [self toastWithTitle:success type:ToastViewSuccess];
}

//
- (ToastView *)toastWithLoading:(NSString *)loading
{
	return [self toastWithTitle:loading type:ToastViewLoading];
}

//
#ifndef _ToastLoadingTitle
#define _ToastLoadingTitle @"正在加载"
#endif
- (ToastView *)toastWithLoading
{
	return [self toastWithLoading:_ToastLoadingTitle];
}

//
- (void)dismissToast
{
	UIView *toastView = [self viewWithTag:kToastViewTag];
	toastView.tag = 0;
	[toastView removeFromSuperview];
}

@end


@implementation ToastView

//
- (id)initWithTitle:(NSString *)title type:(ToastViewType)type
{
	UIFont *font = [UIFont systemFontOfSize:15];
	CGSize size = [title sizeWithFont:font constrainedToSize:CGSizeMake(300, 1000)];
	CGFloat width = size.width + 20;
	if (width < 100) width = 100;
	
	size.height = ceil(size.height);
	CGRect frame = {0, 8, width, MAX(size.height, 16)};
	
	UIView *icon;
	if (type == ToastViewDefault)
	{
		icon = nil;
		[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.5];
	}
	else
	{
		if (type == ToastViewLoading)
		{
			icon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[(UIActivityIndicatorView *)icon startAnimating];
		}
		else
		{
			NSString *name;
			if (type == ToastViewError) name = @"ToastError";
			else if (type == ToastViewCancel) name = @"ToastCacnel";
			else if (type == ToastViewSuccess) name = @"ToastSuccess";
			else name = @"ToastInfo";
			icon = [[UIImageView alloc] initWithImage:UIUtil::Image(name)];
			[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.5];
		}
		
		frame.origin.y += 8;
		CGFloat height = icon.frame.size.height;
		icon.center = CGPointMake(width / 2, frame.origin.y + height / 2);
		icon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		frame.origin.y += height + 12;
	}
	
	//
	UILabel *label = UIUtil::LabelWithFrame(frame, title, font, UIUtil::Color(0xf9f9f9), NSTextAlignmentCenter);
	label.numberOfLines = 0;

	self = [super initWithFrame:CGRectMake(0, 0, width, CGRectGetMaxY(frame) + 8)];
	
	self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
	self.layer.cornerRadius = 6;
	self.clipsToBounds = YES;
	
	[self addSubview:icon];
	[self addSubview:label];
	
	return self;
}

//
#ifdef _ToastViewWithShowingAnimation
- (void)didMoveToSuperview
{
	if (self.superview)
	{
		self.alpha  = 0;
		[UIView animateWithDuration:0.4 animations:^()
		 {
			 self.alpha  = 1;
		 }];
	}
	[super didMoveToSuperview];
}
#endif

//
#ifdef _ToastViewWithHidingAnimation
- (void)removeFromSuperview
{
	[UIView animateWithDuration:0.2 animations:^()
	 {
		 self.alpha  = 0;
	 } completion:^(BOOL finished)
	 {
		 [super removeFromSuperview];
	 }];
}
#endif

//
+ (ToastView *)toastWithTitle:(NSString *)title type:(ToastViewType)type
{
	return [UIUtil::FrontViewController().view toastWithTitle:title type:type];
}

//
+ (ToastView *)toastWithTitle:(NSString *)title
{
	return [UIUtil::FrontViewController().view toastWithTitle:title];
}

//
+ (ToastView *)toastWithInfo:(NSString *)info
{
	return [UIUtil::FrontViewController().view toastWithInfo:info];
}

//
+ (ToastView *)toastWithError:(NSString *)error
{
	return [UIUtil::FrontViewController().view toastWithError:error];
}

//
+ (ToastView *)toastWithCancel:(NSString *)cancel
{
	return [UIUtil::FrontViewController().view toastWithCancel:cancel];
}

//
+ (ToastView *)toastWithSuccess:(NSString *)success
{
	return [UIUtil::FrontViewController().view toastWithSuccess:success];
}

//
+ (ToastView *)toastWithLoading:(NSString *)loading
{
	return[UIUtil::FrontViewController().view toastWithLoading:loading];
}

//
+ (ToastView *)toastWithLoading
{
	return[UIUtil::FrontViewController().view toastWithLoading];
}

//
+ (void)dismissToast
{
	[UIUtil::FrontViewController().view dismissToast];
}

@end

