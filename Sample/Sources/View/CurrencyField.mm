

#import "CurrencyField.h"

@implementation CurrencyField

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	self.keyboardType = UIKeyboardTypeDecimalPad;
	self.font = [UIFont systemFontOfSize:16];
	self.textColor = [UIColor colorWithWhite:50/255.0 alpha:1];
	self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.adjustsFontSizeToFitWidth = YES;
	self.clearButtonMode = UITextFieldViewModeWhileEditing;
	
	//[self addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
	[self addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
	//[self addTarget:self action:@selector(editingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	
	return self;
}

//
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	return (action != @selector(paste:)) && [super canPerformAction:action withSender:sender];
}

//
- (void)setLeadingSymbol:(NSString *)symbol
{
	if (symbol)
	{
		CGFloat leftGap = self.background.size.width / 2;
		CGFloat width = symbol.length ? [symbol sizeWithFont:self.font].width + 6 : 0;
		
		self.leftViewMode = UITextFieldViewModeAlways;
		self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftGap + width, self.frame.size.height)];
		
		if (symbol.length)
		{
			UILabel *label = UIUtil::LabelWithFrame(CGRectMake(leftGap, 0, width, self.frame.size.height - 2), symbol, self.font, [UIColor lightGrayColor], NSTextAlignmentCenter);
			[self.leftView addSubview:label];
		}
	}
	else
	{
		self.leftView = nil;
	}
}

//
- (void)layoutFollowSymbol
{
	if (_followLabel)
	{
		CGRect frame = _followLabel.frame;
		frame.origin.x = [self.text sizeWithFont:self.font].width;
		if (self.leftView)
		{
			frame.origin.x += self.leftView.frame.size.width;
		}
		_followLabel.frame = frame;
		_followLabel.hidden = (self.text.length == 0) || (frame.origin.x + frame.size.width) >= (self.frame.size.width - 20 - self.rightView.frame.size.width);
	}
}

//
- (void)layoutSubviews
{
	[super layoutSubviews];
	[self layoutFollowSymbol];
}

//
- (void)setFollowSymbol:(NSString *)symbol
{
	[_followLabel removeFromSuperview];
	if (symbol)
	{
		_followLabel = UIUtil::LabelWithFrame(CGRectMake(0, 0, [symbol sizeWithFont:self.font].width + 6, self.frame.size.height - 2), symbol, self.font, [UIColor lightGrayColor], NSTextAlignmentCenter);
		if (self.rightView)
		{
			[self insertSubview:_followLabel belowSubview:self.rightView];
		}
		else
		{
			[self addSubview:_followLabel];
		}
		[self layoutFollowSymbol];
	}
	else
	{
		_followLabel = nil;
	}
}

//
- (void)editingChanged:(UITextField *)sender
{
	NSString *text = self.text;
	NSArray *texts = [text componentsSeparatedByString:@"."];
	if (texts.count >= 2)
	{
		BOOL modified = (texts.count > 2);
		NSString *text1 = [texts objectAtIndex:0];
		if (text1.length == 0)
		{
			text1 = @"0";
			modified = YES;
		}
		
		NSString *text2 = [texts objectAtIndex:1];
		if (text2.length > 2)
		{
			modified = YES;
			text2 = [text2 substringToIndex:2];
		}
		
		if (modified)
		{
			self.text = [NSString stringWithFormat:@"%@.%@", text1, text2];
		}
	}
	[self layoutFollowSymbol];
}

@end

