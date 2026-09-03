//
//  ModelsListView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/13/25.
//

import SwiftUI

struct ModelsListView: View {
    let models: [Model]
    let onlySeen: Bool
    
    @State private var searchText = ""
    
    // Group models by manufacturer
    var groupedModels: [String: [Model]] {
        let filtered = if searchText.isEmpty {
            models
        } else {
            models.filter { $0.model.localizedCaseInsensitiveContains(searchText) || $0.manufacturer.localizedStandardContains(searchText) }
        }
        
        return Dictionary(grouping: filtered) { $0.manufacturer }
            .sorted { $0.key < $1.key } // Sort manufacturers alphabetically
            .reduce(into: [String: [Model]]()) { result, pair in
                result[pair.key] = pair.value.sorted { $0.model < $1.model } // Sort models within each manufacturer
            }
    }
    
    var body: some View {
            if onlySeen {
                itemContent()
                    .listStyle(.insetGrouped)
            } else {
                itemContent()
                    .listStyle(.plain)
            }
    }
    
    @ViewBuilder
    private func itemContent() -> some View {
        List {
            ForEach(groupedModels.keys.sorted(), id: \.self) { manufacturer in
                Section(header: Text(manufacturer).font(.title3)) {
                    ForEach(groupedModels[manufacturer] ?? []) { model in
                        NavigationLink(destination: PlanesListView(planes: (onlySeen ? DataService.shared.getSeenPlanes().filter { $0.model == model.model} : model.planes), onlySeen: onlySeen)) {
                            Group {
                                HStack(spacing: 16) {
                                    Image(model.manufacturer)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 50, maxHeight: 50)
                                        .padding(.vertical, 5)
                                    
                                    VStack {
                                        HStack {
                                            Text(model.model)
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                                .minimumScaleFactor(1)
                                            
                                            Text(model.manufacturer)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        HStack {
                                            Text("\(Int(model.percentage * 100))%")
                                                .frame(width: 50, alignment: .leading)
                                                .monospacedDigit()
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                        }
                                        
                                        ProgressView(value: model.percentage)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
}


#Preview {
    ModelsListView(models: DataService.shared.models, onlySeen: false)
}
