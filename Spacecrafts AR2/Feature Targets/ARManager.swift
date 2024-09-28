//
//  ARManager.swift
//  Spacecrafts AR2
//
//  Created by Pranesh Velmurugan on 9/21/24.
//

import Combine


class ARManager {
    static let shared = ARManager() //
    private init() { } // only ARManager can call init()
    // Makes it a singleton
    
    var actionStream = PassthroughSubject<ARAction, Never>()
    
}
