//
//  PlaneDetailView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/13/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PlaneDetailView: View {
    
    private let dataService = DataService.shared
    
    var plane: Plane
    @Environment(\.modelContext) var modelContext
    @Query(sort: \PlanePhoto.timestamp) private var planePhotos: [PlanePhoto]
    
    @State private var selectedPhoto: PlanePhoto?
    @State private var isEditingRegistration = false
    @State private var registrationText: String = ""
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isShowingPhotosPicker = false
    
    var body: some View {
        VStack() {
            VStack() {
                Image(plane.airlineCode)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Text(plane.airline)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                
                Text("Model: \(plane.model)")
                Text("Manufacturer: \(plane.manufacturer)")
                Text("Country: \(plane.country)")
            }
            
            Group {
                if planePhotos.filter({ photo in
                    photo.airlineCode == plane.airlineCode && photo.model == plane.model && photo.type == plane.type
                }).isEmpty {
                    Text("No Photos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    CarouselPhotoView(planePhotos: planePhotos.filter { photo in photo.airlineCode == plane.airlineCode && photo.model == plane.model && photo.type == plane.type } )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            
            Spacer(minLength: 0)
            
            Button(action: {
                isShowingPhotosPicker = true
            }) {
                HStack {
                    Image(systemName: "photo.badge.plus.fill")
                    Text("Add Photos")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotos) {
            Task {
                await processSelectedPhotos()
            }
        }
    }
    
    @MainActor
    private func processSelectedPhotos() async {
        for photoItem in selectedPhotos {
            if let data = try? await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let resizedImage = DataService.shared.resizeImage(image: image, targetSize: CGSize(width: 1080.0, height: 1080.0))
                let planePhoto = PlanePhoto(
                    airlineCode: plane.airlineCode,
                    model: plane.model,
                    type: plane.type,
                    image: resizedImage.jpegData(compressionQuality: 1.0)!,
                    timestamp: Date()
                )
                modelContext.insert(planePhoto)
            }
        }
        
        // Clear the selection after processing
        selectedPhotos.removeAll()
    }
}

#Preview {
    PlaneDetailView(plane: DataService.shared.planes.first!)
}
