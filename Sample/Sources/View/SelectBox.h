
//
@interface SelectBox: UIControl
@property(nonatomic,weak) id param;
- (id)initWithFrame:(CGRect)frame picker:(UIView *)picker;
@property(nonatomic,readonly) UIView *picker;
@property(nonatomic,readonly) UIToolbar *toolbar;
@end
