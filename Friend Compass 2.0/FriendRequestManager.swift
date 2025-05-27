import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

class FriendLocationManager: ObservableObject {
    @Published var friends: [Friend] = []

    func updateFriendLocation(id: String, location: CLLocationCoordinate2D) {
        if let index = friends.firstIndex(where: { $0.id == id }) {
            friends[index].location = location
        }
    }

    func addFriend(_ friend: Friend) {
        friends.append(friend)
    }
}

//
//import Foundation
//import Combine
//import CoreLocation
//
//class FriendLocationManager: ObservableObject {
//    @Published var friends: [Friend] = []
//
//    func updateFriendLocation(id: String, location: CLLocationCoordinate2D) {
//        if let index = friends.firstIndex(where: { $0.id == id }) {
//            friends[index].latitude = location.latitude
//            friends[index].longitude = location.longitude
//        }
//    }
//
//    func addFriend(_ friend: Friend) {
//        if !friends.contains(where: { $0.id == friend.id }) {
//            friends.append(friend)
//        }
//    }
//}
