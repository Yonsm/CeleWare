

#import "SelectSheet.h"


@implementation SelectSheet

#pragma mark Generic methods

//
+ (id)sheetWithTitle:(NSString *)title items:(NSArray *)items target:(id)target changed:(SEL)changed
{
	return [[SelectSheet alloc] initWithTitle:title items:items target:target changed:changed];
}

// Constructor
- (id)initWithTitle:(NSString *)title items:(NSArray *)items target:(id)target changed:(SEL)changed
{
	self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	NSUInteger i = 0;
	for (NSString *item in items)
	{
		[self addButtonWithTitle:item];
		i++;
	}
	self.cancelButtonIndex = i;
	[self addButtonWithTitle:NSLocalizedString(@"Cancel", @"取消")];

	_target = target;
	_changed = changed;

	[self showInView:UIUtil::RootViewController().view];
	return self;
}

// Destructor
//- (void)dealloc
//{
//   [super dealloc];
//}

#pragma mark View methods

// Draws the image within the passed-in rectangle.
//- (void)drawRect:(CGRect)rect
//{
//	[super drawRect:rect];
//}

// Layout subviews.
//- (void)layoutSubviews
//{
//	[super layoutSubviews];
//}

// Set view frame.
//- (void)setFrame:(CGRect)frame
//{
//	[super setFrame:frame];
//}


#pragma mark Event methods

//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex < actionSheet.cancelButtonIndex)
	{
		_selectedIndex = buttonIndex;
		_SuppressPerformSelectorLeakWarning([_target performSelector:_changed withObject:self]);
	}
}

@end
