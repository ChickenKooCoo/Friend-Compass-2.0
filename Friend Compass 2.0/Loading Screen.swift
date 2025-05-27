//
//  Loading screen.swift
//  Friend Compass 2.0
//
//  Created by Aaron J. Fujiwara on 5/27/25.
//
import Foundation
import SwiftUI
struct LoadingScreen: View {
    @State var isActive = false
    @State var size = 0.5
    @State var opacity = 0.5
    @State var degrees = 0.0
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack{
                VStack {
                    ZStack{
                        Rectangle()
                            .ignoresSafeArea()
                        VStack {
                            Text("Friend compass")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                            
                            Image("compass 1")
                                .rotationEffect(Angle(degrees: degrees))
                            
                                .onAppear {
                                    withAnimation(.easeIn(duration: 4)) {
                                        degrees += 1080
                                        size = 1
                                        opacity = 1
                                    }
                                }
                                .scaleEffect(size)
                                .opacity(opacity)
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    isActive = true
                }
            }
        }
        
        
    }
}
#Preview {
    LoadingScreen()
}

