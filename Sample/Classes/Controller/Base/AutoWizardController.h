

#import "WizardController.h"

// 自动隐藏键盘（默认启用）、自动下一个（默认启用）、自动滚动（默认启用）
@interface AutoWizardController : WizardController
{
	BOOL _noAutoHide;
	BOOL _noAutoNext;
	BOOL _noAutoScroll;

	BOOL _keyboardShown;
	NSMutableArray *_textFields;
}

- (id)initWithAutoHide:(BOOL)autoHide autoNext:(BOOL)autoNext autoScroll:(BOOL)autoScroll;

//- (void)lookupTextFieldsInView:(UIView *)view;
//- (void)pushTextField:(UITextField *)textField;

@end
