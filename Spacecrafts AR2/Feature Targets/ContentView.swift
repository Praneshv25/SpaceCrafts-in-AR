//
//  ContentView.swift
//  Spacecrafts AR
//
//  Created by Pranesh Velmurugan on 9/19/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var colors: [Color] = [
        .green,
        .red,
        .blue
    ]
    
    var body: some View {
        CustomViewAR()
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal) {
                    HStack {
                        Button {
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(16)
                        }
                        Button {
                            ARManager.shared.actionStream.send(.placeLunarRover)
                        } label: {
                            Image(systemName: "cloud")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(16)
                        }

//                        ForEach(colors, id: \.self) { color in
//                            Button {
//                                ARManager.shared.actionStream.send(.placeObject(color: color))
//                            } label: {
//                                Image(systemName: "trash")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 40, height: 40)
//                                    .padding()
//                                    .background(.regularMaterial)
//                                    .cornerRadius(16)
//                            }
//                        }
                    }
                    .padding()
                }
            }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
