
#import "InputBox.h"

//
@implementation InputBox

- (id)initWithFrame:(CGRect)frame iconName:(NSString *)iconName
{
	self = [super initWithFrame:frame];
	self.background = UIUtil::StretchableImage(UIUtil::Image(@"InputBox"));
	self.leftView = [[UIImageView alloc] initWithImage:UIUtil::Image(iconName)];
	self.leftViewMode = UITextFieldViewModeAlways;
	[self addTarget:self action:@selector(textFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
	[self addTarget:self action:@selector(textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	
	return self;
}

//
- (void)textFieldEditingDidBegin:(UITextField *)sender
{
	sender.background = UIUtil::Image(@"InputBox_");
}

//
- (void)textFieldEditingDidEnd:(UITextField *)sender
{
	sender.background = UIUtil::Image(@"InputBox");
}

@end
