//
//  Pic_GPIImageFiveInputFilter.h
//  GPUImage
//
//  Created by MAXToooNG on 14-10-10.
//  Copyright (c) 2014年 Brad Larson. All rights reserved.
//

#import "Pic_GPUImageFourInputFIlter.h"

extern NSString *const kGPUImageFiveInputTextureVertexShaderString;
@interface Pic_GPUImageFiveInputFilter : Pic_GPUImageFourInputFilter
{
    GPUImageFramebuffer *fifthInputFramebuffer;
    
    GLint filterFifthTextureCoordinateAttribute;
    GLint filterInputTextureUniform5;
    GPUImageRotationMode inputRotation5;
    GLuint filterSourceTexture5;
    CMTime fifthFrameTime;
    
    BOOL hasSetFourthTexture, hasReceivedFifthFrame, fifthFrameWasVideo;
    BOOL fifthFrameCheckDisabled;
}

- (void)disableFifthFrameCheck;

@end
