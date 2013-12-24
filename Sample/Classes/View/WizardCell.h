
#define kLeftGap	15
#define kRightGap	9
#define kTitleGap	10
#define kDefaultCellHeight		44	// 默认单元行高度

//
enum WizardCellBorderType
{
	WizardCellBorderNoneLine = 0,
	WizardCellBorderTopLine = 1,
	WizardCellBorderBottomLine = 2,
	
	WizardCellBorderTop = WizardCellBorderTopLine,
	WizardCellBorderMiddle = 0,
	WizardCellBorderBottom = WizardCellBorderBottomLine,
	WizardCellBorderOone = WizardCellBorderTopLine + WizardCellBorderBottomLine,
};

//
enum WizardCellAccessoryType
{
	WizardCellAccessoryNone,
	WizardCellAccessoryDropup,
	WizardCellAccessoryDropdown,
	WizardCellAccessoryCheckmark,
	WizardCellAccessoryDisclosure,
};

//
@interface WizardCell : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)setBorderType:(WizardCellBorderType)borderType;	// 只能调用一次

- (void)setNameAlignTop:(BOOL)top;

@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL action;
@property(nonatomic,strong) id param;	// For external use
@property(nonatomic,assign) void *param2;	// For external use
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *detail;
@property(nonatomic,readonly) UILabel *nameLabel;
@property(nonatomic,readonly) UILabel *detailLabel;
@property(nonatomic,strong) UIView *accessoryView;
@property(nonatomic,readonly) CGRect maxAccessoryFrame;
@property(nonatomic,assign) WizardCellAccessoryType accessoryType;
@end
