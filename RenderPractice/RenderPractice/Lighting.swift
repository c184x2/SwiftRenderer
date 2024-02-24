//
//  Lighting.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 18..
//

import Foundation

struct Lighting {
    static func DefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Sun
        return light
    }
    
    let sunlight: Light = {
        var light = Self.DefaultLight()
        light.position = [20, 20, -20]
        return light
    }()
    
    let redLight: Light = {
        var light = Self.DefaultLight()
        light.type = PointLight
        light.position = [-15, 10, 10]
        light.color = [1, 0, 0]
        light.attenuation = [0.5, 2, 1]
        return light
    }()
    
    let ambientLight: Light = {
        var light = Self.DefaultLight()
        light.color = [0.1, 0.1, 0.1]
        light.type = Ambient
        return light
    }()
    
    var lights: [Light] = []
    
    init() {
        lights.append(sunlight)
        lights.append(ambientLight)
        lights.append(redLight)
    }
}
