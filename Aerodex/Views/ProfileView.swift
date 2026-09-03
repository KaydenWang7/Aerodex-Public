//
//  ProfileView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/13/25.
//

import SwiftUI

struct ProfileView: View {
        
    var body: some View {
        NavigationStack {
            VStack() {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(maxWidth: 50, maxHeight: 50)
                
                Text(NSUserName())
                    .lineLimit(1)
                    .minimumScaleFactor(1)
                    .font(.system(size: 25, weight: .semibold))
                    .padding(.vertical, 5)
                Text("User since (date)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                List {
                    NavigationLink {
                        StatsView()
                    } label: {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        Label("Achievements", systemImage: "medal.fill")
                    }
                    
                }
                .listStyle(.plain)
                .padding(.vertical, 5)
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
