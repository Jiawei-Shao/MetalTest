//
//  Renderer.h
//  RenderPassTest
//
//  Created by wp on 2019/4/2.
//  Copyright © 2019 wp. All rights reserved.
//

#import <MetalKit/MetalKit.h>

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

