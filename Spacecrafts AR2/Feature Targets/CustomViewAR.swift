//
//  CustomARViewRepresenatable.swift
//  Spacecrafts AR
//
//  Created by Pranesh Velmurugan on 9/21/24.
//

import SwiftUI

struct CustomViewAR: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
