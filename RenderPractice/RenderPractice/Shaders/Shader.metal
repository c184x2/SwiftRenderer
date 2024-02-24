//
//  Shader.metal
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 04..
//

#include <metal_stdlib>
#import "Common.h"
#import "Lighting.h"
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
    float3 normal [[attribute(2)]];
    float3 tangent [[attribute(4)]];
    float3 bitangent [[attribute(5)]];
};


struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float3 worldPosition;
    float3 worldNormal;
    float3 worldTangent;
    float3 worldBitangent;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position,
        .uv = in.uv,
        .worldPosition = (uniforms.modelMatrix * in.position).xyz,
        .worldNormal = uniforms.normalMatrix * in.normal,
        .worldTangent = uniforms.normalMatrix * in.tangent,
        .worldBitangent = uniforms.normalMatrix * in.bitangent
    };
    return out;
}

fragment float4 fragment_main(
                              VertexOut in [[stage_in]],
                              constant Params &params [[buffer(ParamsBuffer)]],
                              constant Light *lights [[buffer(LightBuffer)]],
                              constant Material &_material [[buffer(MaterialBuffer)]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              texture2d<float> normalTexture [[texture(NormalTexture)]])
{
    Material material = _material;
    constexpr sampler textureSampler(
                                     filter::linear,
                                     address::repeat,
                                     mip_filter::linear,
                                     max_anisotropy(8));
    
    if (!is_null_texture(baseColorTexture)) {
      material.baseColor = baseColorTexture.sample(
      textureSampler,
      in.uv * params.tiling).rgb;
    }
    
    float3 normal;
    if (is_null_texture(normalTexture)) {
        normal = in.worldNormal;
    } else {
        normal = normalTexture.sample(
                                      textureSampler,
                                      in.uv * params.tiling).rgb;
        normal = normal * 2 - 1;
        normal = float3x3(
                          in.worldTangent,
                          in.worldBitangent,
                          in.worldNormal) * normal;
    }
    
    normal = normalize(normal);

    float3 color = phongLighting(normal,
                                 in.worldPosition,
                                 params,
                                 lights,
                                 material
                                 );
    
    return float4(color, 1);
}
