
#import "WizardController.h"

#ifndef kLinkButtonFont
#define kLinkButtonFont [UIFont systemFontOfSize:15]
#endif

_EXObject(SelectBox, strong, WizardCell *, cell);

@implementation WizardController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	self = [super init];
//	return self;
//}

//

#pragma mark -
#pragma mark View methods

//
- (void)loadView
{
	[super loadView];
	
	_contentWidth = 320;
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	_scrollView.backgroundColor = UIUtil::Color(239, 239, 244);
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.alwaysBounceVertical = YES;
	[self.view addSubview:_scrollView];
	
	_contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
	[_scrollView addSubview:_contentView];
}

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self loadData];
}

//
- (void)viewDidUnload
{
	[super viewDidUnload];
	_cells = nil;
	_scrollView = nil;
}

#pragma mark -
#pragma mark Event methods

//
- (void)updateDoneButton
{
}

//
- (void)doneButtonClicked:(id)sender
{
	UIView *focusView = self.view.findFirstResponder;
	if (focusView)
	{
		[focusView resignFirstResponder];
		[self performSelector:@selector(doneAction) withObject:nil afterDelay:0.3];
	}
	else
	{
		[self doneAction];
	}
}

//
- (void)doneAction
{
}

#pragma mark -
#pragma mark Data methods

//
- (void)loadData
{
	[self reloadPage];
}

//
- (void)loadPage
{
}

//
- (void)reloadPage
{
	_contentHeight = 0;
	[_contentView removeSubviews];
	
	//[self spaceWithHeight:kDefaultHeaderHeight];
	
	[self loadPage];
	
	WizardCellBorderType top = WizardCellBorderTopLine;
	NSArray *subviews = _contentView.subviews;
	NSUInteger count = subviews.count;
	for (NSUInteger i = 0; i < count; i++)
	{
		WizardCell *cell = subviews[i];
		if ([cell isKindOfClass:[WizardCell class]])
		{
			CGRect frame = cell.frame;
			UIView *next = (i < count - 1) ? subviews[i + 1] : nil;
			WizardCellBorderType bottom = (CGRectGetMaxY(frame) != next.frame.origin.y) ? WizardCellBorderBottomLine : WizardCellBorderNoneLine;
			cell.borderType = (WizardCellBorderType)(top + bottom);
			top = (bottom == WizardCellBorderBottomLine) ? WizardCellBorderTopLine : WizardCellBorderNoneLine;
		}
		else
		{
			top = WizardCellBorderTopLine;
		}
	}
	
	CGRect frame = {0, 0, _contentWidth, _contentHeight + kScrollViewBottomPad};
	_contentView.frame = frame;
	_scrollView.contentSize = frame.size;
}

#pragma mark -
#pragma mark Content methods

//
- (void)addView:(UIView *)view
{
	[_contentView addSubview:view];
	_contentHeight += view.frame.size.height;
}

//
- (WizardCell *)cellWithHeight:(CGFloat)height
{
	if (_contentHeight == 0)
	{
		// 这将导致 Cell 默认不能粘着顶端；如果需要粘着顶部，先使用 [self spaceWithheight:kZeroHeaderHeight]
		_contentHeight = kDefaultHeaderHeight;
	}
	
	CGRect frame = CGRectMake(0, _contentHeight, _contentWidth, height);
	WizardCell *cell = [[WizardCell alloc] initWithFrame:frame];
	
	if (_cells == nil) 	_cells = [[NSMutableArray alloc] init];
	
	[_cells addObject:cell];
	[_contentView addSubview:cell];
	_contentHeight += height;
	return cell;
}

//
- (WizardCell *)cellWithName:(NSString *)name height:(CGFloat)height
{
	WizardCell *cell = [self cellWithHeight:height];
	if (name) cell.name = name;
	return cell;
}

//
- (WizardCell *)cellWithName:(NSString *)name
{
	return [self cellWithName:name height:kDefaultCellHeight];
}


//
- (WizardCell *)subtitleCellWithName:(NSString *)name detail:(NSString *)detail
{
	WizardCell *cell = [self cellWithName:name detail:detail];
	cell.nameAlignTop = YES;
	
	cell.detailLabel.font = [UIFont systemFontOfSize:16];
	cell.detailLabel.textAlignment = NSTextAlignmentLeft;
	
	CGRect frame = {kLeftGap, CGRectGetMaxY(cell.nameLabel.frame) + 4, _contentWidth - kLeftGap - kRightGap, 1000};
	frame.size.height = [cell.detail sizeWithFont:cell.detailLabel.font constrainedToSize:frame.size].height;
	//if (frame.size.height < 20) frame.size.height = 20;
	cell.detailLabel.frame = frame;
	cell.detailLabel.numberOfLines = 0;
	
	CGRect frame2 = cell.frame;
	CGFloat height = CGRectGetMaxY(frame) + kTitleGap;
	_contentHeight += height - frame2.size.height;
	frame2.size.height = height;
	cell.frame = frame2;
	
	return cell;
}

//
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail action:(SEL)action accessoryType:(WizardCellAccessoryType)type
{
	WizardCell *cell = [self cellWithName:name];
	cell.target = self;
	cell.action = action;
	cell.accessoryType = type;
	if (detail) cell.detail = detail;
	return cell;
}

//
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail action:(SEL)action
{
	return [self cellWithName:name detail:detail action:action accessoryType:WizardCellAccessoryDisclosure];
}

//
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail
{
	WizardCell *cell = [self cellWithName:name];
	cell.detail = detail;
	return cell;
}

//
- (WizardCell *)cellWithView:(UIView *)view
{
	WizardCell *cell = [self cellWithHeight:view.frame.size.height];
	[cell addSubview:view];
	return cell;
}

//
- (WizardCell *)cellWithView:(UIView *)view action:(SEL)action
{
	WizardCell *cell = [self cellWithView:view];
	cell.accessoryType = WizardCellAccessoryDisclosure;
	cell.target = self;
	cell.action = action;
	return cell;
}

//
- (void)spaceWithHeight:(CGFloat)height
{
	_contentHeight += height;
}

//
- (UILabel *)headerWithTitle:(NSString *)title
{
	[self spaceWithHeight:kDefaultHeaderHeight];
	UILabel *label = [self labelWithTitle:title];
	return label;
}

//
- (UILabel *)labelWithTitle:(NSString *)title
{
	UIFont *font = [UIFont boldSystemFontOfSize:14];
	UILabel *label = [UILabel labelAtPoint:CGPointMake(kLeftGap, _contentHeight + 5)
									 width:_contentWidth - 30
									  text:title
									 color:UIUtil::Color(0x4d4d4d)
									  font:font
								 alignment:NSTextAlignmentLeft];
	
	[_contentView addSubview:label];
	_contentHeight += label.frame.size.height + 10;
	return label;
}

//
- (UIButton *)checkWithTitle:(NSString *)title
{
	UIButton *check = [UIButton checkButtonWithTitle:title frame:CGRectMake(kLeftGap, _contentHeight + 5, 0, 28)];
	[_contentView addSubview:check];
	_contentHeight += check.frame.size.height + 10;
	return check;
}

//
- (UIButton *)checkWithTitle:(NSString *)title changed:(SEL)changed
{
	UIButton *check = [self checkWithTitle:title];
	[check addTarget:self action:changed forControlEvents:UIControlEventValueChanged];
	return check;
}

//
- (UIButton *)checkWithTitle:(NSString *)title changed:(SEL)changed alignment:(UIControlContentHorizontalAlignment)alignment
{
	UIButton *box = [self checkWithTitle:title changed:changed];
	CGRect frame = box.frame;
	if (alignment == UIControlContentHorizontalAlignmentRight)
	{
		frame.origin.x = _contentWidth - kRightGap - box.frame.size.width;
	}
	else if (alignment == UIControlContentHorizontalAlignmentRight)
	{
		frame.origin.x = (_contentWidth - box.frame.size.width) / 2;
	}
	box.frame = frame;
	return box;
}

//
- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action
{
	CGFloat width = 18 + [title sizeWithFont:kLinkButtonFont].width;
	UIButton *button = [UIButton linkButtonWithTitle:title frame:CGRectMake((_contentWidth - width) / 2, _contentHeight + 5, width, 0)];
	//button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	[_contentView addSubview:button];
	_contentHeight += button.frame.size.height + 10;
	return button;
}

//
- (NSArray *)buttonsWithTitles:(NSArray *)titles action:(SEL)action
{
	CGRect frame = {0/*kLeftGap*/, _contentHeight + 5, (_contentWidth/* - kLeftGap - kRightGap*/) / titles.count, 36};
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:titles.count];
	for (NSUInteger i = 0; i < titles.count; i++, frame.origin.x += frame.size.width)
	{
		UIButton *button = [UIButton linkButtonWithTitle:titles[i] frame:frame];
		button.titleLabel.font = [UIFont systemFontOfSize:17];
		//button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		
		button.tag = i;
		[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
		
		[_contentView addSubview:button];
		[buttons addObject:button];
	}
	_contentHeight += frame.size.height + 10;
	return buttons;
}

//
- (UIButton *)cellButtonWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title action:(SEL)action width:(CGFloat)width
{
	WizardCell *cell = [self cellWithName:name];
	
	UIFont *font = [UIFont systemFontOfSize:14];
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
	button.titleLabel.font = font;
	[button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageWithColor:UIUtil::Color(0x007aff)] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageWithColor:UIUtil::Color(0x209aff)] forState:UIControlStateHighlighted];
	[button setTitle:title forState:UIControlStateNormal];
	cell.accessoryView = button;
	
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	if (detail) cell.detail = detail;
	return button;
}

//
- (UIButton *)cellButtonWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title action:(SEL)action
{
	CGFloat width = [title sizeWithFont:[UIFont systemFontOfSize:14]].width + 18;
	return [self cellButtonWithName:name detail:detail title:title action:action width:width];
}

//
- (UITextField *)cellTextWithName:(NSString *)name text:(NSString *)text placeholder:(NSString *)placeholder changed:(SEL)changed
{
	WizardCell *cell = [self cellWithName:name];
	
	UITextField *field = [[UITextField alloc] initWithFrame:cell.maxAccessoryFrame];
	field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	field.textAlignment = NSTextAlignmentLeft;
	field.font = [UIFont systemFontOfSize:17];
	field.clearButtonMode = UITextFieldViewModeWhileEditing;
	field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	field.placeholder = placeholder;
	field.text = text;
	cell.accessoryView = field;
	
	[field addTarget:self action:changed forControlEvents:UIControlEventEditingChanged];
	return field;
}

//
- (UITextField *)cellNumberWithName:(NSString *)name text:(NSString *)text placeholder:(NSString *)placeholder changed:(SEL)changed
{
	UITextField *field = [self cellTextWithName:name
										   text:text
									placeholder:placeholder
										changed:changed];
	field.keyboardType = UIKeyboardTypeNumberPad;
	return field;
}

//
- (UIControl *)cellRadioWithName:(NSString *)name items:(NSArray *)items select:(NSUInteger)select changed:(SEL)changed
{
	WizardCell *cell = [self cellWithName:name];
	
	CGRect frame = cell.maxAccessoryFrame;
	UIControl *box = [[UIControl alloc] initWithFrame:frame];
	box.tag = -1;
	frame.size.width /= items.count ;
	for (NSUInteger i = 0; i < items.count; i++, frame.origin.x += frame.size.width)
	{
		UIButton *button = [UIButton linkButtonWithTitle:items[i] frame:frame];
		button.titleLabel.font = [UIFont systemFontOfSize:17];
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
		
		if (i == select)
		{
			box.tag = select;
			[self selectButton:button];
		}
		button.tag = i;
		[button addTarget:self action:@selector(radioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[box addSubview:button];
	}
	cell.accessoryView = box;
	
	[box addTarget:self action:changed forControlEvents:UIControlEventValueChanged];
	return box;
}

//
- (void)radioButtonClicked:(UIButton *)sender
{
	UIControl *box = (UIControl *)sender.superview;
	
	if (box.tag < box.subviews.count)
	{
		UIButton *button = box.subviews[box.tag];
		[self deselectButton:button];
	}
	
	if (sender.tag < box.subviews.count)
	{
		box.tag = sender.tag;
		
		UIButton *button = box.subviews[box.tag];
		[self selectButton:button];
		
		[box sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

//
- (void)selectButton:(UIButton *)button
{
	button.selected = YES;
	UIImage *image = UIUtil::ImageNamed(@"xuanze");
	UIImage *image_ = UIUtil::ImageNamed(@"xuanze_");
	[button setImage:image forState:(UIControlStateNormal)];
	[button setImage:image_ forState:(UIControlStateHighlighted)];
	
	CGFloat width = [button.currentTitle sizeWithFont:button.titleLabel.font].width;
	button.imageEdgeInsets = UIEdgeInsetsMake(0, width + 5, 0, 0);
	button.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, 0);
}

//
- (void)deselectButton:(UIButton *)button
{
	button.selected = NO;
	[button setImage:nil forState:(UIControlStateNormal)];
	[button setImage:nil forState:(UIControlStateHighlighted)];
	button.imageEdgeInsets = UIEdgeInsetsZero;
	button.titleEdgeInsets = UIEdgeInsetsZero;
}

#pragma -
#pragma mark Select box

//
- (SelectBox_cell *)selectBoxWithPicker:(UIView *)picker scrollToRect:(CGRect)rect
{
	SelectBox_cell *box = [[SelectBox_cell alloc] initWithFrame:self.navigationController.view.bounds picker:picker];
	[box addTarget:self action:@selector(selectBoxDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.navigationController.view addSubview:box];
	
	//
	CGFloat y = _scrollView.frame.size.height - picker.frame.size.height - 44 - rect.size.height - 2;
	rect.origin.y -= y;
	if (rect.origin.y < 0) rect.origin.y = 0;
	[_scrollView setContentOffset:rect.origin animated:YES];
	
	return box;
}

//
- (void)selectBoxDone:(SelectBox_cell *)sender
{
	CGFloat y = _scrollView.contentSize.height - _scrollView.frame.size.height;
	if (_scrollView.contentOffset.y > y)
	{
		if (y < 0) y = 0;
		[_scrollView setContentOffset:CGPointMake(0, y) animated:YES];
	}
	
	//if (sender.cell)
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 sender.cell.accessoryType = WizardCellAccessoryDropdown;
	 }];
}

#pragma -
#pragma mark Combo cell methods

//
- (WizardCell *)dateCellWithName:(NSString *)name date:(NSDate *)date changed:(SEL)changed
{
	return [self selectCellWithName:name
							 detail:NSUtil::SmartDate(date, NSDateFormatterMediumStyle, NSDateFormatterShortStyle)
							  items:(NSArray *)date
							changed:changed];
}

//
- (WizardCell *)selectCellWithName:(NSString *)name detail:(NSString *)detail items:(NSArray *)items changed:(SEL)changed
{
	WizardCell *cell = [self cellWithName:name
								   detail:detail
								   action:@selector(selectCellClicked:)
							accessoryType:WizardCellAccessoryDropdown];
	cell.param = items;
	cell.param2 = changed;
	return cell;
}

//
- (void)selectCellClicked:(WizardCell *)sender
{
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 sender.accessoryType = WizardCellAccessoryDropup;
	 }];
	
	id picker;
	if ([sender.param isKindOfClass:[NSDate class]])
	{
		picker = [[UIDatePicker alloc] init];
		[picker setDate:sender.param];
		[picker addTarget:self action:(SEL)sender.param2 forControlEvents:UIControlEventValueChanged];
	}
	else
	{
		picker = [[SelectPicker alloc] initWithItems:sender.param];
		[picker setTarget:self];
		[picker setChanged:(SEL)sender.param2];
	}
	
	[picker setTag:sender.tag];	// tag 传递
	[self selectBoxWithPicker:picker scrollToRect:sender.frame].cell = sender;
}

//
- (WizardCell *)sheetCellWithName:(NSString *)name detail:(NSString *)detail items:(NSArray *)items changed:(SEL)changed
{
	WizardCell *cell = [self cellWithName:name detail:detail
								   action:@selector(sheetCellClicked:)
							accessoryType:WizardCellAccessoryDropdown];
	cell.param = items;
	cell.param2 = changed;
	return cell;
}

//
- (void)sheetCellClicked:(WizardCell *)sender
{
	[[SelectSheet sheetWithTitle:sender.name
						   items:sender.param
						  target:self
						 changed:(SEL)sender.param2]
	 setTag:sender.tag];
}

//
- (WizardCell *)pageCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller
{
	WizardCell *cell = [self cellWithName:name detail:detail action:@selector(pageCellClicked:)];
	cell.param2 = (__bridge void *)controller;
	return cell;
}

//
- (WizardCell *)pageCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller param:(id)param
{
	WizardCell *cell = [self pageCellWithName:name detail:detail controller:controller];
	cell.param = param;
	return cell;
}

//
- (WizardCell *)popupCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller
{
	WizardCell *cell = [self pageCellWithName:name detail:detail controller:controller];
	//cell.accessoryType = WizardCellAccessoryDropup;
	return cell;
}

//
- (WizardCell *)popupCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller param:(id)param
{
	WizardCell *cell = [self popupCellWithName:name detail:detail controller:controller];
	cell.param = param;
	return cell;
}

//
- (WizardCell *)popupButtonCellWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title controller:(const NSString *)controller
{
	WizardCell *cell = (WizardCell *)[[self cellButtonWithName:name detail:detail title:title action:@selector(cellButtonClicked:)] superview];
	cell.param2 = (__bridge void *)controller;
	return cell;
}

//
- (WizardCell *)popupButtonCellWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title controller:(const NSString *)controller param:(id)param
{
	WizardCell *cell = [self popupButtonCellWithName:name detail:detail title:title controller:controller];
	cell.param = param;
	return cell;
}

//
- (void)cellButtonClicked:(UIButton *)sender
{
	[self pageCellClicked:(WizardCell *)sender.superview];
}

//
- (void)pageCellClicked:(WizardCell *)sender
{
	UIViewController<WizardControllerDelegate> *controller = [NSClassFromString((NSString *)sender.param2) alloc];
	
	if (sender.param) controller = [controller initWithParam:sender.param];
	else controller = [controller init];
	
	controller.title = sender.name;
	if (sender.accessoryType == WizardCellAccessoryDisclosure)
	{
		[self.navigationController pushViewController:controller animated:YES];
	}
	else
	{
		[self.navigationController presentModalNavigationController:controller animated:YES];
	}
	
}
@end
