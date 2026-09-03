//
//  AddPlanesView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/4/25.
//

import SwiftUI

struct AddPlanesView: View {
    
    private let dataService = DataService.shared

    @AppStorage("addPlanesSortOption") private var addPlanesSortOption: AddPlanesSortOption = .allPlanes
    
    enum AddPlanesSortOption: String, CaseIterable {
        case allPlanes = "All Planes"
        case airline = "By Airline"
        case model = "By Model"
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch addPlanesSortOption {
                case .allPlanes:
                    PlanesListView(planes: dataService.planes, onlySeen: false)
                        .navigationTitle("All Planes")
                case .airline:
                    AirlinesListView(airlines: dataService.airlines, onlySeen: false)
                        .navigationTitle("By Airline")
                case .model:
                    ModelsListView(models: dataService.models, onlySeen: false)
                        .navigationTitle("By Model")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $addPlanesSortOption) {
                            ForEach(AddPlanesSortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

#Preview {
    AddPlanesView()
}
