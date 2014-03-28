

#import "BaseController.h"
#import "WizardCell.h"
#import "EXButton.h"
#import "SelectBox.h"
#import "SelectPicker.h"
#import "SelectSheet.h"

#define kMaxCellsPerPage		50
#define kDefaultHeaderHeight	20	// 默认单元头高度（仅指空标题的头，不包括标题文本）
#define kZeroHeaderHeight		-0.5	// 置顶单元头高度

//
@interface WizardController : BaseController
{
	CGFloat _contentWidth;
	CGFloat _contentHeight;
	UIView *_contentView;
	UIScrollView *_scrollView;

	UIButton *_lastButton;
	unsigned int _cellCount;
	__weak WizardCell *_cells[kMaxCellsPerPage];
}

- (void)updateDoneButton;
- (void)doneButtonClicked:(UIButton *)sender;
- (void)doneAction;

- (void)loadData;
- (void)loadPage;
- (void)reloadPage;

- (void)addView:(UIView *)view;

- (WizardCell *)cellWithHeight:(CGFloat)height;
- (WizardCell *)cellWithName:(NSString *)name;
- (WizardCell *)cellWithName:(NSString *)name height:(CGFloat)height;
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail;
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail action:(SEL)action;
- (WizardCell *)cellWithName:(NSString *)name detail:(NSString *)detail action:(SEL)action accessoryType:(WizardCellAccessoryType)type;
- (WizardCell *)cellWithView:(UIView *)view action:(SEL)action;
- (WizardCell *)cellWithView:(UIView *)view;

- (WizardCell *)subtitleCellWithName:(NSString *)name detail:(NSString *)detail;

- (void)spaceWithHeight:(CGFloat)height;
- (UILabel *)headerWithTitle:(NSString *)title;
- (UILabel *)labelWithTitle:(NSString *)title;
- (UILabel *)tipsWithTitle:(NSString *)title;

- (UIButton *)checkWithTitle:(NSString *)title;
- (UIButton *)checkWithTitle:(NSString *)title changed:(SEL)changed;
- (UIButton *)checkWithTitle:(NSString *)title changed:(SEL)changed alignment:(UIControlContentHorizontalAlignment)alignment;

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action color:(UIColor *)color color_:(UIColor *)color_;
- (UIButton *)majorButtonWithTitle:(NSString *)title action:(SEL)action;
- (UIButton *)minorButtonWithTitle:(NSString *)title action:(SEL)action;

- (NSArray *)buttonsWithTitles:(NSArray *)titles action:(SEL)action;

- (UIButton *)cellButtonWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title action:(SEL)action width:(CGFloat)width;
- (UIButton *)cellButtonWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title action:(SEL)action;
- (UIControl *)cellRadioWithName:(NSString *)name items:(NSArray *)items select:(NSUInteger)select changed:(SEL)changed;
- (UITextField *)cellTextWithName:(NSString *)name text:(NSString *)text placeholder:(NSString *)placeholder changed:(SEL)changed;
- (UITextField *)cellNumberWithName:(NSString *)name text:(NSString *)text placeholder:(NSString *)placeholder changed:(SEL)changed;

// 组合 Cell，点击 Cell 后自动处理相关事件
- (WizardCell *)dateCellWithName:(NSString *)name date:(NSDate *)date changed:(SEL)changed;	// 点击 Cell 后弹出时间选择
- (WizardCell *)selectCellWithName:(NSString *)name detail:(NSString *)detail items:(NSArray *)items changed:(SEL)changed;	// 点击 Cell 后弹出项目选择
- (WizardCell *)sheetCellWithName:(NSString *)name detail:(NSString *)detail items:(NSArray *)items changed:(SEL)changed;	// 点击 Cell 后弹出动作表单
- (WizardCell *)pageCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller;	// 点击 Cell 后进入新页面
- (WizardCell *)pageCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller param:(id)param;	// 带参数的 Controller，必须符合 WizardControllerDelegate
- (WizardCell *)popupCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller;	// 点击 Cell 后弹出新页面
- (WizardCell *)popupCellWithName:(NSString *)name detail:(NSString *)detail controller:(const NSString *)controller param:(id)param;	// 带参数的 Controller，必须符合 WizardControllerDelegate
- (WizardCell *)popupButtonCellWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title controller:(const NSString *)controller;
- (WizardCell *)popupButtonCellWithName:(NSString *)name detail:(NSString *)detail title:(NSString *)title controller:(const NSString *)controller param:(id)param;

// 用 SelectBox 包装弹出 Picker，For subclass only
- (SelectBox *)selectBoxWithPicker:(UIView *)picker scrollToCell:(WizardCell *)cell;
- (void)selectBoxDone:(SelectBox *)sender;

@end
