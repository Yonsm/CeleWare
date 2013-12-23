
//
@interface SelectBox: UIControl
{
}
- (id)initWithFrame:(CGRect)frame picker:(UIView *)picker;
@property(nonatomic,readonly) UIView *picker;
@property(nonatomic,readonly) UIToolbar *toolbar;
@end
