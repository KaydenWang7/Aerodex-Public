//
//  ExpandedPhotoView.swift
//  Aerodex
//
//  Created by Kayden Wang on 5/8/25.
//

import SwiftUI
import InteractiveImageView
import Photos

struct ExpandedPhotoView: View {
    
    let photo: PlanePhoto
    @State var tapLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: photo.icon)
                    .padding(.top)
                Text("\(photo.airlineCode) \(photo.model)")
                    .padding(.top)
                    .font(.title2)
            }
            .frame(alignment: .center)
            Text("\(photo.registration ?? " ")")
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            InteractiveImage(image: UIImage(data:photo.image) ?? UIImage(systemName: "photo")!, zoomInteraction: .init(location: tapLocation, scale: 1.2, animated: true))
        }
    }
}
