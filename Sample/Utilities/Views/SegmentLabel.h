
//
typedef enum
{
	SegmentItemTextAlignmentLeft,
	SegmentItemTextAlignmentCenter,
	SegmentItemTextAlignmentRight,
} SegmentItemTextAlignment;

//
@interface SegmentItem : NSObject

+ (id)segmentItemWithSpace:(CGFloat)width;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width;
+ (id)segmentItemWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment;

@property(nonatomic,strong) NSString *text;				// Default is nil
@property(nonatomic,strong) UIFont *font;				// Must not be nil if text is not nil
@property(nonatomic,strong) UIColor *color;				// Default is nil, use previous color
@property(nonatomic,strong) UIColor *highlightedColor;	// Default is nil, same as color

@property(nonatomic,assign) CGFloat shadowBlur;			// Default is 0
@property(nonatomic,assign) CGSize shadowOffset;		// Default is {0, 0}
@property(nonatomic,strong) UIColor *shadowColor;		// Default is nil, no shadow

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
@property(nonatomic,strong) NSArray *items;
@property(nonatomic,assign) BOOL highlighted;
@property(nonatomic,readonly) CGFloat lineWidth;
@property(nonatomic,readonly) CGFloat lineHeight;
@property(nonatomic,readonly) NSUInteger lineCount;
@property(nonatomic,assign) SegmentLabelBaseAlignment baseAlignment;

@end
