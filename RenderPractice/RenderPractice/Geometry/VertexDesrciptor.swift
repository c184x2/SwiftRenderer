//
//  VertexDesrciptor.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 03..
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultlayout: MTLVertexDescriptor {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)!
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        
        var offset = 0
        vertexDescriptor.attributes[0]
        = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        
        vertexDescriptor.attributes[1] =
        MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<float2>.stride
        
        vertexDescriptor.attributes[2] =
        MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        vertexDescriptor.layouts[0]
        = MDLVertexBufferLayout(stride: offset)
        
        vertexDescriptor.attributes[4] =
        MDLVertexAttribute(
            name: MDLVertexAttributeTangent,
            format: .float3,
            offset: 0,
            bufferIndex: 3)
        vertexDescriptor.layouts[3]
        = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        
        vertexDescriptor.attributes[5] =
        MDLVertexAttribute(
            name: MDLVertexAttributeBitangent,
            format: .float3,
            offset: 0,
            bufferIndex: 4)
        vertexDescriptor.layouts[4]
        = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)

        return vertexDescriptor
    }()
}
