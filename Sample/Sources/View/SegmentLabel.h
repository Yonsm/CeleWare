
#import <UIKit/UIKit.h>


//
typedef enum
{
	SegmentItemTextAlignmentLeft,
	SegmentItemTextAlignmentCenter,
	SegmentItemTextAlignmentRight,
} SegmentItemTextAlignment;

//
@interface SegmentItem : NSObject
{
	NSString *_text;
	UIFont *_font;
	UIColor *_color;
	UIColor *_highlightedColor;

	CGFloat _shadowBlur;
	CGSize _shadowOffset;
	UIColor *_shadowColor;
	
	CGFloat _width;
	SegmentItemTextAlignment _alignment;
}

+ (id)segmentItemWithSpace:(CGFloat)width;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment;

@property(nonatomic,retain) NSString *text;				// Default is nil
@property(nonatomic,retain) UIFont *font;				// Must not be nil if text is not nil
@property(nonatomic,retain) UIColor *color;				// Default is nil, use previous color
@property(nonatomic,retain) UIColor *highlightedColor;	// Default is nil, same as color

@property(nonatomic,assign) CGFloat shadowBlur;			// Default is 0
@property(nonatomic,assign) CGSize shadowOffset;		// Default is {0, 0}
@property(nonatomic,retain) UIColor *shadowColor;		// Default is nil, no shadow

@property(nonatomic,assign) CGFloat width;				// Default is 0
@property(nonatomic,assign) SegmentItemTextAlignment alignment;	// Default is NSTextAlignmentLeft, only valid if width is not 0

@end


//
typedef enum
{
	SegmentLabelBaseAlignmentCenter,
	SegmentLabelBaseAlignmentBottom,
	SegmentLabelBaseAlignmentTop,
} SegmentLabelBaseAlignment;

@interface SegmentLabel : UIView
{
	NSArray *_items;
	BOOL _highlighted;
	CGFloat _lineWidth;
	CGFloat _lineHeight;
	SegmentLabelBaseAlignment _baseAlignment;
}

@property(nonatomic,retain) NSArray *items;
@property(nonatomic,assign) BOOL highlighted;
@property(nonatomic,readonly) CGFloat lineWidth;
@property(nonatomic,readonly) CGFloat lineHeight;
@property(nonatomic,readonly) NSUInteger lineCount;
@property(nonatomic,assign) SegmentLabelBaseAlignment baseAlignment;

@end
