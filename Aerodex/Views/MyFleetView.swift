//
//  MyFleetView.swift
//  Aerodex
//
//  Created by Kayden Wang on 5/5/25.
//

import SwiftUI

struct MyFleetView: View {
    @StateObject private var dataService = DataService.shared

    @AppStorage("myFleetSortOption") private var myFleetSortOption: MyFleetSortOption = .allPlanes
    
    enum MyFleetSortOption: String, CaseIterable {
        case allPlanes = "All Planes"
        case airline = "By Airline"
        case model = "By Model"
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch myFleetSortOption {
                case .allPlanes:
                    PlanesListView(planes: dataService.getSeenPlanes(), onlySeen: true)
                        .navigationTitle("My Fleet")
                case .airline:
                    AirlinesListView(airlines: dataService.getSeenAirlines(), onlySeen: true)
                        .navigationTitle("My Fleet")
                case .model:
                    ModelsListView(models: dataService.getSeenModels(), onlySeen: true)
                        .navigationTitle("My Fleet")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $myFleetSortOption) {
                            ForEach(MyFleetSortOption.allCases, id: \.self) { option in
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
    MyFleetView()
}
