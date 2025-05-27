import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

struct Friend: Identifiable, Codable {
    var id: String
    var name: String
    var isAccepted: Bool
    var colorHex: String?
    var location: CLLocationCoordinate2D?
}


//import Foundation
//import CoreLocation
//
//struct Friend: Identifiable, Codable {
//    var id: String
//    var name: String
//    var isAccepted: Bool
//    var latitude: Double?
//    var longitude: Double?
//
//    // Computed property to convert lat/lon to CLLocationCoordinate2D
//    var location: CLLocationCoordinate2D? {
//        guard let lat = latitude, let lon = longitude else { return nil }
//        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    }
//}
