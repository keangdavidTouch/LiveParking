
import Foundation
import MapKit

// MARK: - ParkingModel
struct ParkingModel: Codable {
    let nhits: Int
    let parameters: Parameters
    var records: [Record]
}

// MARK: - Parameters
struct Parameters: Codable {
    let dataset: String
    let timezone: String
    let rows: Int
    let format: String
}

// MARK: - Record
struct Record: Codable {
    let datasetid, recordid: String
    let fields: Fields
    let geometry: Geometry
    let recordTimestamp: String
    //var userParkState:Bool = false
    var userDistance:Double = 0.0

    enum CodingKeys: String, CodingKey {
        case datasetid, recordid, fields, geometry
        case recordTimestamp = "record_timestamp"
    }
}

// MARK: - Fields
struct Fields: Codable {
    let totalcapacityTest: Int?
    let lastmodifieddate: String
    let fieldsOpen, id: String
    let lastupdate: String
    let from, daysopen, openingtimes: String
    let suggestedfullthreshold: Int
    let to: String
    let geoLocation: [Double]
    let latitude, parkingserver, contactinfo, fieldsDescription: String
    let city: String
    let suggestedfreethreshold, capacityrounding:Int
    let availablecapacity: Int?
    let address, newopeningtimes, name: String
    let longitude: Double
    let suggestedcapacity, parkingstatus: String
    let totalcapacity: Int
    var availableCapacity: Int {
        return availablecapacity ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case totalcapacityTest = "totalcapacity_test"
        case lastmodifieddate
        case fieldsOpen = "open"
        case id, lastupdate, from, daysopen, openingtimes, suggestedfullthreshold, to
        case geoLocation = "geo_location"
        case latitude, parkingserver, contactinfo
        case fieldsDescription = "description"
        case city, suggestedfreethreshold, capacityrounding, availablecapacity, address, newopeningtimes, name, longitude, suggestedcapacity, parkingstatus, totalcapacity
    }
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
    
    var location:CLLocation {
        return CLLocation(latitude: coordinates[1], longitude: coordinates[0])
    }
}

// MARK: - ParkingModel Functions
extension ParkingModel {
    mutating func sortRecords(by sortOrder:ParkingSortOrder) {
        switch sortOrder {
            case .alphabet:
                records.sort {
                    $0.fields.name.lowercased() < $1.fields.name.lowercased()
                }
                break
            case .capacity:
                records.sort {
                    $0.fields.availableCapacity > $1.fields.availableCapacity
                }
                break
            case .distance:
                records.sort {
                    $0.userDistance < $1.userDistance
                }
                break
        }
    }
    
//    mutating func setRecordParkState(at index:Int, isPark:Bool) {
//        resetParkingStates()
//        records[index].userParkState = isPark
//    }
//    
//    mutating private func resetParkingStates() {
//        for i in records.indices {
//            records[i].userParkState = false
//        }
//    }
}
