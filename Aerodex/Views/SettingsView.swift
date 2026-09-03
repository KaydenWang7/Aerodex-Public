//
//  SettingsView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/14/25.
//

import SwiftUI
import SwiftData


struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showImporter = false
    @State private var importedText: String? = nil
    @Query var planePhotos: [PlanePhoto]
    
    @State private var showingConfirmation = false
    @State private var confirmationText = ""
    @State private var isActionConfirmed = false
    @State private var confirmationAction = ""
    @State private var showingAlert = false
    
    
    var body: some View {
        NavigationView {
            List {
                 
                ShareLink(item:DataService.shared.generateCSV(planes: DataService.shared.getSeenPlanesString())) {
                    Label("Export CSV", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                
                Button(action: {
                    showImporter = true
                }, label: {
                    Label("Import CSV", systemImage: "square.and.arrow.down.fill")
                })
                
                if let importedText = importedText {
                    Text("File Content: \n\(importedText)")
                }
                
                Section() {
                    Button(action: {
                        confirmationAction = "photos"
                        showingConfirmation = true
                        confirmationText = "" // Reset input
                    }, label: {
                        Label("Delete All Photos", systemImage: "trash")
                        .foregroundColor(.red)
                    })
                    
                    Button(action: {
                        confirmationAction = "seen"
                        showingConfirmation = true
                        confirmationText = "" // Reset input
                    }, label: {
                        Label("Clear All Spotted Planes", systemImage: "trash")
                        .foregroundColor(.red)
                    })
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.text],
                allowsMultipleSelection: false
            ) { result in
                print("result: \(result)")

                switch result {
                case .success(let urls):
                    print("success url: \(urls)")
                    guard let url = urls.first else {return}
                    guard let fileContent = try? String(contentsOf: url, encoding: .utf8) else {return}
                    self.importedText = fileContent
                case .failure(let error):
                    print("failed with error: \(error.localizedDescription)")
                }
            }
            .alert("Are you sure?", isPresented: $showingConfirmation, actions: {
                TextField("Enter CONFIRM", text: $confirmationText)
                
                Button("Submit") {
                    if confirmationText == "CONFIRM" {
                        if confirmationAction == "seen" {
                            DataService.shared.clearAircraftSeen()
                            showingAlert = true
                        } else if confirmationAction == "photos" {
                            do {
                                try modelContext.delete(model: PlanePhoto.self)
                                try modelContext.save() // Persist the deletion
                            } catch {
                                print("Failed to delete Plane Photos.")
                            }
                            showingAlert = true
                        } else {
                        }
                        isActionConfirmed = true
                    }
                    showingConfirmation = false
                }
                .disabled(confirmationText != "CONFIRM")
                .tint(.red)
                
                Button("Cancel", role: .cancel) {
                    showingConfirmation = false
                }
            }, message: {
                Text("This action is permanent. To proceed, type CONFIRM")
            })
            .alert(isPresented: $showingAlert) {
                if confirmationAction == "seen" {
                    Alert(title: Text("Spotted aircraft cleared"), dismissButton: .default(Text("Got it")))

                } else {
                    Alert(title: Text("Photos cleared"), dismissButton: .default(Text("Got it")))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

