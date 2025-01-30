//
//  CustomARView.swift
//  Spacecrafts AR
//
//  Created by Pranesh Velmurugan on 9/21/24.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

class CustomARView: ARView {
    private var placementIndicator: ModelEntity?
    private var reticleAnchor: AnchorEntity?
    private var lastResetTime: TimeInterval = 0
    private var initialEntityScale: SIMD3<Float>?
    private var initialEntityRotation: simd_quatf?
    private var issEntity: ModelEntity?
    private var issAnchor: AnchorEntity?
    private var timer: Timer?
    private var earthEntity: ModelEntity?
    private var initialEarthRotation: simd_quatf?
    private var initialISSRotation: simd_quatf?
    private var issUpdateTimer: Timer?
    private var earthRotationGesture: UIRotationGestureRecognizer?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.run(configuration)
        
        session.delegate = self
        setupGestures()
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        setupPlacementIndicator()
        subscribeToActionStream()
        setupGestures()
    }
    
    private func setupPlacementIndicator() {
        let indicatorMesh = MeshResource.generateSphere(radius: 0.1)
        var material = SimpleMaterial()
        material.baseColor = try! .color(UIColor(red: 94.0/255, green: 111.0/255, blue: 186.0/255, alpha: 0.6))
        material.metallic = .init(floatLiteral: 0.0)
        material.roughness = .init(floatLiteral: 1.0)
        
        placementIndicator = ModelEntity(mesh: indicatorMesh, materials: [material])
        placementIndicator?.scale = [1, 0.1, 1]  // Flattened to make it more disc-like
        
        reticleAnchor = AnchorEntity(.plane([.horizontal], classification: [.any], minimumBounds: [0.2, 0.2]))
        reticleAnchor?.addChild(placementIndicator!)
        scene.addAnchor(reticleAnchor!)
    }
    
    func updatePlacementIndicator() {
        guard let placementIndicator = placementIndicator else { return }
        
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastResetTime > 1.0 {
            resetReticleAnchor()
            lastResetTime = currentTime
        }
        
        let screenCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        if let result = raycast(from: screenCenter, 
                              allowing: .estimatedPlane, 
                              alignment: .horizontal).first {
            placementIndicator.isEnabled = true
            
            var transform = Transform(matrix: result.worldTransform)
            transform.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            
            placementIndicator.position = transform.translation
            
            placementIndicator.transform.rotation = simd_quatf(
                angle: Float(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: .pi * 2),
                axis: [0, 1, 0]
            )
        } else {
            placementIndicator.isEnabled = false
        }
    }
    
    private func resetReticleAnchor() {
        if let oldAnchor = reticleAnchor {
            scene.anchors.remove(oldAnchor)
        }
        
        reticleAnchor = AnchorEntity(.plane([.horizontal], classification: [.any], minimumBounds: [0.2, 0.2]))
        if let indicator = placementIndicator {
            reticleAnchor?.addChild(indicator)
        }
        scene.addAnchor(reticleAnchor!)
    }
    
    
    private func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        self.addGestureRecognizer(rotationGesture)
        
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = scene.anchors.filter({ $0 != reticleAnchor }).last?.children.first else { return }
        
        switch gesture.state {
        case .began:
            initialEntityScale = entity.transform.scale
            
        case .changed:
            guard let initialScale = initialEntityScale else { return }
            let scaleFactor = Float(gesture.scale)
            let newScale = initialScale * scaleFactor
            entity.transform.scale = newScale
            
        case .ended:
            initialEntityScale = entity.transform.scale
            
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let entity = scene.anchors.filter({ $0 != reticleAnchor }).last?.children.first else { return }
        
        switch gesture.state {
        case .began:
            initialEntityRotation = entity.transform.rotation
            
        case .changed:
            guard let initialRotation = initialEntityRotation else { return }
            let rotation = simd_quatf(angle: Float(gesture.rotation), axis: SIMD3<Float>(0, 1, 0))
            entity.transform.rotation = initialRotation * rotation
            
        case .ended:
            initialEntityRotation = entity.transform.rotation
            
        default:
            break
        }
    }
    
    func placeLunar() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        
        anchor.position = placementIndicator.position
        anchor.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        
        do {
            let entity = try Entity.load(named: "Apollo Lunar Module 3D.usdz")
            
            entity.scale = [0.1, 0.1, 0.1]
            
            entity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            
            if let modelEntity = entity as? ModelEntity {
                let material = SimpleMaterial(color: .white, isMetallic: true)
                modelEntity.model?.materials = [material]
            }
            
            entity.generateCollisionShapes(recursive: true)
            anchor.addChild(entity)
        } catch {
            print("Failed to load Earth model: \(error.localizedDescription)")
            let box = ModelEntity(mesh: .generateBox(size: 0.1))
            box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
            anchor.addChild(box)
        }
        
        scene.addAnchor(anchor)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream() {
        ARManager.shared
            .actionStream
            .sink { [weak self] action in
                switch action {
                case .removeAllAnchors:
                    self?.scene.anchors.forEach { anchor in
                        if anchor != self?.reticleAnchor {
                            self?.scene.anchors.remove(anchor)
                        }
                    }
                case .placeLunarRover:
                    self?.placeLunarRover()
                case .placeLunar:
                    self?.placeLunar()
                case .placeISS:
                    self?.placeISS()
                case .placeEarth:
                    self?.placeEarth()
                case .placeSaturnV:
                    self?.placeSaturnV()
                case .placeJWST:
                    self?.placeJWST()
                case .placeIceSat:
                    self?.placeIceSat()
                }
            }
            .store(in: &cancellables)
    }
    
    func placeLunarRover() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        
        anchor.position = placementIndicator.position
        anchor.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        
        if let entity = try? Entity.load(named: "Lunar Rover AR.reality") {
            entity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            anchor.addChild(entity)
        } else {
            print("Failed to load the entity.")
        }
        
        scene.addAnchor(anchor)
    }

    func placeISS() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        anchor.position = placementIndicator.position
        
        do {
            let earthEntity = try ModelEntity.load(named: "Earth 3D Model.usdz")
            earthEntity.scale = [0.0007, 0.0007, 0.0007]
            
            let earthBounds = earthEntity.visualBounds(relativeTo: nil)
            let earthDiameter = earthBounds.extents.x
            let earthRadius = earthDiameter / 2
            let orbitRadius = earthRadius * 1.7
            
            let issEntity = try ModelEntity.load(named: "International Space Station.usdz")
            issEntity.scale = [0.00007, 0.00007, 0.00007]
            
            anchor.addChild(earthEntity)
            anchor.addChild(issEntity)
            scene.addAnchor(anchor)
            
            fetchISSLocation { [weak self] position in
                guard let position = position else { return }
                
                DispatchQueue.main.async {
                    let latRad = Float(position.latitude) * .pi / 180
                    let lonRad = Float(position.longitude) * .pi / 180
                    

                    let x = orbitRadius * cos(latRad) * sin(lonRad)
                    let y = orbitRadius * sin(latRad)
                    let z = orbitRadius * cos(latRad) * cos(lonRad)
                    
                    issEntity.position = [x, y, z]
                    print("ISS Position: (\(x), \(y), \(z))")
                }
            }
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    func placeEarth() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        anchor.position = placementIndicator.position
        
        do {
            let earthEntity = try ModelEntity.load(named: "International Space Station.usdz")
            
            let scale: Float = 0.001
            earthEntity.scale = [scale, scale, scale]

            anchor.addChild(earthEntity)
            scene.addAnchor(anchor)
            
            print("✅ Earth model loaded successfully")
            
        } catch {
            print("❌ Error loading Earth model: \(error.localizedDescription)")
        }
    }

    func placeSaturnV() {
        guard let placementIndicator = placementIndicator else { return }
        let anchor = AnchorEntity()
        anchor.position = placementIndicator.position
        
        do {
            
            let saturnVEntity = try ModelEntity.load(named: "Saturn V 3D.usdz")
            
            let scale: Float = 0.1
            saturnVEntity.scale = [scale, scale, scale]
            
            anchor.addChild(saturnVEntity)
            scene.addAnchor(anchor)
        } catch {
            print("Saturn V not found")
        }
    }

    func placeJWST() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        anchor.position = placementIndicator.position
        
        do {
            
            let jwstEntity = try ModelEntity.load(named: "JWST 2016 Composite.usdz")
            jwstEntity.scale = [0.1, 0.1, 0.1]
            
            
            anchor.addChild(jwstEntity)
            scene.addAnchor(anchor)
        }
        catch {
            print("JWST not found")
        }
    }

    func placeIceSat() {
        guard let placementIndicator = placementIndicator else { return }
        
        let anchor = AnchorEntity()
        anchor.position = placementIndicator.position
        
        do {
            let iceSatEntity = try ModelEntity.load(named: "ICESat-2 3D Model.usdz")
            
            iceSatEntity.scale = [0.1, 0.1, 0.1]
            anchor.addChild(iceSatEntity)
            scene.addAnchor(anchor)
        } catch {
            print("IceSat not found")
        }
    }

}

extension CustomARView: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updatePlacementIndicator()
    }
}
