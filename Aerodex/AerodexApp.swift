//
//  AerodexApp.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/3/25.
//

import SwiftUI
import Photos

@main
struct AerodexApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PlanePhoto.self)
    }
}
