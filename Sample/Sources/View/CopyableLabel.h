
@interface CopyableLabel : UILabel
{
	NSTimer* _holdTimer;
}

+ (id)copyableLabelWithFrame:(CGRect)frame
						text:(NSString *)text
					   color:(UIColor *)color
						font:(UIFont *)font
				   alignment:(NSTextAlignment)alignment;

+ (id)copyableLabelAtPoint:(CGPoint)point
					 width:(float)width
					  text:(NSString *)text
					 color:(UIColor *)color
					  font:(UIFont*)font
				 alignment:(NSTextAlignment)alignment;
@end
