//
//  GalleryView.swift
//  Aerodex
//
//  Created by Kayden Wang on 5/4/25.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @AppStorage("gallerySortOption") private var gallerySortOption: GallerySortOption = .timestamp
    
    enum GallerySortOption: String, CaseIterable {
        case timestamp = "Timestamp"
        case airlineCode = "Airline Code"
        case model = "Model"
    }
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \PlanePhoto.timestamp) private var planePhotos: [PlanePhoto]
    
    var sortedPhotos: [PlanePhoto] {
        switch gallerySortOption {
        case .timestamp:
            return planePhotos.sorted { $0.timestamp < $1.timestamp }
        case .airlineCode:
            return planePhotos.sorted { $0.airlineCode < $1.airlineCode }
        case .model:
            return planePhotos.sorted { $0.model < $1.model }
        }
    }
    
    @State private var isEditingRegistration = false
    @State private var registrationText: String = ""
    @State private var isSheetPresented: Bool = false
    @State private var selectedPhoto: PlanePhoto?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 3)], spacing: 3) {
                    ForEach(sortedPhotos) { photo in
                        itemContent(photo: photo)
                            .onTapGesture {
                                selectedPhoto = photo
                                isSheetPresented.toggle()
                            }
                    }
                }
                .sheet(isPresented: $isSheetPresented) {
                    if let selectedPhoto {
                        ExpandedPhotoView(photo: selectedPhoto)
                            .id(selectedPhoto.id)
                    }
                }
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $gallerySortOption) {
                            ForEach(GallerySortOption.allCases, id: \.self) { option in
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
    
    @ViewBuilder
    private func itemContent(photo: PlanePhoto) -> some View {
        VStack {
            Image(uiImage: (UIImage(data:photo.image) ?? UIImage(systemName: "photo")!))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(12)
                .contextMenu {
                    Text("Registration: \(photo.registration ?? "No registration")")
                    Button("Edit Registration") {
                        selectedPhoto = photo
                        registrationText = photo.registration ?? ""
                        isEditingRegistration = true
                    }
                    Button("Delete Image", role: .destructive) {
                        modelContext.delete(photo)
                    }
                }
            HStack {
                Image(systemName: photo.icon)
                Text("\(photo.airlineCode) \(photo.model)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .foregroundColor(.primary)
            }
            Text("\(photo.registration ?? " ")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, idealHeight: 200)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
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
                Text("Edit registration for \(selectedPhoto.airlineCode) \(selectedPhoto.model)")
            }
        })
    }
}

#Preview {
    GalleryView()
}
