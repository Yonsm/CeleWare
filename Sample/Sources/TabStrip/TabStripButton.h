
@interface TabStripButton : UIControl
{
@private
	UILabel* label;
	UIImageView* imageView;
}

- (void)markSelected;
- (void)markUnselected;	

@property(nonatomic,copy) NSString* text;
@property(weak, readonly) UIFont* font;
@end
