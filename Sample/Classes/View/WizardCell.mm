
#import "WizardCell.h"

@implementation WizardCell

#pragma mark Generic methods

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.backgroundColor = UIColor.whiteColor;
	return self;
}

//
- (UIView *)lineWithFrame:(CGRect)frame
{
	UIView *line = [[UIView alloc] initWithFrame:frame];
	line.backgroundColor = UIUtil::Color(0xcccccc);
	[self addSubview:line];
	return line;
}

//
- (void)setBorderType:(WizardCellBorderType)borderType
{
	CGRect frame = self.frame;
	if (borderType & WizardCellBorderTopLine)
	{
		[self lineWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
	}
	else
	{
		[self lineWithFrame:CGRectMake(kLeftGap, 0, frame.size.width - kLeftGap, 0.5)];
	}

	if (borderType & WizardCellBorderBottomLine)
	{
		[self lineWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
	}
}

//
- (NSString *)name
{
	return _nameLabel.text;
}

//
- (NSString *)detail
{
	return _detailLabel.text;
}

//
- (void)setName:(NSString *)name
{
	UIFont *font = [UIFont systemFontOfSize:17];
	CGRect frame = {kLeftGap, (self.frame.size.height - 20) / 2, [name sizeWithFont:font].width, 20};
	if (_nameLabel == nil)
	{
		_nameLabel = [UILabel labelWithFrame:frame
										text:name
									   color:[UIColor blackColor]
										font:font
								   alignment:NSTextAlignmentLeft];
		[self addSubview:_nameLabel];
	}
	else
	{
		_nameLabel.text = name;
		_nameLabel.frame = frame;
	}
}

//
- (void)setDetail:(NSString *)detail
{
	UIFont *font = [UIFont systemFontOfSize:16];
	CGFloat x = CGRectGetMaxX(_nameLabel.frame) + 10;
	CGFloat right = (_accessoryView ? _accessoryView.frame.origin.x : self.frame.size.width) - kRightGap;
	CGRect frame = {x, 2, right - x, self.frame.size.height - 4};
	if (_detailLabel == nil)
	{
		_detailLabel = [UILabel labelWithFrame:frame
										  text:detail
										 color:UIUtil::Color(90, 90, 90)
										  font:font
									 alignment:NSTextAlignmentRight];
		_detailLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:_detailLabel];
	}
	else
	{
		_detailLabel.text = detail;
		_detailLabel.frame = frame;
	}
}

//
- (void)setNameAlignTop:(BOOL)top
{
	CGRect frame = _nameLabel.frame;
	frame.origin.y = ((top ? kDefaultCellHeight : self.frame.size.height) - 20) / 2;
	_nameLabel.frame = frame;
}

#pragma View methods

//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_target && _action)
	{
		self.backgroundColor = UIUtil::Color(0xd9d9d9);
	}
	[super touchesBegan:touches withEvent:event];
}

//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_target && _action)
	{
		[self performSelector:@selector(setBackgroundColor:) withObject:UIUtil::Color(0xffffff) afterDelay:0.15];
		//self.backgroundColor = UIUtil::Color(0xffffff);
		_SuppressPerformSelectorLeakWarning([_target performSelector:_action withObject:self]);
	}
	[super touchesEnded:touches withEvent:event];
}

//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_target && _action)
	{
		self.backgroundColor = UIUtil::Color(0xffffff);
	}
	[super touchesCancelled:touches withEvent:event];
}


#pragma mark Content methods

//
- (CGRect)maxAccessoryFrame
{
	CGRect frame = self.bounds;
	frame.size.height -= 4;
	frame.size.width -= kLeftGap + kRightGap;
	if (_nameLabel.text.length) frame.size.width -= [_nameLabel.text sizeWithFont:_nameLabel.font].width + kTitleGap;
	return frame;
}

//
- (void)setAccessoryView:(UIView *)accessoryView
{
	if (_accessoryView != accessoryView)
	{
		[_accessoryView removeFromSuperview];
		_accessoryView = accessoryView;
		
		if (accessoryView)
		{
			accessoryView.center = CGPointMake(self.frame.size.width - kRightGap - accessoryView.frame.size.width / 2, self.frame.size.height / 2 + 0.5);
			[self addSubview:accessoryView];
		}
	}
}

//
- (void)setAccessoryType:(WizardCellAccessoryType)accessoryType
{
	if ((accessoryType == WizardCellAccessoryPopup) || (accessoryType == WizardCellAccessoryDropdown) || (accessoryType == WizardCellAccessoryDisclosure))
	{
		if ((_accessoryType != WizardCellAccessoryPopup) && (_accessoryType != WizardCellAccessoryDropdown) && (_accessoryType != WizardCellAccessoryDisclosure))
		{
			self.accessoryView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"CellAccessoryDisclosure")];
		}
		
		if (accessoryType == WizardCellAccessoryPopup)
		{
			self.accessoryView.transform = CGAffineTransformMakeRotation((M_PI / 180.0) * -90);
		}
		else if (accessoryType == WizardCellAccessoryDropdown)
		{
			self.accessoryView.transform = CGAffineTransformMakeRotation((M_PI / 180.0) * 90);
		}
	}
	else if (accessoryType == WizardCellAccessoryEnter)
	{
		self.accessoryView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"CellAccessoryEnter")];
	}
	else if (accessoryType == WizardCellAccessoryCheckmark)
	{
		self.accessoryView = [[UIImageView alloc] initWithImage:UIUtil::Image(@"CellAccessoryCheckmark")];
	}
	else
	{
		self.accessoryView = nil;
	}
	_accessoryType = accessoryType;
}

@end
