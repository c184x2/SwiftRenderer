//
//  Transform.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 03..
//

import Foundation

struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: Float = 1
    
    var modelMatrix: matrix_float4x4 {
      let translation = float4x4(translation: position)
      let rotation = float4x4(rotation: rotation)
      let scale = float4x4(scaling: scale)
      let modelMatrix = translation * rotation * scale
      return modelMatrix
    }
}
