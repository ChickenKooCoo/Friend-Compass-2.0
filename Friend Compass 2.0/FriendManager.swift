import Foundation
import FirebaseFirestore
import CoreLocation
import Combine
import FirebaseAuth


class FriendManager: ObservableObject {
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid

    func sendFriendRequest(to friendID: String) {
        guard let userID = userID else { return }
        db.collection("users").document(friendID)
            .collection("friendRequests").document(userID)
            .setData(["timestamp": Timestamp()])
    }

    func acceptFriendRequest(from friendID: String) {
        guard let userID = userID else { return }
        db.collection("users").document(userID)
            .collection("friends").document(friendID)
            .setData(["addedAt": Timestamp()])
        db.collection("users").document(friendID)
            .collection("friends").document(userID)
            .setData(["addedAt": Timestamp()])
        db.collection("users").document(userID)
            .collection("friendRequests").document(friendID)
            .delete()
    }

    func fetchFriendIDs(completion: @escaping ([String]) -> Void) {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("friends").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                let ids = docs.map { $0.documentID }
                completion(ids)
            }
        }
    }
}


//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//class FriendManager: ObservableObject {
//    private let db = Firestore.firestore()
//    private var userID: String? {
//        Auth.auth().currentUser?.uid
//    }
//
//    func sendFriendRequest(to friendID: String) {
//        guard let userID = userID else { return }
//        db.collection("users").document(friendID)
//            .collection("friendRequests").document(userID)
//            .setData(["timestamp": Timestamp()])
//    }
//
//    func acceptFriendRequest(from friendID: String) {
//        guard let userID = userID else { return }
//
//        // Add to both friends' accepted lists
//        db.collection("users").document(userID)
//            .collection("friends").document(friendID)
//            .setData(["addedAt": Timestamp()])
//
//        db.collection("users").document(friendID)
//            .collection("friends").document(userID)
//            .setData(["addedAt": Timestamp()])
//
//        // Delete the request
//        db.collection("users").document(userID)
//            .collection("friendRequests").document(friendID)
//            .delete()
//    }
//
//    func fetchFriendIDs(completion: @escaping ([String]) -> Void) {
//        guard let userID = userID else { return }
//        db.collection("users").document(userID).collection("friends").getDocuments { snapshot, error in
//            if let docs = snapshot?.documents {
//                let ids = docs.map { $0.documentID }
//                completion(ids)
//            } else {
//                print("Error fetching friend IDs: \(error?.localizedDescription ?? "Unknown error")")
//                completion([])
//            }
//        }
//    }
//}
