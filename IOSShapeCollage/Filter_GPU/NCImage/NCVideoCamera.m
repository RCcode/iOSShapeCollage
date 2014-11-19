

#import "NCFilters.h"
//#import "UIImage+SubImage.h"
//#import "UIImage+Rotate.h"

@interface NCVideoCamera () <NCImageFilterDelegate>
{
    //滤镜处理完成之后的回调
    FilterCompletionBlock _filterCompletionBlock;
}

@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture1;
@property (nonatomic, strong) GPUImagePicture *sourcePicture2;
@property (nonatomic, strong) GPUImagePicture *sourcePicture3;
@property (nonatomic, strong) GPUImagePicture *sourcePicture4;
@property (nonatomic, strong) GPUImagePicture *sourcePicture5;

@property (nonatomic, strong) GPUImageFilter *internalFilter;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture1;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture2;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture3;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture4;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture5;

@property (strong, readwrite) GPUImageView *gpuImageView_HD;
@property (strong, readwrite) GPUImageView *gpuImageView;

@property (nonatomic, strong) GPUImageFilter *rotationFilter;
@property (nonatomic, unsafe_unretained) NCFilterType currentFilterType;

@property (nonatomic, strong) GPUImagePicture *stillImageSource;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, unsafe_unretained, readwrite) BOOL isRecordingMovie;
@property (nonatomic, strong) AVAudioRecorder *soundRecorder;
@property (nonatomic, strong) AVMutableComposition *mutableComposition;
@property (nonatomic, strong) AVAssetExportSession *assetExportSession;

@property (nonatomic ,strong) UIImage *resultImage;

@property (nonatomic, assign) NSUInteger imagesIndex;

@end

@implementation NCVideoCamera

@synthesize filter;
@synthesize sourcePicture1;
@synthesize sourcePicture2;
@synthesize sourcePicture3;
@synthesize sourcePicture4;
@synthesize sourcePicture5;

@synthesize internalFilter;
@synthesize internalSourcePicture1;
@synthesize internalSourcePicture2;
@synthesize internalSourcePicture3;
@synthesize internalSourcePicture4;
@synthesize internalSourcePicture5;

@synthesize gpuImageView;
@synthesize gpuImageView_HD;
@synthesize rotationFilter;
@synthesize currentFilterType;
@synthesize rawImage;
@synthesize stillImageSource;

@synthesize stillImageOutput;

@synthesize delegate;

@synthesize movieWriter;
@synthesize isRecordingMovie;
@synthesize soundRecorder;
@synthesize mutableComposition;
@synthesize assetExportSession;



#pragma mark - Switch Filter
- (void)switchToNewFilter {
    
    
    
//    self.internalFilter.delegate = self;

    if (self.stillImageSource == nil) {
        self.filter = self.internalFilter;
    } else {
        [self.stillImageSource removeTarget:self.filter];
        self.filter = self.internalFilter;
        [self.stillImageSource addTarget:self.filter];
    }

    switch (currentFilterType) {
        case NC_F1_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;

            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            
            break;
        }
            
        case NC_F2_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            
            
            break;
        }
            
        case NC_F3_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            
            break;
        }
            
        case NC_F4_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            
            break;
        }
            
            
        case NC_F5_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];

            break;
        }
            
        case NC_F6_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            
            break;
        }
            
        case NC_F7_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            self.sourcePicture4 = self.internalSourcePicture4;
            self.sourcePicture5 = self.internalSourcePicture5;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture4 addTarget:self.filter];
            [self.sourcePicture5 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            [self.sourcePicture4 processImage];
            [self.sourcePicture5 processImage];

            break;
        }
            
        case NC_F8_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            self.sourcePicture4 = self.internalSourcePicture4;
            self.sourcePicture5 = self.internalSourcePicture5;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture4 addTarget:self.filter];
            [self.sourcePicture5 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            [self.sourcePicture4 processImage];
            [self.sourcePicture5 processImage];
            
            break;
        }
            
        case NC_F9_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            self.sourcePicture4 = self.internalSourcePicture4;
            self.sourcePicture5 = self.internalSourcePicture5;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture4 addTarget:self.filter];
            [self.sourcePicture5 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            [self.sourcePicture4 processImage];
            [self.sourcePicture5 processImage];
            
            
            break;
        }
            
        case NC_F10_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            self.sourcePicture4 = self.internalSourcePicture4;
            self.sourcePicture5 = self.internalSourcePicture5;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture4 addTarget:self.filter];
            [self.sourcePicture5 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            [self.sourcePicture4 processImage];
            [self.sourcePicture5 processImage];
            
            break;
        }
            
        case NC_F11_FILTER: {
            
            self.sourcePicture1 = self.internalSourcePicture1;
            
            [self.sourcePicture1 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];

            break;
        }
            
        case NC_F12_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
        
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            
            break;
        }
            
        case NC_F13_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            self.sourcePicture3 = self.internalSourcePicture3;
            self.sourcePicture4 = self.internalSourcePicture4;
            self.sourcePicture5 = self.internalSourcePicture5;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            [self.sourcePicture3 addTarget:self.filter];
            [self.sourcePicture4 addTarget:self.filter];
            [self.sourcePicture5 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            [self.sourcePicture3 processImage];
            [self.sourcePicture4 processImage];
            [self.sourcePicture5 processImage];
            
            break;
        }
            
        case NC_F14_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;

            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
 
            break;
        }
            
        case NC_F15_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            
            break;
        }
            
        case NC_F16_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture2 addTarget:self.filter];
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            
            break;
        }
            
        case NC_F17_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            
            [self.sourcePicture1 addTarget:self.filter];
            [self.sourcePicture1 processImage];
            
            break;
        }
//        case NC_F18_FILTER:
//        case NC_F19_FILTER:
//        case NC_F20_FILTER:
//        case NC_F21_FILTER:
//        case NC_F22_FILTER:
//        case NC_F23_FILTER:
//        case NC_F24_FILTER:
//        case NC_F25_FILTER:
//        case NC_F26_FILTER:
//        case NC_F27_FILTER:
//        case NC_F28_FILTER:
//        case NC_F29_FILTER:
//        case NC_F30_FILTER:
//        case NC_F31_FILTER:
//        case NC_F32_FILTER:
//        case NC_F33_FILTER:
//        case NC_F34_FILTER:
//        case NC_F35_FILTER:
//        case NC_F36_FILTER:
//        case NC_F37_FILTER:
//        {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            
//            [self.sourcePicture1 addTarget:self.filter];
//            [self.sourcePicture2 addTarget:self.filter];
//            [self.sourcePicture3 addTarget:self.filter];
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            
//            break;
//        }

            
        case NC_NORMAL_FILTER: {
            break;
        }
            
        default: {
            break;
        }
    }


    if (self.stillImageSource != nil) {
        self.gpuImageView_HD.hidden = NO;

        [self.stillImageSource processImage];
        [self.filter useNextFrameForImageCapture];
        self.resultImage = [self.filter imageFromCurrentFramebuffer];

        if (self.resultImage != nil) {
            
            if([delegate respondsToSelector:@selector(videoCameraDidFinishFilter:Index:)]){
                [delegate videoCameraDidFinishFilter:self.resultImage Index:_imagesIndex++];
            }
        }
    }
}



- (void)forceSwitchToNewFilter:(NCFilterType)type {

    currentFilterType = type;

//    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case NC_F1_FILTER: {
                self.internalFilter = [[NCF1Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCBlackboard1024" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
                break;
            }
                
            case NC_NORMAL_FILTER: {
                self.internalFilter = [[NCNormalFilter alloc] init];
                break;
            }
                
            case NC_F2_FILTER: {
                self.internalFilter = [[NCF2Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCBlackboard1024" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF2Map" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F3_FILTER: {
                self.internalFilter = [[NCF3Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF3Background" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF3Map" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F4_FILTER: {
                self.internalFilter = [[NCF4Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF4Map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCVignetteMap" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F5_FILTER: {
                self.internalFilter = [[NCF5Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF5Vignette" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF5Map" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F6_FILTER: {
                self.internalFilter = [[NCF6Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF6Map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCVignetteMap" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F7_FILTER: {
                self.internalFilter = [[NCF7Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF7Curves" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF7OverlayMap" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCVignetteMap" ofType:@"png"]]];
                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF7Blowout" ofType:@"png"]]];
                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF7Map" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F8_FILTER: {
                self.internalFilter = [[NCF8Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCVignetteMap" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF8Metal" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCSoftLight" ofType:@"png"]]];
                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF8EdgeBurn" ofType:@"png"]]];
                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF8Curves" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F9_FILTER: {
                self.internalFilter = [[NCF9Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF9Metal" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF9SoftLight" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF9Curves" ofType:@"png"]]];
                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF9OverlayMapWarm" ofType:@"png"]]];
                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF9ColorShift" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F10_FILTER: {
                self.internalFilter = [[NCF10Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF10Process" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF10Blowout" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF10Contrast" ofType:@"png"]]];
                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF10Luma" ofType:@"png"]]];
                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF10Screen" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F11_FILTER: {
                self.internalFilter = [[NCF11Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF11Map" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F12_FILTER: {
                self.internalFilter = [[NCF12Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF12Map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCVignetteMap" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F13_FILTER: {
                self.internalFilter = [[NCF13Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCEdgeBurn" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF13Map" ofType:@"png"]]];
                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF13GradientMap" ofType:@"png"]]];
                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF13SoftLight" ofType:@"png"]]];
                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF13Metal" ofType:@"png"]]];
                
                
                break;
            }
                
            case NC_F14_FILTER: {
                self.internalFilter = [[NCF14Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF14Map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF14GradientMap" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F15_FILTER: {
                self.internalFilter = [[NCF15Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF15Map" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F16_FILTER: {
                self.internalFilter = [[NCF16Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF16map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF16blowout" ofType:@"png"]]];
                
                break;
            }
                
            case NC_F17_FILTER: {
                self.internalFilter = [[NCF17Filter alloc] init];
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCKelvinMap" ofType:@"png"]]];
                
                break;
            }
//            case NC_F18_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51001" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F19_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51002" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F20_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51003" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F21_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51004" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F22_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51005" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F23_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51006" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F24_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51007" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F25_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51008" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F26_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51009" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F27_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51010" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F28_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51011" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F29_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51012" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F30_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51013" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F31_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51014" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F32_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51015" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F33_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51016" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F34_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51017" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F35_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51018" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F36_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51019" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
//            case NC_F37_FILTER :
//            {
//                self.internalFilter = [[NCFNewFilter alloc] init];
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51020" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NCF1Map" ofType:@"png"]]];
//                break;
//            }
                
            default:
                break;
        }
        
//        [self performSelectorOnMainThread:@selector(switchToNewFilter) withObject:nil waitUntilDone:NO];
    [self switchToNewFilter];
//    });
}


- (void)switchFilterType:(NCFilterType)type {
//    NSLog(@"switchFilterType");

    if ((self.rawImage != nil) && (self.stillImageSource == nil)) {
        self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage];
    }

    [self forceSwitchToNewFilter:(NCFilterType)type];
}

- (void)forceSwitchToNewFilterAfterDelay:(NSNumber *)type
{
    [self forceSwitchToNewFilter:(NCFilterType)type.intValue];
}



//#pragma mark - init
//- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highVideoQuality:(BOOL)isHighQuality WithFrame:(CGRect)frame{
//	if (!(self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition]))
//    {
//		return nil;
//    }
//    
//    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
//    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
//    [self.stillImageOutput setOutputSettings:outputSettings];
//    [self.captureSession addOutput:stillImageOutput];
//    
//    rotationFilter = [[GPUImageFilter alloc] init];
//    [rotationFilter setInputRotation:kGPUImageRotateRight atIndex:0];
//    [self addTarget:rotationFilter];
//    
//    self.filter = [[NCNormalFilter alloc] init];
//    self.internalFilter = self.filter;
//
//    [rotationFilter addTarget:filter];
//        
//    gpuImageView = [[GPUImageView alloc] initWithFrame:frame];
//    if (isHighQuality == YES) {
//        gpuImageView.layer.contentsScale = 2.0f;
//    } else {
//        gpuImageView.layer.contentsScale = 1.0f;
//    }
//    [filter addTarget:gpuImageView];
//
//    gpuImageView_HD = [[GPUImageView alloc] initWithFrame:[gpuImageView bounds]];
//    gpuImageView_HD.hidden = YES;
//    [gpuImageView addSubview:gpuImageView_HD];
//    
//    return self;
//}

- (id)initWithImage:(UIImage *)newImageSource
{
    if (self = [super init]) {
        self.rawImage = newImageSource;
    }
    return self;
}

+ (instancetype)videoCameraWithFrame:(CGRect)frame Image:(UIImage *)rawImage{
//    NCVideoCamera *instance = [[[self class] alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionUnspecified highVideoQuality:YES WithFrame:frame];
    
    NCVideoCamera *instance = [[self class] initWithImage:rawImage];
    
//    instance.rawImage = rawImage;
//    [instance switchFilterType:NC_NORMAL_FILTER];
    
    return instance;
}

- (void)switchFilter:(NCFilterType)type WithCompletionBlock:(FilterCompletionBlock)filterCompletionBlock{
    [self switchFilterType:type];
    _filterCompletionBlock = filterCompletionBlock;
}


#pragma mark 保存至本地相册 结果反馈
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error == nil) {
        MBProgressHUD *hud = showMBProgressHUD(LocalizedString(@"saved_in_album", nil), NO);
        [hud performSelector:@selector(hide:) withObject:nil afterDelay:1.5];
    }
}



- (void)setImage:(UIImage *)image WithFilterType:(NCFilterType)filterType Index:(NSUInteger)index {
    _imagesIndex = index;
    
    [stillImageSource removeAllTargets];
    stillImageSource = nil;
    self.rawImage = image;
//    self.gpuImageView.frame = (CGRect){CGPointZero, self.rawImage.size};
//    self.gpuImageView_HD.frame = self.gpuImageView.bounds;
    
    [self switchFilterType:filterType];
}

- (void)setImages:(NSArray *)images WithFilterType:(NCFilterType)filterType{
    _imagesIndex = 0;
    
    @autoreleasepool {
        for (UIImage *image in images) {
            if(![image isKindOfClass:[UIImage class]])
            {
                if([self.delegate respondsToSelector:@selector(videoCameraDidFinishFilter:Index:)])
                {
                    [self.delegate videoCameraDidFinishFilter:image Index:_imagesIndex++];
                }
                continue;
            }
            [stillImageSource removeAllTargets];
            stillImageSource = nil;
            self.rawImage = image;

            [self switchFilterType:filterType];
        }
    }
    
}

- (void)setImages:(NSArray *)images WithFilterTypes:(NSArray *)filterTypes{
    //图片数与滤镜数一一对应
    _imagesIndex = 0;
    
    for (int i=0; (i<images.count) && (i<filterTypes.count); i++) {
        UIImage *image = images[i];
        int filterType = [filterTypes[i] intValue];
        
        [stillImageSource removeAllTargets];
        stillImageSource = nil;
        self.rawImage = image;

        [self switchFilterType:filterType];
    }
    
    
}

@end
