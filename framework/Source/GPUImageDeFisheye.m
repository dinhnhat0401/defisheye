//
//  GPUImageDeFisheye.m
//  GPUImage
//
//  Created by Nhat Dinh Van on 8/16/16.
//

#import "GPUImageDeFisheye.h"

NSString *const kFishEyeFragmentShader = SHADER_STRING
(
#define PI 3.14159265358979
#define _THETA_S_Y_SCALE	(640.0 / 720.0)

 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float radius;
 uniform lowp vec4 uvOffset;
 
 void main()
{
    lowp vec2 revUV = textureCoordinate.st;
    if (textureCoordinate.x <= 0.5) {
        revUV.x = revUV.x * 2.0;
    } else {
        revUV.x = (revUV.x - 0.5) * 2.0;
    }
    
    revUV *= PI;
    
    lowp vec3 p = vec3(cos(revUV.x), cos(revUV.y), sin(revUV.x));
    p.xz *= sqrt(1.0 - p.y * p.y);
    
    lowp float r = 1.0 - asin(p.z) / (PI / 2.0);
    lowp vec2 st = vec2(p.y, p.x);
    
    st *= r / sqrt(1.0 - p.z * p.z);
    st *= radius;
    st += 0.5;
    
    if (textureCoordinate.x <= 0.5) {
        st.x *= 0.5;
        st.x += 0.5;
        st.y = 1.0 - st.y;
        st.xy += uvOffset.wz;
    } else {
        st.x = 1.0 - st.x;
        st.x *= 0.5;
        st.xy += uvOffset.yx;
    }
    
    st.y = st.y * _THETA_S_Y_SCALE;
    
    gl_FragColor = texture2D(inputImageTexture, st);
}
 );

@implementation GPUImageDeFisheye


- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kFishEyeFragmentShader]))
    {
        return nil;
    }
    
    GLint radiusUniform = [filterProgram uniformIndex:@"radius"];
    [self setFloat:0.445 forUniform:radiusUniform program:filterProgram];
    
    GLint uvOffsetUniform = [filterProgram uniformIndex:@"uvOffset"];
    GPUVector4 uvOffset = {0, 0, 0, 0};
    [self setVec4:uvOffset forUniform:uvOffsetUniform program:filterProgram];
    
    return self;
}

@end
