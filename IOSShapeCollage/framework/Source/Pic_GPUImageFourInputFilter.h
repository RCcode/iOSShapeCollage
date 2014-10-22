//
//  Pic_GPUImageFourInputFIlter.h
//  FreeCollage
//
//  Created by MAXToooNG on 14-10-10.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//
#import "GPUImageThreeInputFilter.h"
extern NSString *const kGPUImageFourInputTextureVertexShaderString;
@interface Pic_GPUImageFourInputFilter : GPUImageThreeInputFilter
{
    GPUImageFramebuffer *fourthInputFramebuffer;
    
    GLint filterFourthTextureCoordinateAttribute;
    GLint filterInputTextureUniform4;
    GPUImageRotationMode inputRotation4;
    GLuint filterSourceTexture4;
    CMTime fourthFrameTime;
    
    BOOL hasSetThridTexture, hasReceivedFourthFrame, fourthFrameWasVideo;
    BOOL fourthFrameCheckDisabled;
}

- (void)disableFourthFrameCheck;

@end

