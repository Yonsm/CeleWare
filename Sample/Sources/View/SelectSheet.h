
//
@interface SelectSheet : UIActionSheet <UIActionSheetDelegate>

+ (id)sheetWithTitle:(NSString *)title items:(NSArray *)items target:(id)target changed:(SEL)changed;
- (id)initWithTitle:(NSString *)title items:(NSArray *)items target:(id)target changed:(SEL)changed;

@property(nonatomic,readonly) NSInteger selectedIndex;
@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL changed;
@end
