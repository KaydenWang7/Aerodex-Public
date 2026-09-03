//
//  AirlinesListView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/13/25.
//

import SwiftUI

struct AirlinesListView: View {
    let airlines: [Airline]
    let onlySeen: Bool
    
    @State private var searchText = ""
    
    var filteredAirlines: [Airline] {
        if searchText.isEmpty {
            return airlines
        } else {
            return airlines.filter { airline in
                airline.airline.localizedCaseInsensitiveContains(searchText) || airline.airlineCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
            if onlySeen {
                itemContent()
                    .listStyle(.automatic)
            } else {
                itemContent()
                    .listStyle(.plain)
            }
    }
    
    @ViewBuilder
    private func itemContent() -> some View {
        List(filteredAirlines, id: \.id) { airline in
            NavigationLink(destination: PlanesListView(planes: (onlySeen ? DataService.shared.getSeenPlanes().filter { $0.airlineCode == airline.airlineCode} : airline.planes), onlySeen: onlySeen)) {
                Group {
                    HStack(spacing: 16) {
                        Image(airline.airlineCode)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 5)
                        
                        VStack {
                            HStack {
                                Text(airline.airline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(1)
                                
                                Text(airline.airlineCode)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("\(Int(airline.percentage * 100))%")
                                    .frame(width: 50, alignment: .leading)
                                    .monospacedDigit()
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            
                            ProgressView(value: airline.percentage)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    AirlinesListView(airlines: DataService.shared.airlines, onlySeen: false)
}
