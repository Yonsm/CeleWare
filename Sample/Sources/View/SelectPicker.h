
//
@interface SelectPicker: UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
{
}

- (id)initWithItems:(NSArray *)items;

@property(nonatomic,readonly) NSInteger selectedIndex;
@property(nonatomic,readonly) NSArray *items;
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL changed;

@end
