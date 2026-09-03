//
//  Plane.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/4/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Plane {
    var airline: String = ""
    var airlineCode: String = ""
    var model: String = ""
    var manufacturer: String = ""
    var type: String = ""
    var country: String = ""
    var seen: Bool = false
    var id = UUID()
    
    var icon: String {
        switch type {
        case "P": return "person.fill"
        case "F": return "shippingbox.fill"
        case "M": return "m.square.fill"
        default: return "questionmark.circle"
        }
    }
    
    init(raw: [String]) {
        airline = raw[0]
        airlineCode = raw[1]
        model = raw[2]
        manufacturer = raw[3]
        type = raw[4]
        country = raw[5]
    }
    
}
