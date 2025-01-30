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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        Button {
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            ARManager.shared.actionStream.send(.placeLunarRover)
                        } label: {
                            Image("Lunar_rover")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            ARManager.shared.actionStream.send(.placeLunar)
                        } label: {
                            Image("Lunar Lander")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            ARManager.shared.actionStream.send(.placeISS)
                        } label: {
                            Image("earth")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            ARManager.shared.actionStream.send(.placeEarth)
                        } label: {
                            Image("ISS")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            ARManager.shared.actionStream.send(.placeSaturnV)
                        } label: {
                            Image("Saturn V")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            ARManager.shared.actionStream.send(.placeJWST)
                        } label: {
                            Image("JWST")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            ARManager.shared.actionStream.send(.placeIceSat)
                        } label: {
                            Image("ICESAT 2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .background(Color.black.opacity(0.5))
            }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
