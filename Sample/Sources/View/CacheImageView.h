
@protocol CacheImageProtocol
- (void)setImage:(UIImage *)image;
@optional
- (void)setCacheImageUrl2:(NSString *)cacheImageUrl2;
- (void)cacheImageDownloaded2:(NSArray *)params;
@end

//
@interface UIView (CacheImage)
- (void)setCacheImageUrl:(NSString *)cacheImageUrl;
@end


//
@interface CacheImageButton : UIButton <CacheImageProtocol>
@end


//
@interface CacheBackgroundImageButton : UIButton <CacheImageProtocol>
@end

//
@interface CacheImageView : UIImageView	// 避免重入
@property(nonatomic,strong) NSString *cacheImageUrl2; // 外部勿用
@end