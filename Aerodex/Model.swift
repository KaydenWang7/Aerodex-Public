//
//  Model.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/13/25.
//

import Foundation
import SwiftUI

struct Model: Identifiable {
    var model: String = ""
    var manufacturer: String = ""
    var percentage: Double = 0.0
    var planes: [Plane]
    var id = UUID()
    
    init(model: String, manufacturer: String, percentage: Double, planes: [Plane]) {
        self.model = model
        self.manufacturer = manufacturer
        self.percentage = percentage
        self.planes = planes
    }
    
}
