//
//  Pic_GPUImageSixInputFilter.h
//  GPUImage
//
//  Created by MAXToooNG on 14-10-10.
//  Copyright (c) 2014年 Brad Larson. All rights reserved.
//

#import "Pic_GPUImageFiveInputFilter.h"
extern NSString *const kGPUImageSixInputTextureVertexShaderString;
@interface Pic_GPUImageSixInputFilter : Pic_GPUImageFiveInputFilter
{
    GPUImageFramebuffer *sixthInputFramebuffer;
    
    GLint filterSixthTextureCoordinateAttribute;
    GLint filterInputTextureUniform6;
    GPUImageRotationMode inputRotation6;
    GLuint filterSourceTexture6;
    CMTime sixthFrameTime;
    
    BOOL hasSetFifthTexture, hasReceivedSixthFrame, sixthFrameWasVideo;
    BOOL sixthFrameCheckDisabled;
}

- (void)disableSixthFrameCheck;

@end
