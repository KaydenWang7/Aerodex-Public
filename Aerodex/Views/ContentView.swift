//
//  ContentView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    @StateObject private var dataService = DataService.shared
    
    // body
    var body: some View {
        Group {
            if isLoading {
                FakeLoadingView()
            } else {
                TabView {
                    Tab("My Fleet", systemImage: "airplane") {
                        MyFleetView()
                    }
                    
                    Tab("Add", systemImage: "plus") {
                        AddPlanesView()
                    }
                    
                    Tab("Gallery", systemImage: "photo.on.rectangle.angled.fill") {
                        GalleryView()
                    }
                    
                    Tab("Map", systemImage: "map.fill") {
                        Text("Coming Soon")
                    }
                    
                    Tab("Profile", systemImage: "person.crop.circle.fill") {
                        ProfileView()
                    }
                }
                .transition(.opacity) // Fade in when added
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) { // Quick fade animation
                isLoading = false
                print("Switching to TabView with fade")
            }
        }
        .environmentObject(dataService)
    }
}

#Preview {
    ContentView()
}
