
import Foundation
import MapKit

// MARK: - ParkingModel
class ParkingModel: Codable {
    let nhits: Int
    let parameters: Parameters
    var records: [Record]
    var recentUpdateDate = Date()
    fileprivate var isUpdatingDistances:Bool = false

    enum CodingKeys: String, CodingKey {
        case nhits, parameters, records
    }
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
    
    func fetchRecentUpdateDate() {
        if let record = records.first {
            recentUpdateDate = ParkingDateHelper.getDate(from: record.fields.lastupdate)
        }
    }
    
    func sortRecords(by sortOrder:ParkingSortOrder) {
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
    
    func calculateParkingDistance(from location: CLLocation, locationService:LocationService, completion:@escaping() -> Void) {
        
        guard isUpdatingDistances == false else {
            return
        }
        isUpdatingDistances = true
        
        let group = DispatchGroup()
        for i in records.indices {
            let parkingLocation = records[i].geometry.location
            group.enter()
            
            locationService.calculateRouteDistance(between: parkingLocation, location) { [weak self] (distance) in
                if self?.records[i] != nil {
                    self?.records[i].userDistance = distance
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isUpdatingDistances = false
            completion()
        }
    }
}
