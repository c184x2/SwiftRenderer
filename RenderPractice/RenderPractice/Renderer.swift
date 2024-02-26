//
//  Renderer.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 03..
//
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var depthStencilState: MTLDepthStencilState!
    var pipelineState: MTLRenderPipelineState!
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var uniforms = Uniforms()
    var params = Params()
    
    lazy var scene = MyScene()
    
    var objectIdRenderPass: ObjectIdRenderPass
    var forwardRenderPass: ForwardRenderPass
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        
        forwardRenderPass = ForwardRenderPass(view: metalView)
        objectIdRenderPass = ObjectIdRenderPass()
        
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.0,
            alpha: 1.0)
        
        metalView.delegate = self
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
}

extension Renderer {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        forwardRenderPass.resize(view: view, size: size)
        objectIdRenderPass.resize(view: view, size: size)
    }
    
    func updateUniforms(scene: MyScene) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        
        var lights = scene.lighting.lights
        
        scene.camera.update(deltaTime: deltaTime)
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position
    }
    
    func draw(in view: MTKView) {
        
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        updateUniforms(scene: scene)
        
        objectIdRenderPass.draw(
          commandBuffer: commandBuffer,
          scene: scene,
          uniforms: uniforms,
          params: params)
        
        forwardRenderPass.idTexture = objectIdRenderPass.idTexture
        forwardRenderPass.descriptor = descriptor
        
        forwardRenderPass.draw(
          commandBuffer: commandBuffer,
          scene: scene,
          uniforms: uniforms,
          params: params)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
