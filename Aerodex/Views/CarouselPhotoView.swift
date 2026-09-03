//
//  CarouselPhotoView.swift
//  Aerodex
//
//  Created by Kayden Wang on 5/7/25.
//

import SwiftUI

struct CarouselPhotoView: View {
    let planePhotos: [PlanePhoto]
    
    @Environment(\.modelContext) var modelContext
    @State private var isEditingRegistration = false
    @State private var registrationText: String = ""
    @State private var isSheetPresented: Bool = false
    @State private var selectedPhoto: PlanePhoto?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 35) {
                ForEach(planePhotos) { photo in
                    Image(uiImage: (UIImage(data:photo.image) ?? UIImage(systemName: "photo")!))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 70, height: 250)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 30))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.horizontal, 10)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .scaleEffect(y: phase.isIdentity ? 1 : 0.7)
                        }
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .contextMenu {
                            Button("View in Photos") {
                                // Placeholder for future button
                            }
                            Text("Registration: \(photo.registration ?? "")")
                            Button("Edit Registration") {
                                selectedPhoto = photo
                                registrationText = photo.registration ?? ""
                                isEditingRegistration = true
                            }
                            Button("Delete Image", role: .destructive) {
                                modelContext.delete(photo)
                            }
                        }
                        .onTapGesture {
                            selectedPhoto = photo
                            isSheetPresented.toggle()
                        }
                }
                .alert("Edit registration", isPresented: $isEditingRegistration, actions: {
                    TextField("Ex: F-WTSS", text: $registrationText)
                    Button("OK") {
                        if let selectedPhoto {
                            selectedPhoto.registration = registrationText
                            try? modelContext.save() // Ensure changes are persisted
                        }
                        isEditingRegistration = false
                    }
                }, message: {
                    if let selectedPhoto {
                        Text("Edit registration for \(selectedPhoto.airlineCode) \(selectedPhoto.model) \(selectedPhoto.type)")
                    }
                })
            }
            .scrollTargetLayout()
            .frame(height: 250)
            .sheet(isPresented: $isSheetPresented) {
                if let selectedPhoto {
                    ExpandedPhotoView(photo: selectedPhoto)
                        .id(selectedPhoto.id)
                }
            }
        }
        .contentMargins(50, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
}
