
@protocol CacheImageProtocol
- (void)setImage:(UIImage *)image;
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
