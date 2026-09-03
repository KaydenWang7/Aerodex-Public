//
//  DataService.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/4/25.
//

import Foundation
import SwiftUI

class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: Data Arrays
    
    @Published var seenPlanes: [Plane] = []
    var planes: [Plane]
    var airlines: [Airline]
    var models: [Model]
    
    init() {
        self.airlines = []
        self.models = []
        self.planes = []
        self.planes = loadCSV(from: "AerodexDatabase")
        populateAirlines()
        populateModels()
        loadPercentages()
        loadSeenPlanes()
    }
    
    // fill in airlines array with Airline objects
    func populateAirlines() {
        for p in planes {
            if let airline = airlines.enumerated().first(where: { d in
                d.element.airlineCode == p.airlineCode
            }) {
                // add planes to airlines
                airlines[airline.offset].planes.append(p)
                //airline.element.planes.append(p)
            } else {
                airlines.append(Airline(airline: p.airline, airlineCode: p.airlineCode, percentage: 0.0, planes: [p]))
            }
        }
        airlines = airlines.sorted(by: {$0.airline.lowercased() < $1.airline.lowercased()})
    }
    
    // fill in models array with Model objects
    func populateModels() {
        for p in planes {
            if let model = models.enumerated().first(where: { d in
                d.element.model == p.model
            }) {
                // add planes to airlines
                models[model.offset].planes.append(p)
                //airline.element.planes.append(p)
            } else {
                models.append(Model(model: p.model, manufacturer: p.manufacturer, percentage: 0.0, planes: [p]))
            }
        }
        models = models.sorted(by: {$0.model.lowercased() < $1.model.lowercased()})
    }
    
    // loads percentages for Airlines and Models in data
    func loadPercentages() {
        for index in 0..<airlines.count {
            loadSingleAirlinePercentage(airlines[index])
        }
        for index in 0..<models.count {
            loadSingleModelPercentage(models[index])
        }
    }
    
    // loads percentage for a single Airline
    func loadSingleAirlinePercentage(_ airline: Airline) {
        var seen = 0.0;
        for p in airline.planes {
            if p.seen {
                seen+=1;
            }
        }
        if let offset = airlines.firstIndex(where: {$0.airlineCode == airline.airlineCode}) {
            airlines[offset].percentage = (seen/Double(airline.planes.count));
        }
    }
    
    // loads percentage for a single Model
    func loadSingleModelPercentage(_ model: Model) {
        var seen = 0.0;
        for p in model.planes {
            if p.seen {
                seen+=1;
            }
        }
        if let offset = models.firstIndex(where: {$0.model == model.model}) {
            models[offset].percentage = (seen/Double(model.planes.count));
        }
    }
    
    // decodes plane shorthand (code + type) into Plane object
    func decodePlane(_ plane: String) -> Plane? {
        
        let CODE = String(plane.prefix(2))
        let MODEL = String(plane.dropFirst(2).dropLast(1))
        let TYPE = String(plane.suffix(1))
        
        for p in planes {
            if p.airlineCode == CODE && p.model == MODEL && p.type == TYPE {
                return p
            }
        }
        return nil
    }
    
    func markSeen(plane: Plane) {
        plane.seen = true
        loadSingleAirlinePercentage(airlines.first(where: { $0.airlineCode == plane.airlineCode })!)
        loadSingleModelPercentage(models.first(where: { $0.model == plane.model })!)
        loadSeenPlanes()
    }
    
    func markUnseen(plane: Plane) {
        plane.seen = false
        loadSingleAirlinePercentage(airlines.first(where: { $0.airlineCode == plane.airlineCode })!)
        loadSingleModelPercentage(models.first(where: { $0.model == plane.model })!)
        loadSeenPlanes()
    }
    
    func loadSeenPlanes() {
        self.seenPlanes = getSeenPlanes()
    }

    // returns an array of seen Planes
    func getSeenPlanes() -> [Plane] {
        let seenPlanes = planes.filter { $0.seen }
        return seenPlanes
            .sorted { $0.model.lowercased() < $1.model.lowercased() }
            .sorted { $0.airline.lowercased() < $1.airline.lowercased() }
            .sorted { (a, b) -> Bool in
                let order: [String: Int] = ["P": 0, "F": 1, "M": 2]
                let rankA = order[a.type] ?? Int.max
                let rankB = order[b.type] ?? Int.max
                return rankA < rankB
            }
    }
    
    // returns an array of seen Planes in String array
    func getSeenPlanesString() -> [String] {
        var res: [String] = []
        for p in getSeenPlanes() {
            res.append(p.airlineCode + p.model)
        }
        return res
    }
    
    // returns an array of seen Airlines
    func getSeenAirlines() -> [Airline] {
        let seenAirlineCodes = Set(planes.filter { $0.seen }.map { $0.airlineCode })
        return airlines
            .filter { seenAirlineCodes.contains($0.airlineCode) }
            .sorted { $0.airline.lowercased() < $1.airline.lowercased() }
    }
    
    // returns an array of seen Models
    func getSeenModels() -> [Model] {
        let seenModels = Set(planes.filter { $0.seen }.map { $0.model })
        return models
            .filter { seenModels.contains($0.model) }
            .sorted { $0.model.lowercased() < $1.model.lowercased() }
    }

    // gets fraction from percent viewed
    func getFractionFromPercentage(_ airline: Airline) -> String {
        var numSeen: Int = 0
        for p in airline.planes {
            if p.seen { numSeen += 1 }
        }
        return String(numSeen) + "/" + String(airline.planes.count)
    }
    
    // removes all seen aircraft
    func clearAircraftSeen() {        
        for plane in planes { plane.seen = false }
        loadSeenPlanes()
    }
    
    func loadCSV(from csvName: String) -> [Plane] {
        var csvToStruct = [Plane]()
        
        // Locate the csv file
        guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
            return []
        }
        
        // Convert the contents of the file into one very long string
        var data = ""
        do {
            data = try String(contentsOf: URL(fileURLWithPath: filePath), encoding: String.Encoding.utf8)
        } catch {
            print(error)
            return []
        }
        
        // Split the long string into an array of "rows" of data. each row is a string
        // Detect "\n" carriage return, then split
        var rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        // Remove header rows
        // Count the number of header columns before removing
        let columnCount = rows.first?.components(separatedBy: ",").count
        rows.removeFirst()
        
        // Now loop around each row and split into columns
        for row in rows {
            let csvColumns = row.components(separatedBy: ",")
            if csvColumns.count == columnCount {
                let planeStruct = Plane.init(raw: csvColumns)
                csvToStruct.append(planeStruct)
            }
        }
        
        return csvToStruct
            .sorted(by: {$0.model.lowercased() < $1.model.lowercased()})
            .sorted(by: {$0.airline.lowercased() < $1.airline.lowercased()})
    }
    
    func loadImportedCSV(_ content: String) -> [String] {
        // Split into lines and remove empty lines
        let lines = content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
        
        // Skip header (first line) and return remaining values
        return Array(lines.dropFirst())
    }
    
    func processImportedCSV(array: [String]) {
        for item in array {
            for plane in planes {
                if plane.airlineCode + plane.model == item {
                    plane.seen = true
                }
            }
        }
        loadSeenPlanes()
    }
    
    func generateCSV(planes: [String]) -> URL {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        
        var fileURL: URL!
        // heading of CSV file.
        let heading = "Planes\n"
        
        // file rows
        let rows = planes.map { "\($0)" }
        
        // rows to string data
        let stringData = heading + rows.joined(separator: "\n")
        
        do {
            
            let path = try FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
            
            fileURL = path.appendingPathComponent("Aerodex-Export-\(currentDate).csv")
            
            // append string data to file
            try stringData.write(to: fileURL, atomically: true , encoding: .utf8)
            print(fileURL!)
            
        } catch {
            print("error generating csv file")
        }
        return fileURL
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return image // Return original if resize fails
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

