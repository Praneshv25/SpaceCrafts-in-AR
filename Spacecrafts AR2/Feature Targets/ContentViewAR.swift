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
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.run(configuration)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        
        subscribeToActionStream()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream() {
        ARManager.shared
            .actionStream
            .sink { [weak self] action in
                switch action {
                    case .removeAllAnchors:
                        self?.scene.anchors.removeAll()
                    case .placeLunarRover:
                        self?.placeLunarRover()
                }
            }
            .store(in: &cancellables)
    }
    
    
    func placeLunarRover() {
        let anchor = AnchorEntity(plane: .horizontal)        
        
        if let entity = try? Entity.load(named: "Lunar Rover AR.reality") {
            anchor.addChild(entity)
        } else {
            print("Failed to load the entity.")
        }
        
        scene.addAnchor(anchor)
    }
    
}
