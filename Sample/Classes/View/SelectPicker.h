
//
@interface SelectPicker: UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

- (id)initWithItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex;
- (id)initWithItems:(NSArray *)items;

@property(nonatomic,readonly) NSInteger selectedIndex;
@property(nonatomic,readonly) NSArray *items;
@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL changed;

@end
