
@interface CopyableLabel : UILabel

- (id)initAtPoint:(CGPoint)point
			width:(float)width
			 text:(NSString *)text
			color:(UIColor *)color
			 font:(UIFont *)font
		alignment:(NSTextAlignment)alignment;

//
- (id)initWithFrame:(CGRect)frame
			   text:(NSString *)text
			  color:(UIColor *)color
			   font:(UIFont *)font
		  alignment:(NSTextAlignment)alignment;

+ (id)copyableLabelWithFrame:(CGRect)frame
						text:(NSString *)text
					   color:(UIColor *)color
						font:(UIFont *)font
				   alignment:(NSTextAlignment)alignment;

#define NSTextAlignmentCenterOrLeft (NSTextAlignment)-1
+ (id)copyableLabelAtPoint:(CGPoint)point
					 width:(float)width
					  text:(NSString *)text
					 color:(UIColor *)color
					  font:(UIFont*)font
				 alignment:(NSTextAlignment)alignment;
@end
