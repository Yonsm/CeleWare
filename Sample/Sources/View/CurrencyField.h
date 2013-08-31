

#import "KBCustomTextField.h"

//
@interface CurrencyField : DecimalNumberField
{
	UILabel *_followLabel;
}
- (void)setLeadingSymbol:(NSString *)symbol;	// @"¥"
- (void)setFollowSymbol:(NSString *)symbol;		// @"元"
@end
