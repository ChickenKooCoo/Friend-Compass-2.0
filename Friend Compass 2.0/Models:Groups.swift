import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

struct Group: Identifiable, Codable {
    var id: String
    var name: String
    var members: [String]
}
