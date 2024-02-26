//
//  Scene.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 18..
//

import MetalKit

class MyScene {
    static var objectId: UInt32 = 1
    var models: [Model] = []
    var camera = OrbitCamera()
    
    lazy var UFO: Model = {
        let model = Model(name: "UFO",
                          transform: Transform(position: float3(0, 6, 5), scale: 2.0),
                          objectID: 1)
        model.BindTexture(textureName: "UFO_color", materialType: .baseColor)
        model.BindTexture(textureName: "UFO_nmap", materialType: .normal)
        model.BindTexture(textureName: "UFO_rough", materialType: .roughness)
        model.BindTexture(textureName: "UFO_metalness", materialType: .metalness)
        return model
    }()
    
    lazy var ground: Model = {
        let model = Model(name: "plane",
                          transform: Transform(position: float3(0, 0, 0), scale: 16.0),
                          tiling: 16,
                          objectID: 0)
        model.BindTexture(textureName: "grass", materialType: .baseColor)
        return model
    }()
    
    lazy var house: Model = {
        let model = Model(name: "lowpoly-house",
                          transform: Transform(position: float3(5, 0, 5), scale: 1.0),
                          tiling: 1,
                          objectID: 2)
        model.BindTexture(textureName: "barn", materialType: .baseColor)
        return model
    }()
    
    /*lazy var farmhouse: Model = {
        let model = Model(name: "farmhouse_obj",
                          transform: Transform(position: float3(-5, 0, 5), scale: 0.2),
                          tiling: 1)
        model.BindTexture(textureName: "Farmhouse Texture", materialType: .baseColor)
        model.BindTexture(textureName: "Farmhouse Texture Bump Map ", materialType: .normal)
        return model
    }()*/
    
    lazy var cube: Model = {
        let model = Model(name: "cube",
                          transform: Transform(position: float3(0, 1.05, 0), scale: 1.0),
                          tiling: 1,
                          objectID: 4)
        model.BindTexture(textureName: "cube-color", materialType: .baseColor)
        model.BindTexture(textureName: "cube-normal", materialType: .normal)
        model.BindTexture(textureName: "cube-roughness", materialType: .roughness)
        return model
    }()
    
    let lighting = Lighting()
    
    init() {
        setupScene()
    }
    
    func setupScene() {
        models.append(UFO)
        models.append(ground)
        models.append(house)
        //models.append(farmhouse)
        models.append(cube)
        
        for model in models {
            print("ModelMatrix: \(model.transform.modelMatrix),\(model.tiling) \n")
            print("Tangent and bitangent: \(model.transform.modelMatrix),\(model.tiling) \n")
        }
    }
}
