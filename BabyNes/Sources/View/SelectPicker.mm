

#import "SelectPicker.h"


@implementation SelectPicker

//
- (id)initWithItems:(NSArray *)items
{
	return [self initWithItems:items selectedIndex:0];
}

//
- (id)initWithItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex
{
	self = [super init];
	self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
	self.showsSelectionIndicator = YES;
	self.dataSource = self;
	self.delegate = self;
	
	_items = items;

	[self selectRow:selectedIndex inComponent:0 animated:NO];
	
	return self;
}

//

//
- (NSInteger)selectedIndex
{
	return [self selectedRowInComponent:0];
}

//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// Returns the # of rows in each component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return _items.count;
}

//
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return _items[row];
}

//
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_SuppressPerformSelectorLeakWarning([_target performSelector:_changed withObject:self]);
}

@end

