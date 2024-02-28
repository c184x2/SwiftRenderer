//
//  Camera.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 16..
//
import GameController

enum Settings {
  static var rotationSpeed: Float { 2.0 }
  static var translationSpeed: Float { 3.0 }
  static var mouseScrollSensitivity: Float { 0.1 }
  static var mousePanSensitivity: Float { 0.008 }
  static var touchZoomSensitivity: Float { 10 }
}

protocol Transformable {
  var transform: Transform { get set }
}

extension Transformable {
  var position: float3 {
    get { transform.position }
    set { transform.position = newValue }
  }
  var rotation: float3 {
    get { transform.rotation }
    set { transform.rotation = newValue }
  }
  var scale: Float {
    get { transform.scale }
    set { transform.scale = newValue }
  }
}


protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}

struct OrbitCamera: Camera {
    
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    
    var projectionMatrix: float4x4 {
      float4x4(
        projectionFov: fov,
        near: near,
        far: far,
        aspect: aspect)
    }

    let minDistance: Float = 0.0
    let maxDistance: Float = 40
    var target: float3 = [0, 0, 0]
    var distance: Float = 10.0
    
    var transform = Transform()
    
    var viewMatrix: float4x4 {
      let matrix: float4x4
        if target == transform.position {
            matrix = (float4x4(translation: target) * float4x4(rotationYXZ: transform.rotation)).inverse
      } else {
          matrix = float4x4(eye: transform.position, center: target, up: [0, 1, 0])
      }
      return matrix
    }
    
    mutating func update(size: CGSize) {
      aspect = Float(size.width / size.height)
    }
    
    mutating func update(deltaTime: Float) {
      let input = InputHandler.shared
      let scrollSensitivity = Settings.mouseScrollSensitivity
      distance -= (input.mouseScroll.x + input.mouseScroll.y)
        * scrollSensitivity
      distance = min(maxDistance, distance)
      distance = max(minDistance, distance)
      input.mouseScroll = .zero
      if input.leftMouseDown {
        let sensitivity = Settings.mousePanSensitivity
          transform.rotation.x += input.mouseDelta.y * sensitivity
          transform.rotation.y += input.mouseDelta.x * sensitivity
          transform.rotation.x = max(-.pi / 2, min(transform.rotation.x, .pi / 2))
        input.mouseDelta = .zero
      }
      let rotateMatrix = float4x4(
        rotationYXZ: [-transform.rotation.x, transform.rotation.y, 0])
      let distanceVector = float4(0, 0, -distance, 0)
      let rotatedVector = rotateMatrix * distanceVector
        transform.position = target + rotatedVector.xyz
    }
}
