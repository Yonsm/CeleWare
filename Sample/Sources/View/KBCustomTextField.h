
//
@interface UIKBKey : NSObject
{
}
@property(copy, nonatomic) NSString* name;
@property(copy, nonatomic) NSString* representedString;
@property(copy, nonatomic) NSString* displayString;
@property(copy, nonatomic) NSString* displayType;
@property(copy, nonatomic) NSString* interactionType;
@property(copy, nonatomic) NSString* variantType;
@property(assign, nonatomic) BOOL visible;
@property(assign, nonatomic) unsigned displayTypeHint;
@property(retain, nonatomic) NSString* displayRowHint;
@property(copy, nonatomic) NSArray* variantKeys;
@property(copy, nonatomic) NSString* overrideDisplayString;
@property(assign, nonatomic) BOOL disabled;
@property(assign, nonatomic) BOOL hidden;
@end


//
@interface UIKBKeyView : UIView
{
}
@property(readonly, assign, nonatomic) UIKBKey* key;
@end


//
@class KBCustomTextField;
@protocol KBCustomTextFieldDelegate
@required
- (void)keyboardShow:(KBCustomTextField *)sender;
- (void)keyboardHide:(KBCustomTextField *)sender;
@end


//
@interface KBCustomTextField: UITextField


@property(nonatomic,weak) IBOutlet id/*<KBCustomTextFieldDelegate>*/ kbDelegate;

+ (UIKBKeyView *)findKeyView:(NSString *)name;
+ (UIKBKeyView *)modifyKeyView:(NSString *)name display:(NSString *)display represent:(NSString *)represent interaction:(NSString *)type;

@end

//
@interface ActionNumberField: KBCustomTextField <KBCustomTextFieldDelegate>
{
}
@property(nonatomic,readonly) UIButton *actionButton;
- (id)initWithFrame:(CGRect)frame actionButtonTitle:(NSString *)actionButtonTitle;
@end
