//
//  PlanesListView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/16/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PlanesListView: View {
    @Environment(\.modelContext) var modelContext
    let planes: [Plane]
    @State private var searchText = ""
    @State private var planeToUnspot: Plane? = nil // The plane pending "unspotted" confirmation
    
    @State var selectedPhoto: PhotosPickerItem? // The photo that is selected from the photos picker
    @State var photoPlane: Plane? = nil // The plane object associated with the photo
    @State var isShowingPhotosPicker = false
    
    @Query var planePhotos: [PlanePhoto] // All photos stored in the app
    
    var filteredPlanes: [Plane] {
        if searchText.isEmpty {
            return planes
        } else {
            return planes.filter { plane in
                plane.airline.localizedCaseInsensitiveContains(searchText) ||
                plane.model.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    let onlySeen: Bool
    
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
        List(filteredPlanes) { plane in
            NavigationLink(destination: PlaneDetailView(plane: plane)) {
                Group {
                    HStack(spacing: 16) {
                        Image(plane.airlineCode)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(plane.airline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(1)
                            
                            HStack {
                                Image(systemName: plane.icon)
                                    .foregroundColor(.secondary)
                                Text(plane.model)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        let hasPhotos = !(planePhotos.filter { photo in
                            photo.airlineCode == plane.airlineCode && photo.model == plane.model && photo.type == plane.type
                        }.isEmpty)
                        if plane.seen {
                            if hasPhotos {
                                Image(systemName: "photo.badge.checkmark.fill")
                                    .padding(.horizontal, 10)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .swipeActions(edge: .trailing) {
                Button {
                    withAnimation {
                        planeToUnspot = plane
                    }
                } label: {
                    Label("", systemImage: "x.circle.fill")
                }
                .tint(.red)
            }
            .swipeActions(edge: .leading) {
                Button {
                    markPlaneSeen(plane)
                } label: {
                    Label("", systemImage: "checkmark.circle")
                }
                .tint(.green)
                
                Button {
                    markPlaneSeen(plane)
                    photoPlane = plane
                    isShowingPhotosPicker = true
                } label: {
                    Label("", systemImage: "photo.badge.plus.fill")
                }
                .tint(.blue)
            }
            .confirmationDialog("Marking as unspotted will remove all photos for this plane.",
                                isPresented: Binding(
                                    get: { planeToUnspot?.id == plane.id },     // only this row shows when selected
                                    set: { if !$0 { planeToUnspot = nil } }     // clear when dismissed
                                ),
                                titleVisibility: .visible) {
                Button("Confirm", role: .destructive) {
                    if let target = planeToUnspot {
                        deletePhotos(for: target)
                        markPlaneUnseen(target)
                    }
                    planeToUnspot = nil
                }
                Button("Cancel", role: .cancel) {
                    planeToUnspot = nil
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    let image = DataService.shared.resizeImage(image: UIImage(data: data)!, targetSize: CGSize(width: 1080.0, height: 1080.0))
                    modelContext.insert(PlanePhoto(airlineCode: photoPlane?.airlineCode ?? "", model: photoPlane?.model ?? "", type: photoPlane?.type ?? "", image: image.jpegData(compressionQuality: 1.0)!, timestamp: Date()))
                }
                selectedPhoto = nil
            }
        }
        .photosPicker(isPresented: $isShowingPhotosPicker, selection: $selectedPhoto, matching: .images, photoLibrary: .shared())
    }
    
    func markPlaneSeen(_ plane: Plane) {
        plane.seen = true
        do { try modelContext.save() } catch {
            print("Failed to mark seen: \(error)")
        }
        print("Marking Seen: \(plane.airlineCode) \(plane.model) \(plane.type)")
    }

    func markPlaneUnseen(_ plane: Plane) {
        plane.seen = false
        do { try modelContext.save() } catch {
            print("Failed to mark unseen: \(error)")
        }
        print("Marking Unseen: \(plane.airlineCode) \(plane.model) \(plane.type)")
    }
    
    func deletePhotos(for plane: Plane) {
        let toDelete = planePhotos.filter { photo in
            photo.airlineCode == plane.airlineCode &&
            photo.model == plane.model &&
            photo.type == plane.type
        }
        for photo in toDelete {
            modelContext.delete(photo)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete photos for \(plane.airlineCode) \(plane.model) \(plane.type): \(error)")
        }
    }
}

#Preview {
    PlanesListView(planes: DataService.shared.planes, onlySeen: false)
}

