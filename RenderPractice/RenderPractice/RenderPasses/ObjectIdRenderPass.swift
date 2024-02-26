/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MetalKit

struct ObjectIdRenderPass: RenderPass {
  let label = "Object ID Render Pass"
  var descriptor: MTLRenderPassDescriptor?
  var pipelineState: MTLRenderPipelineState
  var depthStencilState: MTLDepthStencilState?
  var idTexture: MTLTexture?
  var depthTexture: MTLTexture?

  init() {
    pipelineState = PipelineStates.createObjectIdPSO()
    descriptor = MTLRenderPassDescriptor()
    depthStencilState = Self.buildDepthStencilState()
  }

  mutating func resize(view: MTKView, size: CGSize) {
    idTexture = Self.makeTexture(
      size: size,
      pixelFormat: .r32Uint,
      label: "ID Texture")
    depthTexture = Self.makeTexture(
      size: size,
      pixelFormat: .depth32Float,
      label: "ID Depth Texture")
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    scene: MyScene,
    uniforms: Uniforms,
    params: Params
  ) {
    guard let descriptor = descriptor else {
      return
    }
    descriptor.colorAttachments[0].texture = idTexture
    descriptor.colorAttachments[0].loadAction = .clear
    descriptor.colorAttachments[0].storeAction = .store
    descriptor.depthAttachment.texture = depthTexture
    guard let renderEncoder =
      commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
    else { return }
    renderEncoder.label = label
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthStencilState)
    for model in scene.models {
      model.Render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params,
        vertexDescriptor: MDLVertexDescriptor.defaultLayout)
    }
    renderEncoder.endEncoding()
  }
}