

#import "SelectBox.h"


@implementation SelectBox

//
- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame picker:[[[UIDatePicker alloc] init] autorelease]];
}

//
- (id)initWithFrame:(CGRect)frame picker:(UIView *)picker
{
	self = [super initWithFrame:frame];
	
	self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
	[self addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

	_picker = picker;
	_picker.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
	[self addSubview:_picker];
	
	_toolbar = [[[UIToolbar alloc] init] autorelease];
	_toolbar.barStyle = UIBarStyleBlack;
	_toolbar.translucent = YES;
	_toolbar.items = @
	[
	 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
	 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)] autorelease],
	 ];
	[self addSubview:_toolbar];
	
	return self;
}

//
//- (void)dealloc
//{
//	[super dealloc];
//}

//
- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (self.superview)
	{
		CGRect frame = self.frame;
		CGFloat halfHeight = _picker.frame.size.height / 2;
		_toolbar.frame = CGRectMake(0, frame.size.height, 320, 44);
		_picker.center = CGPointMake(frame.size.width / 2, frame.size.height + 44 + halfHeight);
		
		self.alpha = 0;
		[UIView animateWithDuration:0.3 animations:^()
		 {
			 self.alpha = 1;
			 _picker.center = CGPointMake(frame.size.width / 2, frame.size.height - halfHeight);
			 _toolbar.frame = CGRectMake(0, frame.size.height - halfHeight * 2 - 44, 320, 44);
			 
		 }];
	}
}

//
- (void)removeFromSuperview
{
	CGRect frame = self.frame;
	CGFloat halfHeight = _picker.frame.size.height / 2;
	
	[UIView animateWithDuration:0.3 animations:^()
	 {
		 self.alpha = 0;
		 _toolbar.frame = CGRectMake(0, frame.size.height, 320, 44);
		 _picker.center = CGPointMake(frame.size.width / 2, frame.size.height + 44 + halfHeight);
	 } completion:^(BOOL finished)
	 {
		 [super removeFromSuperview];
	 }];
}

//
- (void)doneButtonClicked:(id)sender
{
	[self removeFromSuperview];
	[self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];
}

@end

