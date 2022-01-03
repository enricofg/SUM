//
//  ARViewController.swift
//  SUM
//
//  Created by Enrico Florentino Gomes on 03/01/2022.
//

import UIKit
import RealityKit
import ARKit

class ARViewController: UIViewController {

    @IBOutlet var arView: ARView!
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the AR session for horizontal plane tracking
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arView.session.run(arConfiguration)
        
        // Load the BusScene from the "Experience" Reality File
        let busScene = try! ExperienceCopy.loadBusScene()
        
        // Add the BusScene anchor to the scene
        arView.scene.anchors.append(busScene)
        
        networkManager.fetchBus(busNumber: 5) { [weak self] (bus) in
            DispatchQueue.main.async {
                
                let capacity = bus.first?.Bus_Capacity ?? 0
                var description = ""
                                
                let progressBar = busScene.progress
                progressBar?.children.remove((progressBar?.children[0])!)
                progressBar?.children.remove((progressBar?.children[1])!)
                progressBar?.children.remove((progressBar?.children[1])!)
                progressBar?.children.remove((progressBar?.children[2])!)
                                
                let barEntity : Entity = (progressBar?.children[1].children[0])!
                var barModelComp: ModelComponent = (barEntity.components[ModelComponent.self])!
                var barMaterial = SimpleMaterial()
                //var scale: SIMD3<Float>(1.0, 1.0, 1.0)
                if(capacity<40){
                    barMaterial.color = .init(tint: (self?.hexStringToUIColor(hex: "#3e9a2c"))!).self
                    description="Vazio"
                    barEntity.scale = [1,1+Float(capacity/80),1]
                } else if (capacity>=40&&capacity<=60) {
                    barMaterial.color = .init(tint: (self?.hexStringToUIColor(hex: "#e1cd00"))!).self
                    description="Médio"
                    barEntity.scale = [1,1.25+Float(capacity/90),1]
                } else {
                    barMaterial.color = .init(tint: (self?.hexStringToUIColor(hex: "#bb1111"))!).self
                    description="Cheio"
                    barEntity.scale = [1,1.5+Float(capacity/100),1]
                }
                    //barEntity.scale = [1,1+Float(capacity/75),1]
                    barModelComp.materials[0] = barMaterial
                
                let valueEntity: Entity = (progressBar?.children[0].children[0].children[0])!
                var valueModelComp: ModelComponent = (valueEntity.components[ModelComponent.self])!
                var valueMaterial = SimpleMaterial()
                //valueMaterial.color = .init(tint: .white).self
                valueMaterial.color = .init(tint: (self?.hexStringToUIColor(hex: "#FFFFFF"))!).self
                    valueModelComp.materials[0] = valueMaterial
                    valueModelComp.mesh = .generateText("\(description) - Lotação: \(capacity)%",
                                                        extrusionDepth: 0.001,
                                                font: .systemFont(ofSize: 0.03),
                                      containerFrame: CGRect(),
                                           alignment: .left,
                                       lineBreakMode: .byCharWrapping)

                progressBar?.children[0].children[0].children[0].components.set(valueModelComp)
                progressBar?.children[1].children[0].components.set(barModelComp)
            }
        }
    }
    
    //function to convert Hex value to UIColor class
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
