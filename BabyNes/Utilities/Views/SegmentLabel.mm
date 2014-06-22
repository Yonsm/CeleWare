

#import "SegmentLabel.h"


@implementation SegmentItem

//
+ (id)segmentItemWithSpace:(CGFloat)width
{
	SegmentItem *label = [[SegmentItem alloc] init];
	label.width = width;
	return label;
}

//
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
	SegmentItem *label = [[SegmentItem alloc] init];
	label.text = text;
	label.font = font;
	label.color = color;
	return label;
}

//
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width
{
	SegmentItem *label = [self segmentItemWithText:text font:font color:color];
	label.width = width;
	return label;
}

//
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment
{
	SegmentItem *label = [self segmentItemWithText:text font:font color:color width:width];
	label.alignment = alignment;
	return label;
}

//

@end


@implementation SegmentLabel

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.userInteractionEnabled = NO;
	//self.backgroundColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:0.2];
	self.opaque = NO;
	return self;
}

//

//
- (void)setHighlighted:(BOOL)highlighted
{
	_highlighted = highlighted;
	[self setNeedsDisplay];
}

//
- (void)setItems:(NSArray *)items
{
	if (_items != items)
	{
		_items = items;
	}
	
	_lineWidth = 0;
	_lineHeight = 0;
	for (SegmentItem *item in _items)
	{
		CGSize size = {0};
		if (item.text.length)
		{
			size = [item.text sizeWithFont:item.font];
			//size.width = ceil(size.width);
			//size.height = ceil(size.height);
		}
		_lineWidth += item.width ? item.width : size.width;
		if (_lineHeight < size.height)
		{
			_lineHeight = size.height;
		}
	}
	
	[self setNeedsDisplay];
}

//
- (NSUInteger)lineCount
{
	NSUInteger width = self.bounds.size.width;
	return ((NSUInteger)_lineWidth/* + 3*/ + width - 1) / width;	// MAGIC: 3, but why?
}

//
- (CGSize)contentSizeForWidth:(CGFloat)width
{
	return CGSizeMake(MIN(width, _lineWidth), _lineHeight * self.lineCount);
}

//
- (void)sizeToFit
{
	CGRect frame = self.frame;
	frame.size = [self contentSizeForWidth:frame.size.width];
	self.frame = frame;
}

//#define SEG_TEST
#ifdef SEG_TEST
CGFloat _white = 0;
CGFloat _step = 0;
CGContextRef _context = nil;
#endif

//
- (CGFloat)drawText:(NSString *)text atPoint:(CGPoint)point font:(UIFont *)font right:(CGFloat)right width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment
{
	CGSize size = [text sizeWithFont:font];
	if (point.x + size.width <= right)
	{
#ifdef SEG_TEST
		CGContextSaveGState(_context);
		CGContextSetFillColorWithColor(_context, [UIColor colorWithWhite:_white alpha:1].CGColor);
		CGContextFillRect(_context, CGRectMake(point.x, point.y, width ? width : size.width, _lineHeight));
		CGContextRestoreGState(_context);
#endif
		
		if (width > size.width)
		{
			if (alignment == NSTextAlignmentRight)
			{
				point.x += width - size.width;
			}
			else if (alignment == NSTextAlignmentCenter)
			{
				point.x += (width - size.width) / 2;
			}
		}
		
		if (_baseAlignment == SegmentLabelBaseAlignmentBottom)
		{
			if (_lineHeight >= size.height + 2)
			{
				point.y += _lineHeight - size.height - 2;	// MAGIC: 2 is minor fix
			}
		}
		else if (_baseAlignment != SegmentLabelBaseAlignmentTop)
		{
			point.y += (_lineHeight - size.height) / 2;
		}
		else
		{
			if (_lineHeight >= size.height + 2)
			{
				point.y += 2;	// MAGIC: 2 is minor fix
			}
		}
		
		CGSize size = [text drawAtPoint:point withFont:font];
		return size.width;
	}
	return 0;
}

//
- (void)drawRect:(CGRect)rect
{
	// Adjust content rect based on content mode
	UIViewContentMode contentMode = self.contentMode;
	if (contentMode != UIViewContentModeTopLeft)
	{
		CGSize size = [self contentSizeForWidth:rect.size.width];
		
		if (rect.size.width >= size.width)
		{
			if ((contentMode == UIViewContentModeRight) || (contentMode == UIViewContentModeTopRight) || (contentMode == UIViewContentModeBottomRight))
			{
				rect.origin.x += rect.size.width - size.width;
			}
			else if ((contentMode != UIViewContentModeLeft) && (contentMode != UIViewContentModeTopLeft) && (contentMode != UIViewContentModeBottomLeft))
			{
				rect.origin.x += (rect.size.width - size.width) / 2;
			}
		}
		if (rect.size.height >= size.height)
		{
			if ((contentMode == UIViewContentModeBottom) || (contentMode == UIViewContentModeBottomLeft) || (contentMode == UIViewContentModeBottomRight))
			{
				rect.origin.y += rect.size.height - size.height;
			}
			else if ((contentMode != UIViewContentModeTop) && (contentMode != UIViewContentModeTopLeft) && (contentMode != UIViewContentModeTopRight))
			{
				rect.origin.y += (rect.size.height - size.height) / 2;
			}
		}
		//rect.size = size;
	}
	
	//
	CGPoint point = rect.origin;
	CGFloat right = rect.origin.x + rect.size.width;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
#ifdef SEG_TEST
	_white = 0;
	_step = _items.count ? (1.0 / _items.count) : 0;
	_context = context;
#endif
	
	for (SegmentItem *label in _items)
	{
		if (UIColor *color = (_highlighted && label.highlightedColor) ? label.highlightedColor : label.color)
		{
			CGContextSetFillColorWithColor(context, color.CGColor);
		}
		CGContextSetShadowWithColor(context, label.shadowOffset, label.shadowBlur, label.shadowColor.CGColor);
		
		CGFloat width = 0;
		NSString *text = label.text;
		if (text.length)
		{
			UIFont *font = label.font;
			
			while (!(width = [self drawText:text atPoint:point font:font right:right width:label.width alignment:label.alignment]))
			{
				NSUInteger i = 1;
				NSUInteger length = text.length;
				while ((i < length) && (point.x + [[text substringToIndex:i] sizeWithFont:font].width < right)) i++;
				
				if (i > 1)
				{
					[self drawText:[text substringToIndex:i - 1] atPoint:point font:font right:right width:0 alignment:label.alignment];
				}
				point.x = rect.origin.x;
				point.y += _lineHeight;
				
				if (i <= text.length)
				{
					text = [text substringFromIndex:i - 1];
				}
				else
				{
					break;
				}
			}
		}
		point.x += label.width ? label.width : width;
		
#ifdef SEG_TEST
		_white += _step;
#endif
	}
}

@end
