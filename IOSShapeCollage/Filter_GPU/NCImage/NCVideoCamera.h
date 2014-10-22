
#import "GPUImage.h"
#import "NCFilters.h"
#import "NCImageFilter.h"


@class NCVideoCamera;

typedef void(^FilterCompletionBlock) (UIImage *filterImage);

@protocol NCVideoCameraDelegate <NSObject>
@optional
- (void)IFVideoCameraWillStartCaptureStillImage:(NCVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishCaptureStillImage:(NCVideoCamera *)videoCamera;
- (void)IFVideoCameraDidSaveStillImage:(NCVideoCamera *)videoCamera;
- (BOOL)canIFVideoCameraStartRecordingMovie:(NCVideoCamera *)videoCamera;
- (void)IFVideoCameraWillStartProcessingMovie:(NCVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishProcessingMovie:(NCVideoCamera *)videoCamera;

- (void)videoCameraResultImage:(NSArray *)arr;

- (void)videoCameraDidFinishFilter:(UIImage *)image Index:(NSUInteger)index;

@end

@interface NCVideoCamera : NSObject

@property (strong, readonly) GPUImageView *gpuImageView;
@property (strong, readonly) GPUImageView *gpuImageView_HD;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, assign) id delegate;
@property (nonatomic, unsafe_unretained, readonly) BOOL isRecordingMovie;



- (id)initWithImage:(UIImage *)newImageSource;


/** 选择滤镜类型 */
- (void)switchFilterType:(NCFilterType)type;



- (void)setImage:(UIImage *)image WithFilterType:(NCFilterType)filterType Index:(NSUInteger)index;
- (void)setImages:(NSArray *)images WithFilterTypes:(NSArray *)filterTypes;
- (void)setImages:(NSArray *)images WithFilterType:(NCFilterType)filterType;

@end
