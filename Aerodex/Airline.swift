//
//  Airline.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/4/25.
//

import Foundation
import SwiftUI

struct Airline: Identifiable {
    var airline: String = ""
    var airlineCode: String = ""
    var percentage: Double = 0.0
    var planes: [Plane]
    var id = UUID()
    
    init(airline: String, airlineCode: String, percentage: Double, planes: [Plane]) {
        self.airline = airline
        self.airlineCode = airlineCode
        self.percentage = percentage
        self.planes = planes
    }
}
