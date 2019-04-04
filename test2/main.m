//
//  main.m
//  test2
//
//  Created by wp on 2019/4/3.
//  Copyright © 2019 wp. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Metal;

int main(int argc, const char * argv[]) {
    const int kBaseLevel = 1;
    const int kBaseSlice = 1;
    
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    MTLTextureDescriptor* mtlDesc = [MTLTextureDescriptor new];
    mtlDesc.textureType = MTLTextureType2DMultisample;
    mtlDesc.usage = MTLTextureUsageRenderTarget;
    mtlDesc.pixelFormat = MTLPixelFormatRGBA8Unorm;
    mtlDesc.width = 16;
    mtlDesc.height = 16;
    mtlDesc.depth = 1;
    mtlDesc.mipmapLevelCount = 1;
    mtlDesc.arrayLength = 1;
    mtlDesc.sampleCount = 4;
    mtlDesc.storageMode = MTLStorageModePrivate;
    id<MTLTexture> color = [device newTextureWithDescriptor:mtlDesc];
    
    MTLTextureDescriptor* mtlDesc2 = [MTLTextureDescriptor new];
    mtlDesc2.textureType = MTLTextureType2DArray;
    mtlDesc2.usage = MTLTextureUsageRenderTarget;
    mtlDesc2.pixelFormat = MTLPixelFormatRGBA8Unorm;
    mtlDesc2.width = 16 << kBaseLevel;
    mtlDesc2.height = 16 << kBaseSlice;
    mtlDesc2.depth = 1;
    mtlDesc2.mipmapLevelCount = kBaseLevel + 1;
    mtlDesc2.arrayLength = kBaseSlice + 1;
    mtlDesc2.sampleCount = 1;
    mtlDesc2.storageMode = MTLStorageModePrivate;
    id<MTLTexture> resolveTarget = [device newTextureWithDescriptor:mtlDesc2];
    
    MTLRenderPassDescriptor* renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0);
    renderPass.colorAttachments[0].texture = color;
    renderPass.colorAttachments[0].resolveTexture = resolveTarget;
    renderPass.colorAttachments[0].resolveSlice = kBaseSlice;
    renderPass.colorAttachments[0].resolveLevel = kBaseLevel;
    renderPass.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;

    id<MTLCommandQueue> queue = [device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [queue commandBuffer];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPass];
    [renderEncoder endEncoding];
    
    id<MTLBuffer> buffer = [device newBufferWithLength:8192 options:MTLResourceStorageModeShared];
    id<MTLBlitCommandEncoder> blit = [commandBuffer blitCommandEncoder];
    MTLOrigin origin;
    origin.x = 0;
    origin.y = 0;
    origin.z = 0;
    
    MTLSize size;
    size.width = 8;
    size.height = 8;
    size.depth = 1;
    
    [blit copyFromTexture:resolveTarget
              sourceSlice:kBaseSlice
              sourceLevel:kBaseLevel
             sourceOrigin:origin
               sourceSize:size
                 toBuffer:buffer
        destinationOffset:0
   destinationBytesPerRow:512
 destinationBytesPerImage:8192];
    
    [blit endEncoding];
    [commandBuffer commit];
    
    sleep(1);
    
    char* data = (char*)[buffer contents];

    // The screen will print "-1 0 0 -1" if we set kBaseSlice = 0 and kBaseLevel = 0
    printf("%d %d %d %d\n", (int)data[0], (int)data[1], (int)data[2], (int)data[3]);
    
    return 0;
}
