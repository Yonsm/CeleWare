
//
@interface DelayImageView: UIImageView
{
	BOOL _force;
	UIActivityIndicatorView *_activityView;
}

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame;

@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *def;
@property (nonatomic,readonly) BOOL loaded;
@end

