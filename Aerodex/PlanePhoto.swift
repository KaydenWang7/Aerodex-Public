//
//  PlanePhoto.swift
//  Aerodex
//
//  Created by Kayden Wang on 5/1/25.
//

import Foundation
import SwiftData

@Model
final class PlanePhoto: Identifiable {
    var id: UUID = UUID()
    var airlineCode: String
    var model: String
    var type: String
    var icon: String {
        switch type {
        case "P": return "person.fill"
        case "F": return "shippingbox.fill"
        case "M": return "m.square.fill"
        default: return "questionmark.circle"
        }
    }
    var image: Data
    var timestamp: Date
    var registration: String?
    
    init (airlineCode: String = "", model: String = "", type: String = "", image: Data = Data(), timestamp: Date = Date()) {
        self.airlineCode = airlineCode
        self.model = model
        self.type = type
        self.image = image
        self.timestamp = timestamp
    }
    
}
