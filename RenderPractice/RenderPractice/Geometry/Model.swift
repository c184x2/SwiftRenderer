//
//  Model.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 03..
//

import MetalKit

class Model: Transformable {
    
    enum MaterialType {
        case baseColor
        case normal
        case roughness
        case metalness
    }
    
    struct Materials {
        var baseColor: MTLTexture?
        var normal: MTLTexture?
        var roughness: MTLTexture?
        var metalness: MTLTexture?
        
        init(baseColor: MTLTexture? = nil, normal: MTLTexture? = nil, roughness: MTLTexture? = nil, metalness: MTLTexture? = nil) {
            self.baseColor = baseColor
            self.normal = normal
            self.roughness = roughness
            self.metalness = metalness
        }
    }
    
    var material: Materials? = Materials()
    var mtkMesh: MTKMesh
    var metalTextures: [MTLTexture] = []
    
    var transform: Transform
    var tiling: uint32
    
    init(name: String,
         transform: Transform = Transform(),
         tiling: UInt32 = 1) {
        let descriptor = MDLVertexDescriptor.defaultLayout
        let modelURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: modelURL,
                             vertexDescriptor: descriptor,
                             bufferAllocator: allocator)
        if let modelMesh = asset.childObjects(of: MDLMesh.self).first as? MDLMesh {
            do {
                mtkMesh = try MTKMesh(mesh: modelMesh, device: Renderer.device)
            } catch {
                fatalError("Failed to load mesh")
            }
        } else {
            fatalError("No mesh available")
        }
        
        self.transform = transform
        self.tiling = tiling
        
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        mdlMeshes.forEach { mdlMesh in mdlMesh.addTangentBasis(
            forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
            tangentAttributeNamed: MDLVertexAttributeTangent,
            bitangentAttributeNamed: MDLVertexAttributeBitangent)
        }
        
    }
    
    func BindTexture(textureName: String,
                     materialType: MaterialType) {
        
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .SRGB: (materialType == MaterialType.baseColor || materialType == MaterialType.normal)
        ]
        do {
            self.metalTextures.append(try textureLoader.newTexture(name: textureName,
                                                                   scaleFactor: 1.0,
                                                                   bundle: Bundle.main,
                                                                   options: textureLoaderOptions))
            
            switch materialType {
            case .baseColor: self.material!.baseColor = metalTextures.last!
            case .normal: self.material!.normal = metalTextures.last!
            case .roughness: self.material!.roughness = metalTextures.last!
            case .metalness: self.material!.metalness = metalTextures.last!
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
            fatalError("Unable to load texture.")}
    }
    
    func Render(encoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                params fragment: Params,
                vertexDescriptor: MDLVertexDescriptor) {
        
        encoder.setVertexBuffer(self.mtkMesh.vertexBuffers[0].buffer,
                                offset: 0,
                                index: 0)
        
        encoder.setVertexBuffer(self.mtkMesh.vertexBuffers[1].buffer,
                                offset: 0,
                                index: 3)
        
        encoder.setVertexBuffer(self.mtkMesh.vertexBuffers[2].buffer,
                                offset: 0,
                                index: 4)
        var uniforms = vertex
        var params = fragment
        uniforms.modelMatrix = transform.modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
        
        params.tiling = tiling
        
        encoder.setVertexBytes(&uniforms,
                               length: MemoryLayout<Uniforms>.stride,
                               index: 11)
        
        encoder.setFragmentBytes(&params,
                                 length: MemoryLayout<Uniforms>.stride,
                                 index: 12)
        
        encoder.setFragmentBytes(&material,
                                 length: MemoryLayout<Material>.stride,
                                 index: 14)
        
        encoder.setFragmentTexture(self.material!.baseColor, index: 0)
        encoder.setFragmentTexture(self.material!.normal, index: 1)
        encoder.setFragmentTexture(self.material!.roughness, index: 2)
        encoder.setFragmentTexture(self.material!.metalness, index: 3)
        
        for submesh in self.mtkMesh.submeshes {
            encoder.drawIndexedPrimitives(type: .triangle,
                                          indexCount: submesh.indexCount,
                                          indexType: submesh.indexType,
                                          indexBuffer: submesh.indexBuffer.buffer,
                                          indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
